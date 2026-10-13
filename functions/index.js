/**
 * FixinDays Cloud Functions (firebase-functions v2, Node 20).
 *
 * These functions are the TRUSTED backend: clients call them via HTTPS
 * callable endpoints; Firestore rules deny direct status/payment writes, so
 * the real checks happen here against the Admin SDK (which bypasses rules).
 *
 * Callable functions in this file:
 *  - validateBooking      customer: server-side price/slot/provider validation
 *  - transitionBooking    customer|provider: enforced status transition matrix
 *  - generateArrivalCode  provider: 4-digit arrival code (sha256 stored)
 *  - submitReview         customer: one review per completed booking
 *  - askAssistant         customer: Gemini online mode for the AI assistant
 *                          (key from env, never the client; honest
 *                          "not configured" error when unset)
 *  - setAdminClaim        admin only: grant the `admin:true` custom claim
 *
 * Firestore triggers:
 *  - onBookingWrite       bookings/{id}: fan-out status notifications
 *
 * Every callable validates input AND authentication/authorization and throws
 * HttpsError with a safe (non-leaky) message on failure.
 */

const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {onDocumentWritten} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
const {createHash, randomInt} = require('node:crypto');
const logger = require('firebase-functions/logger');

admin.initializeApp();
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const nowMs = () => Date.now();

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

/** Require a signed-in caller; return the uid. */
function requireUid(request) {
  const uid = request.auth && request.auth.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Sign in is required.');
  }
  return uid;
}

/** Require the caller to hold the admin custom claim. */
function requireAdmin(request) {
  const uid = requireUid(request);
  // IMPORTANT: admin rights come ONLY from the custom claim
  // `admin: true` on the ID token — never from a Firestore field.
  if (!request.auth.token || request.auth.token.admin !== true) {
    throw new HttpsError('permission-denied', 'Admin access required.');
  }
  return uid;
}

function asNonEmptyString(v, name, maxLen = 500) {
  if (typeof v !== 'string' || v.trim().length === 0) {
    throw new HttpsError('invalid-argument', `${name} is required.`);
  }
  if (v.length > maxLen) {
    throw new HttpsError('invalid-argument', `${name} is too long.`);
  }
  return v.trim();
}

function asPositiveInt(v, name) {
  const n = Number(v);
  if (!Number.isInteger(n) || n <= 0) {
    throw new HttpsError('invalid-argument', `${name} must be a positive integer.`);
  }
  return n;
}

/** Commission basis points from config/platform (default 1000 = 10%). */
async function commissionBps() {
  const doc = await db.collection('config').doc('platform').get();
  const bps = doc.exists ? doc.data().commissionBps : 1000;
  return Number.isInteger(bps) && bps >= 0 && bps <= 10000 ? bps : 1000;
}

async function addBookingEvent(bookingId, type, {actorRole, actorId, note} = {}) {
  await db
    .collection('bookings')
    .doc(bookingId)
    .collection('bookingEvents')
    .add({
      bookingId,
      type,
      actorRole: actorRole || null,
      actorId: actorId || null,
      note: note || null,
      createdAt: nowMs(),
    });
}

// Allowed status transitions: from -> {to -> which side may perform it}.
// 'customer' | 'provider' | 'either'
const TRANSITIONS = {
  pending: {accepted: 'provider', rejected: 'provider', cancelled: 'either'},
  accepted: {confirmed: 'provider', cancelled: 'either'},
  confirmed: {enRoute: 'provider', cancelled: 'either'},
  enRoute: {arrived: 'provider'},
  arrived: {inProgress: 'provider'}, // requires arrival code match
  inProgress: {completed: 'provider'},
  completed: {disputed: 'either'},
  rejected: {},
  cancelled: {},
  disputed: {cancelled: 'either'}, // admin resolves disputes via console
};

const ACTIVE_STATUSES = [
  'pending', 'accepted', 'confirmed', 'enRoute', 'arrived', 'inProgress',
];

/**
 * Caller must be a party to the booking. Returns {booking, side}.
 * Side is 'customer' or 'provider'.
 */
async function loadBookingForCaller(bookingId, uid) {
  const id = asNonEmptyString(bookingId, 'bookingId', 100);
  const snap = await db.collection('bookings').doc(id).get();
  if (!snap.exists) {
    throw new HttpsError('not-found', 'Booking not found.');
  }
  const booking = {id: snap.id, ...snap.data()};
  let side = null;
  if (booking.customerId === uid) side = 'customer';
  else if (booking.providerId === uid) side = 'provider';
  if (!side) {
    throw new HttpsError(
      'permission-denied',
      'You are not a party to this booking.',
    );
  }
  return {booking, side};
}

