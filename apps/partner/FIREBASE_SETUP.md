# Firebase setup — FixinDays Partner

Follow these steps to take the partner app from demo mode to live Firebase.

## 1. Create the Firebase project

1. Go to the [Firebase console](https://console.firebase.google.com/) and
   create a project (e.g. `fixindays`).
2. Enable **Authentication** → sign-in methods: **Phone** and
   **Email/Password**.
3. Enable **Cloud Firestore** (production mode).
4. Enable **Cloud Storage**.
5. Enable **Cloud Messaging** (for push notifications).

## 2. Generate platform folders

```bash
cd apps/partner
flutter create --platforms=android,ios,web .
```

Android application id: **`com.fixindays.partner`**
(iOS bundle id: `com.fixindays.partner`).

## 3. Configure FlutterFire

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-project-id>
```

This generates `lib/firebase_options.dart`. Then in `lib/main.dart`,
pass the options:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## 4. Flip off demo mode

In `packages/core/lib/src/config.dart`:

```dart
static bool useDemoData = false;
```

## 5. Wire the real repositories

`PartnerState` currently builds demo repositories. Replace them with the
Firestore implementations (auth/catalog/bookings exist in core;
provider-ops/support/notifications Firestore adapters still need to be
written — see the repository interfaces in
`packages/core/lib/src/repositories.dart`).

## 6. Firestore rules (starter sketch)

- `providers/{uid}`: read by anyone, write by the owning provider.
- `bookings/{id}`: read/write by the customer and provider on the booking.
- `applications/{id}`: write by the owning provider, read by admins
  (custom claim `admin: true`).
- Never store plain arrival codes — only `arrivalCodeHash` (sha256).

## 7. Storage

Verification documents go to a **private** bucket path such as
`verifications/{providerId}/{docType}` with rules restricting reads to
admins and the owning provider.
