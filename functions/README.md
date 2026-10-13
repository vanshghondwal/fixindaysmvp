# FixinDays Cloud Functions

Trusted backend for the FixinDays platform (Node 20, firebase-functions v2).
Clients talk to these via HTTPS callable endpoints; Firestore security rules
deny direct status/payment writes, so the real business checks live here and
run under the Admin SDK.

## Functions

| Function | Caller | What it does |
|---|---|---|
| `validateBooking` | customer | Re-derives prices from provider service docs, verifies provider approved+active, checks slot conflicts, rejects client-tampered totals. Returns the totals the client must store. |
| `transitionBooking` | customer/provider | Enforces the booking status matrix server-side, verifies the actor is a party to the booking, checks the arrival code (sha256) for `arrived → inProgress`, writes a `bookingEvents` audit entry. |
| `generateArrivalCode` | provider | Creates a 4-digit code, stores only its sha256 (`arrivalCodeHash`), returns the code once to the provider. |
| `submitReview` | customer | One review per completed booking, rating 1–5; updates provider rating aggregates transactionally. |
| `onBookingWrite` | trigger | On status change of `bookings/{id}`, fans out notification docs to customer + provider (deduped via `notification:<status>` in `bookingEvents`). |
| `setAdminClaim` | admin only | Grants/revokes the `admin:true` custom claim. Callable **only** by an existing admin (checked from the caller's ID token claims, never a Firestore field). |

Status matrix enforced by `transitionBooking`:

```
pending    → accepted / rejected (provider) | cancelled (either)
accepted   → confirmed (provider)           | cancelled (either)
confirmed  → enRoute (provider)              | cancelled (either)
enRoute    → arrived (provider)
arrived    → inProgress (provider, arrival code required)
inProgress → completed (provider)
completed  → disputed (either)
disputed   → cancelled (either, admin-resolved)
```

## Deploy

Needs the **Blaze** plan (Functions require it).

```bash
cd functions
npm install
firebase deploy --only functions
```

For a single function:

```bash
firebase deploy --only functions:validateBooking
```

## Emulator

```bash
firebase emulators:start --only functions,firestore,auth
```

## Secrets

Never commit secrets. Runtime config / Secret Manager keys used later
(Razorpay, Gemini) are set via:

```bash
firebase functions:secrets:set RAZORPAY_KEY_SECRET
```

and read in code with `process.env.RAZORPAY_KEY_SECRET`.

## TODO / follow-ups

- Push delivery: `onBookingWrite` writes notification docs; delivering them
  as FCM pushes needs device tokens (`notifications` repo `saveFcmToken`)
  and a send step in the trigger.
- Razorpay payment capture/verification and refunds: add callables that use
  the Razorpay secret from Secret Manager.
- Rate limiting on `generateArrivalCode` (per booking, it is naturally
  idempotent-ish; add per-IP limits if abused).