// ---------------------------------------------------------------------------
// validateBooking — customer
// ---------------------------------------------------------------------------
/**
 * Server-side booking validation. The client sends what the customer picked;
 * the function re-derives prices from the provider's own service documents,
 * verifies the provider is approved+active, checks for slot conflicts, and
 * returns the totals the client must use. Client-supplied totals are
 * rejected if they differ.
 */
exports.validateBooking = onCall(async (request) => {
  const customerId = requireUid(request);
  const data = request.data || {};

  const providerId = asNonEmptyString(data.providerId, 'providerId', 100);
  if (!Array.isArray(data.items) || data.items.length === 0) {
    throw new HttpsError('invalid-argument', 'items must be a non-empty array.');
  }
  if (data.items.length > 20) {
    throw new HttpsError('invalid-argument', 'Too many items.');
  }
  const scheduledAt = asPositiveInt(data.scheduledAt, 'scheduledAt');
  if (scheduledAt < nowMs() - 60_000) {
    throw new HttpsError('invalid-argument', 'scheduledAt must be in the future.');
  }
  const addressSnapshot = asNonEmptyString(data.addressSnapshot, 'addressSnapshot', 1000);
  const clientTotal =
    data.totalPaise == null ? null : asPositiveInt(data.totalPaise, 'totalPaise');

  // Provider must exist, be approved and active.
  const provSnap = await db.collection('providers').doc(providerId).get();
  if (!provSnap.exists) {
    throw new HttpsError('not-found', 'Provider not found.');
  }
  const prov = provSnap.data();
  if (prov.verificationStatus !== 'approved' || prov.active !== true) {
    throw new HttpsError(
      'failed-precondition',
      'This provider is not available for new bookings right now.',
    );
  }

  // Re-derive line items from the provider's own service docs.
  const bps = await commissionBps();
  const items = [];
  let subtotal = 0;
  for (const raw of data.items) {
    const serviceId = asNonEmptyString(raw && raw.serviceId, 'items[].serviceId', 100);
    const qty = asPositiveInt(raw && raw.quantity, 'items[].quantity');
    const svcSnap = await db.collection('providerServices').doc(serviceId).get();
    if (!svcSnap.exists) {
      throw new HttpsError('not-found', `Service ${serviceId} not found.`);
    }
    const svc = svcSnap.data();
    if (svc.providerId !== providerId) {
      throw new HttpsError('invalid-argument', 'Service does not belong to this provider.');
    }
    if (svc.active !== true) {
      throw new HttpsError('failed-precondition', `Service "${svc.name}" is not active.`);
    }
    const unitPrice = Number(svc.pricePaise);
    if (!Number.isInteger(unitPrice) || unitPrice < 0) {
      throw new HttpsError('failed-precondition', `Service "${svc.name}" has an invalid price.`);
    }
    items.push({
      serviceId,
      serviceName: svc.name,
      quantity: qty,
      unitPricePaise: unitPrice,
      priceBasis: svc.priceBasis || 'fixed',
    });
    subtotal += unitPrice * qty;
  }
  const platformFee = Math.round((subtotal * bps) / 10000);
  const total = subtotal + platformFee;

  if (clientTotal != null && clientTotal !== total) {
    throw new HttpsError(
      'invalid-argument',
      'Price mismatch: totals must be computed server-side.',
    );
  }

  // Slot conflict: any active booking for this provider within ±2h.
  const windowMs = 2 * 60 * 60 * 1000;
  const conflict = await db
    .collection('bookings')
    .where('providerId', '==', providerId)
    .where('status', 'in', ACTIVE_STATUSES)
    .where('scheduledAt', '>=', scheduledAt - windowMs)
    .where('scheduledAt', '<=', scheduledAt + windowMs)
    .limit(1)
    .get();
  if (!conflict.empty) {
    throw new HttpsError(
      'failed-precondition',
      'This time slot is no longer available. Please pick another.',
    );
  }

  return {
    valid: true,
    providerId,
    items,
    subtotalPaise: subtotal,
    platformFeePaise: platformFee,
    totalPaise: total,
    commissionBps: bps,
    scheduledAt,
    addressSnapshot,
  };
});

