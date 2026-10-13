# FIREBASE_SETUP.md — FixinDays backend setup

Exact steps to take the FixinDays monorepo from demo mode to a live Firebase
backend. **No keys, IDs, or secrets are invented here** — everywhere a value
is needed you must paste your own, marked `YOUR_...` below.

Prerequisites: a Google account, Node 20+, Flutter stable, and the Firebase CLI
(`npm i -g firebase-tools`, then `firebase login`).

---

## 1. Create the Firebase project

1. Go to <https://console.firebase.google.com> → **Add project**.
2. Name it (e.g. `fixindays-prod`). Google Analytics is optional.
3. **Billing:** the free **Spark** plan covers Auth, Firestore, Storage, and
   Hosting. **Cloud Functions require the Blaze (pay-as-you-go) plan** —
   enable it under *Build → Functions* or *Usage and billing* before step 6.

## 2. Register the Flutter apps (`flutterfire configure`)

Run once **per app** from the repo root. This generates each app's
`lib/firebase_options.dart` (replacing the stub that currently forces demo mode).

```bash
cd apps/customer && flutterfire configure   # select your project, platforms android+web
cd ../partner  && flutterfire configure
cd ../admin    && flutterfire configure      # web at minimum
cd ../..
```

After this, set `AppConfig.useDemoData = false` (or wire it to a build flag)
— until then the apps keep showing the demo banner.

## 3. Authentication providers

In console → **Build → Authentication → Sign-in method**, enable:

- **Phone** — add your test numbers under *Phone numbers for testing*
  (e.g. `+91 98765 43210` → code `123456`) so you can demo without real SMS.
- **Email/Password** — used by the admin console sign-in.

## 4. Firestore — create + deploy rules and indexes

```bash
# In console: Build → Firestore Database → Create database (production mode, region asia-south1 recommended for India)
firebase deploy --only firestore
```

This deploys `firestore.rules` (no public read/write; admin checks use
**only** the `request.auth.token.admin == true` custom claim — never a
Firestore field) and `firestore.indexes.json`.

## 5. Storage — deploy rules

```bash
firebase deploy --only storage
```

Deploys `storage.rules`: user files are owner-only,
`verification-docs/{providerId}/` is **write-owner / read-admin-only**
(this is what the admin console's application review reads).

## 6. Cloud Functions — install + deploy (needs Blaze)

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

Verify in console → **Build → Functions**: `validateBooking`,
`transitionBooking`, `generateArrivalCode`, `submitReview`,
`onBookingWrite`, `setAdminClaim` should all be listed.

Local emulator (optional):

```bash
firebase emulators:start --only auth,firestore,functions,storage
# Emulator UI: http://localhost:4000
```

## 7. First admin — grant the `admin:true` custom claim

The `setAdminClaim` function can only be called by an *existing* admin, so
the very first admin is bootstrapped once with the Admin SDK. Run this with
Node (service-account key from *Project settings → Service accounts* —
**keep the key file out of git**):

```js
// bootstrap-admin.js — run ONCE, then delete the key file
const admin = require('firebase-admin');
admin.initializeApp({
  credential: admin.credential.cert(require('./serviceAccountKey.json')),
});
async function main(uid) {
  await admin.auth().setCustomUserClaims(uid, { admin: true });
  console.log('admin claim granted to', uid);
}
main('PASTE_THE_USERS_UID_HERE');
```

```bash
cd functions && npm install firebase-admin   # if needed
node bootstrap-admin.js
```

Get the UID from *Authentication → Users* (create the admin's account via
email sign-up first). After signing in again, the admin console will
recognize the claim. From then on, grant/revoke admins via `setAdminClaim`.

## 8. FCM push notifications

- **Android:** download `google-services.json` (*Project settings → Your apps*)
  into `apps/customer/android/app/` and `apps/partner/android/app/`.
- **Web:** add the Firebase web config to each app's `web/index.html` /
  `firebase-messaging-sw.js` (values come from `flutterfire configure`).
- **iOS (if added later):** APNs key in *Project settings → Cloud Messaging*.
- The `onBookingWrite` trigger already writes `notifications` docs; sending
  them as pushes needs the apps to call `saveFcmToken()` and a send step in
  the function (marked TODO in `functions/README.md`).

## 9. App Check (recommended before launch)

*Build → App Check*: enable **Play Integrity** (Android) and **App Attest**
or **DeviceCheck** (Apple), plus **reCAPTCHA v3** for web. Then enforce it on
Firestore/Functions in the console.

## 10. Razorpay (payments)

**You must create these in the Razorpay dashboard — nothing is committed.**

1. Get `key_id` and `key_secret` from <https://dashboard.razorpay.com>.
2. Store the secret in Functions config (never in the app or git):

```bash
firebase functions:secrets:set RAZORPAY_KEY_ID
firebase functions:secrets:set RAZORPAY_KEY_SECRET
```

3. Put the **public** `key_id` (`YOUR_RAZORPAY_KEY_ID`) in the customer app's
   payment code only — never the secret.
4. Payment capture/verification callables still need to be written against
   these secrets (see `functions/README.md` TODO).

## 11. Google Maps API key

**Create it yourself** at <https://console.cloud.google.com> → *APIs &
Services → Credentials* (restrict it: Android apps by package name/SHA-1,
HTTP referrers for web).

- **Android:** `apps/customer/android/app/src/main/AndroidManifest.xml`
  (and partner):
  ```xml
  <meta-data android:name="com.google.android.geo.API_KEY"
             android:value="YOUR_MAPS_API_KEY"/>
  ```
- **Web:** in `web/index.html`:
  ```html
  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_MAPS_API_KEY"></script>
  ```
- Enable the **Maps SDK for Android**, **Maps JavaScript API**, and
  **Places API** for the key's project.

## 12. Gemini (AI features)

Server-side secret **only** — never ship it in any app binary:

```bash
firebase functions:secrets:set GEMINI_API_KEY
```

Read it in functions via `process.env.GEMINI_API_KEY`.

---

## What remains manual (checklist)

- [ ] `flutterfire configure` run for customer, partner, admin
- [ ] Auth providers enabled (Phone + test numbers, Email/Password)
- [ ] `firebase deploy --only firestore` (rules + indexes)
- [ ] `firebase deploy --only storage`
- [ ] Blaze plan enabled; `firebase deploy --only functions`
- [ ] First admin claim bootstrapped via the Node snippet
- [ ] `google-services.json` placed for customer + partner Android apps
- [ ] Razorpay `key_id`/`key_secret` created; secrets set; **not committed**
- [ ] Google Maps API key created, restricted, and placed (manifest + index.html)
- [ ] Gemini API key stored as a Functions secret (if AI features are built)
- [ ] App Check enforced before public launch
- [ ] `AppConfig.useDemoData = false` once the backend is live

## Useful commands

```bash
firebase deploy --only firestore          # rules + indexes
firebase deploy --only storage
firebase deploy --only functions
firebase deploy --only functions:transitionBooking   # single function
firebase emulators:start --only auth,firestore,functions,storage
```
