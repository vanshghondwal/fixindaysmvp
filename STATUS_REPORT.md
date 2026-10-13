# FixinDays — Build Status Report

**Date:** 2026-10-12
**Repo:** `vanshghondwal/fixindaysmvp` (branch `main`)
**Scope:** Full production-oriented marketplace per the master prompt:
Customer app + Partner app + Admin web app + shared Firebase backend.

---

## 1. What was built

### Monorepo structure (new in this build)

| Path | Contents |
|---|---|
| `apps/customer/` | Customer Flutter app — 38 files, 30 screens |
| `apps/partner/` | Partner (provider) Flutter app — 34 files, 23 screens |
| `apps/admin/` | Admin panel (Flutter Web) — 23 files, 11 screens |
| `packages/core/` | Shared package: theme, models, repositories, demo data, Firestore impls, 20+ widgets, en/hi l10n, pure-Dart business logic + unit tests |
| `functions/` | Node.js Cloud Functions (booking validation, status guards, arrival codes, reviews, notifications, admin claims) |
| `firestore.rules`, `firestore.indexes.json`, `storage.rules`, `firebase.json` | Backend security + config |
| `.github/workflows/` | `android.yml`, `web.yml`, `core-test.yml` |
| `FIREBASE_SETUP.md` | 12-step exact setup guide |
| `lib/` (repo root) | Legacy single-app MVP — **kept untouched** for history |

### Customer app screens (all implemented)
Splash → Language (en/hi) → Onboarding → Welcome → Phone OTP auth →
Email auth → Profile setup → Location/address setup → Home (search,
categories, trust badges, top providers, recent bookings) → Search
(debounced, recent searches) → Categories → Category detail →
Provider list (rating filter, price sort) → Provider profile →
Reviews (eligibility-gated) → Cart (multi-service, single-provider guard) →
Address select → Schedule (7 days, slots) → Booking review →
Payment → Confirmation (real booking ID) → Booking detail (timeline,
cancel/reschedule/dispute) → My Bookings (tabs) → Notifications →
Addresses CRUD → Profile → Edit profile → Help/FAQ → Dispute ticket →
Settings (language, sign out, delete account).

### Partner app screens (all implemented)
Splash → Welcome → Auth (provider role) → Business profile setup →
Verification application → Verification status gate → Dashboard (real
computed stats) → Booking requests (accept/reject) → Request detail →
Upcoming → Active service (lifecycle: en route → arrived → code verify →
complete) → Arrival-code verification → Booking history → Service
catalogue → Add/edit service → Availability → Service areas → Earnings
→ Reviews → Notifications → Profile (+ customer preview) → Support →
Settings.

### Admin app screens (all implemented)
Login (custom-claim gate) → Dashboard (real metric cards) → Provider
verification review (approve/reject + notes) → Provider activate/suspend →
Booking search + detail → Support tickets → Review moderation →
User management → Platform settings → Audit log → Announcements.

### Backend
- **Firestore rules:** no public read/write; customers read own docs;
  providers read own; **admin only via `request.auth.token.admin == true`
  custom claims — never a client-editable field** (commented in 3 places).
- **Cloud Functions:** `validateBooking` (re-derives totals from provider
  prices, rejects client-total mismatch, slot-conflict check),
  `transitionBooking` (server-side status matrix + sha256 arrival-code
  check), `generateArrivalCode`, `submitReview` (eligibility checks),
  `onBookingWrite` (notification fan-out), `setAdminClaim`
  (caller-must-be-admin).
- **Storage rules:** user docs owner-only; verification docs
  write-owner/read-admin-only; evidence uploads 10MB image-only.

---

## 2. Demo vs Real — read this before the hackathon

All three apps boot in **demo mode** (`AppConfig.useDemoData = true`) with a
visible "Demo mode" banner. Demo data is sample data and is never presented
as real.

| Feature | Demo (works now) | Real (needs credentials/config) |
|---|---|---|
| Auth (phone OTP / email) | Flow works; any 6-digit OTP accepted, clearly labelled | Firebase Auth: enable Phone + Email providers |
| Provider catalogue | Labelled seed providers (deck data) | Firestore `providers` + `providerServices` |
| Booking create/cancel/reschedule | In-memory, status guards enforced | Firestore + `validateBooking`/`transitionBooking` functions |
| Reviews | Eligibility logic real; seed list empty | Firestore `reviews` |
| Payments | **Cash on Service only.** Online payment screen honestly says "not configured" — never fakes success | Razorpay key id/secret (user must provide) |
| Maps / distance / GPS | Honestly disabled; "needs Maps API key" | Google Maps API key (user must provide) |
| Photo evidence upload | Honestly disabled | Firebase Storage (enable in console) |
| Push notifications | In-app list only | FCM config + `google-services.json` |
| Gemini AI assistant | Not built (stub + docs only) | Server-side API key (user must provide) |
| Admin login | Demo admin (`admin@fixindays.demo`) | Real admin via custom claim bootstrap (see FIREBASE_SETUP.md step 9) |

---

## 3. What was tested

- **Unit tests** (`packages/core/test/logic_test.dart`, 20 tests):
  totals math, commission, discount floor, status-transition matrix
  (customer/provider/admin), review eligibility, arrival-code matching,
  slot conflicts, INR formatting, validators. **Not run locally** — no
  Dart/Flutter SDK on this machine. CI (`core-test.yml`) runs them on push.
- **Static review:** bracket-balance + import/cross-reference checks on all
  Dart files; core API signatures cross-checked by hand.
- **Not run:** `flutter analyze`, `flutter test`, `flutter build`.
  These run in CI on every push (see below). Expect possible minor fixes
  from the first CI run — Dart was written carefully but not compiled here.

---

## 4. Credentials / manual steps the user must provide

1. **Google account** → create Firebase project, run `flutterfire configure`
   per app (generates `firebase_options.dart`; stubs throw until then).
2. **Firebase console:** enable Auth (Phone, Email), Firestore, Storage;
   deploy rules/indexes/functions (`firebase deploy`).
3. **First admin:** run the Admin SDK custom-claims snippet in
   FIREBASE_SETUP.md step 9.
4. **Razorpay:** key id + secret → Functions config (never in the repo).
5. **Google Maps API key** → Android manifest + web `index.html`.
6. **Gemini:** server-side key only, if the AI assistant is wanted later.
7. **Set `AppConfig.useDemoData = false`** once the backend is live.

Nothing above is faked, stubbed with dummy keys, or hardcoded.

---

## 5. CI behavior (what happens after push)

- **Push to `main`** touching `apps/customer|partner` or `packages/core`
  → `android.yml` builds **release APKs** for customer + partner apps.
- Touching `apps/customer|admin` or `packages/core` → `web.yml` builds web.
- Touching `packages/core` → `core-test.yml` runs unit tests.
- **APKs appear under the repo's Actions tab → workflow run → Artifacts**
  (`fixindays-customer-apk`, `fixindays-partner-apk`). Download from there —
  this is the "download APK from GitHub" flow requested.
- First CI run also runs `flutter analyze`; any compile issues will be
  reported there (code not compiled locally — see §3).

---

## 6. Known gaps / follow-ups

- Booking detail shows created/updated timeline; full per-event history view
  is a follow-up (events are already written by functions).
- Search is prefix-match; Algolia/Typesense flagged for later.
- Announcements are in-app; FCM push send needs wiring (noted in UI+docs).
- `flutter create --platforms=...` runs in CI to generate `android/`/`web/`
  folders — not committed.
- iOS builds not in CI (needs macOS runner).