// ---------------------------------------------------------------------------
// transitionBooking — customer|provider
// ---------------------------------------------------------------------------
/**
 * Enforces the booking status machine server-side, verifies the actor owns
 * the booking side, checks the arrival code for arrived->inProgress, and
 * writes a bookingEvents audit entry. Firestore rules deny direct status
 * writes, so all transitions MUST go through this function.
 */
exports.transitionBooking = onCall(async (request) => {
  const uid = requireUid(request);
  const data = request.data || {};
  const {booking, side} = await loadBookingForCaller(data.bookingId, uid);
  const to = asNonEmptyString(data.to, 'to', 50);

  const from = booking.status;
  const allowed = TRANSITIONS[from] || {};
  const who = allowed[to];
  if (!who) {
    throw new HttpsError(
      'failed-precondition',
      `Cannot move booking from ${from} to ${to}.`,
    );
  }
  if (who !== 'either' && who !== side) {
    throw new HttpsError(
      'permission-denied',
      `Only the ${who} can move a booking from ${from} to ${to}.`,
    );
  }

  // arrived -> inProgress requires the customer-shared arrival code.
  if (from === 'arrived' && to === 'inProgress') {
    const code = asNonEmptyString(data.arrivalCode, 'arrivalCode', 10);
    if (!/^\d{4}$/.test(code)) {
      throw new HttpsError('invalid-argument', 'Arrival code must be 4 digits.');
    }
    if (!booking.arrivalCodeHash) {
      throw new HttpsError('failed-precondition', 'No arrival code was generated for this booking.');
    }
    const hash = createHash('sha256').update(code).digest('hex');
    if (hash !== booking.arrivalCodeHash) {
      throw new HttpsError('permission-denied', 'Wrong arrival code.');
    }
  }

  const update = {status: to, updatedAt: nowMs()};
  if (to === 'cancelled') {
    update.cancelReason = data.reason
      ? asNonEmptyString(data.reason, 'reason', 500)
      : `${side} cancelled`;
  }

  await db.collection('bookings').doc(booking.id).update(update);
  await addBookingEvent(booking.id, `status:${from}->${to}`, {
    actorRole: side,
    actorId: uid,
    note: update.cancelReason || null,
  });
  logger.info('booking transition', {bookingId: booking.id, from, to, side, uid});
  return {ok: true, from, to};
});

// ---------------------------------------------------------------------------
// generateArrivalCode — provider
// ---------------------------------------------------------------------------
/**
 * Creates a 4-digit arrival code for a booking. Only the sha256 hash is
 * stored (booking.arrivalCodeHash); the plain code is returned ONCE to the
 * provider, who shares it with the customer at the door.
 */
exports.generateArrivalCode = onCall(async (request) => {
  const uid = requireUid(request);
  const data = request.data || {};
  const {booking, side} = await loadBookingForCaller(data.bookingId, uid);
  if (side !== 'provider') {
    throw new HttpsError('permission-denied', 'Only the provider can generate the arrival code.');
  }
  if (!['confirmed', 'enRoute', 'arrived'].includes(booking.status)) {
    throw new HttpsError(
      'failed-precondition',
      'Arrival codes can only be generated for confirmed/upcoming bookings.',
    );
  }
  const code = String(randomInt(1000, 10000)); // 1000..9999
  const hash = createHash('sha256').update(code).digest('hex');
  await db.collection('bookings').doc(booking.id).update({
    arrivalCodeHash: hash,
    updatedAt: nowMs(),
  });
  await addBookingEvent(booking.id, 'arrivalCode:generated', {
    actorRole: 'provider',
    actorId: uid,
  });
  return {code}; // shown once to the provider
});

// ---------------------------------------------------------------------------
// submitReview — customer
// ---------------------------------------------------------------------------
/**
 * One review per completed booking. Caller must be the booking's customer,
 * the booking must be completed, and no review may exist yet for it.
 */
exports.submitReview = onCall(async (request) => {
  const uid = requireUid(request);
  const data = request.data || {};
  const {booking, side} = await loadBookingForCaller(data.bookingId, uid);
  if (side !== 'customer') {
    throw new HttpsError('permission-denied', 'Only the customer can review.');
  }
  if (booking.status !== 'completed') {
    throw new HttpsError('failed-precondition', 'Only completed bookings can be reviewed.');
  }
  const rating = Number(data.rating);
  if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
    throw new HttpsError('invalid-argument', 'Rating must be an integer 1–5.');
  }
  const text =
    typeof data.text === 'string' ? data.text.trim().slice(0, 2000) : '';

  const existing = await db
    .collection('reviews')
    .where('bookingId', '==', booking.id)
    .limit(1)
    .get();
  if (!existing.empty) {
    throw new HttpsError('already-exists', 'This booking already has a review.');
  }

  const ref = await db.collection('reviews').add({
    bookingId: booking.id,
    providerId: booking.providerId,
    customerId: booking.customerId,
    customerName: data.customerName
      ? asNonEmptyString(data.customerName, 'customerName', 120)
      : 'Customer',
    rating,
    text,
    hidden: false,
    createdAt: nowMs(),
  });

  // Update provider aggregates transactionally.
  await db.runTransaction(async (tx) => {
    const pRef = db.collection('providers').doc(booking.providerId);
    const pSnap = await tx.get(pRef);
    if (!pSnap.exists) return;
    const p = pSnap.data();
    const count = (p.ratingCount || 0) + 1;
    const avg = ((p.ratingAvg || 0) * (p.ratingCount || 0) + rating) / count;
    tx.update(pRef, {ratingAvg: avg, ratingCount: count});
  });

  await addBookingEvent(booking.id, 'review:submitted', {
    actorRole: 'customer',
    actorId: uid,
    note: `rating ${rating}`,
  });
  return {ok: true, reviewId: ref.id};
});

// ---------------------------------------------------------------------------
// onBookingWrite — status change notifications
// ---------------------------------------------------------------------------
/**
 * On any booking write where the status changed, fan out notification docs
 * for the customer and the provider. Deduped: we record
 * `notification:<status>` in bookingEvents and skip if it already exists.
 * (Push delivery via FCM tokens is a follow-up; see README.)
 */
exports.onBookingWrite = onDocumentWritten('bookings/{bookingId}', async (event) => {
  const after = event.data && event.data.after;
  if (!after || !after.exists) return; // deleted — nothing to notify
  const booking = {id: after.id, ...after.data()};
  const before = event.data.before && event.data.before.exists
    ? event.data.before.data()
    : null;
  if (before && before.status === booking.status) return; // no status change

  const dedupeKey = `notification:${booking.status}`;
  const existing = await after.ref
    .collection('bookingEvents')
    .where('type', '==', dedupeKey)
    .limit(1)
    .get();
  if (!existing.empty) return; // already notified for this transition

  const titles = {
    accepted: ['Booking accepted', `${booking.providerName} accepted your booking.`],
    rejected: ['Booking declined', `${booking.providerName} could not take this booking.`],
    confirmed: ['Booking confirmed', 'Your booking is confirmed.'],
    enRoute: ['Provider on the way', `${booking.providerName} is on the way.`],
    arrived: ['Provider arrived', `${booking.providerName} has arrived.`],
    inProgress: ['Service started', 'Your service is now in progress.'],
    completed: ['Service completed', 'Your service is complete. Please leave a review.'],
    cancelled: ['Booking cancelled', 'A booking was cancelled.'],
    disputed: ['Booking disputed', 'A booking was marked as disputed.'],
  };
  const [title, body] = titles[booking.status] || ['Booking update', 'Your booking was updated.'];

  const batch = db.batch();
  for (const userId of [booking.customerId, booking.providerId]) {
    if (!userId) continue;
    batch.set(db.collection('notifications').doc(), {
      userId,
      kind: 'booking',
      title,
      body,
      data: {bookingId: booking.id, status: booking.status},
      read: false,
      createdAt: nowMs(),
    });
  }
  // Dedupe marker (doubles as part of the audit trail).
  batch.set(after.ref.collection('bookingEvents').doc(), {
    bookingId: booking.id,
    type: dedupeKey,
    actorRole: null,
    actorId: null,
    note: 'status notification fanned out',
    createdAt: nowMs(),
  });
  await batch.commit();
  logger.info('booking notifications fanned out', {bookingId: booking.id, status: booking.status});
});

// ---------------------------------------------------------------------------
// setAdminClaim — admin only
// ---------------------------------------------------------------------------
/**
 * Grants the `admin: true` custom claim to a target user. ONLY callable by an
 * existing admin (checked against the CALLER's custom claim, never a
 * Firestore field) — this prevents privilege escalation.
 *
 * Bootstrap: the very first admin cannot be created this way; use the
 * Admin SDK snippet in FIREBASE_SETUP.md once, then manage admins here.
 */
exports.setAdminClaim = onCall(async (request) => {
  const adminUid = requireAdmin(request);
  const data = request.data || {};
  const targetUid = asNonEmptyString(data.uid, 'uid', 128);
  const grant = data.grant !== false; // default true; pass grant:false to revoke

  const target = await admin.auth().getUser(targetUid).catch(() => null);
  if (!target) {
    throw new HttpsError('not-found', 'Target user not found.');
  }
  await admin.auth().setCustomUserClaims(targetUid, {admin: grant});

  await db.collection('adminAuditLogs').add({
    adminId: adminUid,
    action: grant ? 'admin.granted' : 'admin.revoked',
    targetType: 'user',
    targetId: targetUid,
    details: grant ? 'admin claim granted' : 'admin claim revoked',
    createdAt: nowMs(),
  });
  logger.info('admin claim updated', {by: adminUid, target: targetUid, grant});
  return {ok: true, uid: targetUid, admin: grant};
});

// ---------------------------------------------------------------------------
// askAssistant — Gemini online mode for the AI assistant
// ---------------------------------------------------------------------------

/**
 * Online AI mode. The Gemini API key comes ONLY from the `GEMINI_API_KEY`
 * secret (set with `firebase functions:secrets:set GEMINI_API_KEY`) —
 * it is never embedded in the client and never echoed back.
 *
 * Guardrails:
 *  - per-user rate limit (20 questions/day) via a transaction;
 *  - system prompt forbids inventing prices, ratings, availability or
 *    reviews, and forbids performing booking/payment actions;
 *  - when the key is not set, throws `failed-precondition` so the client
 *    honestly falls back to the rule-based offline mode instead of
 *    faking a "Powered by Gemini" label.
 *
 * NOTE: this stub passes the user's question through with guardrails.
 * A production hardening would inject server-side Firestore context
 * (provider summaries the caller is allowed to see) into the prompt
 * instead of trusting any client-supplied context.
 */
exports.askAssistant = onCall(async (request) => {
  const uid = requireUid(request);
  const data = request.data || {};
  const question = asNonEmptyString(data.question, 'question', 2000).trim();
  const locale = data.locale === 'hi' ? 'hi' : 'en';

  // Rate limit: 20 questions per user per day.
  const rlRef = db.collection('assistantRateLimits').doc(uid);
  const today = new Date().toISOString().slice(0, 10); // YYYY-MM-DD (UTC)
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(rlRef);
    const d = snap.exists ? snap.data() : {};
    const count = d.day === today ? (d.count || 0) : 0;
    if (count >= 20) {
      throw new HttpsError(
        'resource-exhausted',
        'Daily AI question limit reached. Try again tomorrow.',
      );
    }
    tx.set(rlRef, {day: today, count: count + 1}, {merge: true});
  });

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    // Honest signal: the client shows the rule-based offline mode.
    throw new HttpsError(
      'failed-precondition',
      'AI online mode is not configured yet.',
    );
  }

  const systemPrompt = [
    'You are the FixinDays customer support assistant.',
    'RULES (never break them):',
    '1. Answer ONLY from information the user can verify in the app.',
    '2. NEVER invent provider prices, ratings, review counts, availability, or service areas.',
    '3. If you do not know something, say so honestly instead of guessing.',
    '4. NEVER perform bookings, payments, cancellations or account changes —',
    '   direct the user to the relevant screen in the app instead.',
    '5. Keep answers short and in the user\'s language.',
  ].join('\n');

  let resp;
  try {
    resp = await fetch(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: JSON.stringify({
          systemInstruction: {parts: [{text: systemPrompt}]},
          contents: [{parts: [{text: `[locale=${locale}] ${question}`}]}],
          generationConfig: {maxOutputTokens: 400, temperature: 0.3},
        }),
      },
    );
  } catch (e) {
    logger.warn('askAssistant: Gemini request failed', {uid, err: String(e)});
    throw new HttpsError('unavailable', 'AI service is temporarily down.');
  }
  if (!resp.ok) {
    logger.warn('askAssistant: Gemini HTTP error', {uid, status: resp.status});
    throw new HttpsError('unavailable', 'AI service is temporarily down.');
  }
  const body = await resp.json();
  const text =
    body?.candidates?.[0]?.content?.parts
      ?.map((p) => p.text || '')
      .join('')
      .trim() || '';
  if (!text) {
    throw new HttpsError('internal', 'AI returned an empty answer.');
  }
  return {reply: text.slice(0, 2000), mode: 'gemini'};
});
