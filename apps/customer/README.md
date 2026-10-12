# FixinDays — Customer App

Flutter customer app for the FixinDays local home-services marketplace
(Urban Company style). Built for **InnoHacks 4.0 · Open Innovation**.

- Package: `fixindays_customer` · v1.0.0+1
- Android + Web (iOS folder can be generated too)
- Shared design system, models, repos and logic: `packages/core`
  (`package:fixindays_core/fixindays_core.dart`)
- State: `provider` (`AppState` + `CartState`)

## Project structure

```
apps/customer/
├── pubspec.yaml
├── README.md
└── lib/
    ├── main.dart                 # Firebase best-effort init, providers, MaterialApp
    └── src/
        ├── state/
        │   └── app_state.dart    # AppState (repos, user, locale, cart) + BookingDraft
        └── screens/
            ├── splash_screen.dart
            ├── language_screen.dart      # en / hi
            ├── onboarding_screen.dart
            ├── welcome_screen.dart
            ├── auth/
            │   ├── auth_flow.dart        # shared post-auth routing
            │   ├── phone_auth_screen.dart
            │   └── email_auth_screen.dart
            ├── profile_setup_screen.dart
            ├── location_screen.dart
            ├── address_form_screen.dart  # shared add/edit form
            ├── root_shell.dart           # bottom nav: Home / Bookings / Profile
            ├── home_screen.dart
            ├── search_screen.dart
            ├── categories_screen.dart
            ├── category_detail_screen.dart
            ├── provider_list_screen.dart
            ├── provider_profile_screen.dart
            ├── reviews_screen.dart
            ├── cart_screen.dart
            ├── address_select_screen.dart
            ├── schedule_screen.dart
            ├── booking_review_screen.dart
            ├── payment_screen.dart
            ├── booking_confirmation_screen.dart
            ├── booking_detail_screen.dart
            ├── bookings_screen.dart
            ├── notifications_screen.dart
            ├── addresses_screen.dart
            ├── profile_screen.dart
            ├── edit_profile_screen.dart
            ├── help_screen.dart
            ├── dispute_screen.dart
            └── settings_screen.dart
```

Navigation is plain `Navigator` push/pop (no router dependency).

## Demo mode (important)

Until Firebase is configured, the app runs on **clearly labelled demo seed
data** (`DemoRepositories` in `packages/core`) with a "Demo mode" banner on
every screen. Demo data is never presented as real marketplace data.

- Phone OTP: **any 6-digit OTP works** (labelled in the UI).
- Online payment is **not faked** — only "Cash on service" is offered, and
  the payment screen says exactly why online payment is unavailable.
- GPS "current location" shows an honest dialog pointing at
  `FIREBASE_SETUP.md` instead of pretending to work.
- Distances aren't shown — same reason.
- Language choice and notification prefs are in-memory (`TODO(firebase)`).

## Run / build

```bash
cd apps/customer
flutter create --platforms=android,ios,web .   # generates platform folders
# then set applicationId "com.fixindays.customer" in android/app/build.gradle
flutter pub get
flutter run                 # demo mode, no backend needed
```

APKs are built by GitHub Actions CI on every push to `main`
(artifact: `fixindays-customer-apk`); CI runs `flutter create` before the
build, so `android/` and `ios/` are intentionally not committed.

## Going live

1. Read `FIREBASE_SETUP.md` at the repo root (Firebase project, Auth,
   Firestore, Storage, Functions, FCM).
2. Credentials you must provide (never committed): Firebase project config,
   Razorpay key id/secret (for online payment), Google Maps API key (for
   live location + distances).
3. Set `AppConfig.useDemoData = false` in
   `packages/core/lib/src/config.dart` once the backend is configured.

## What's demo vs real

| Area | Status |
|---|---|
| Auth (phone OTP, email) | Demo repo (any 6-digit OTP) → swap to Firebase Auth |
| Categories / providers / services | Demo seed data → Firestore |
| Bookings (create, cancel, reschedule) | Demo repo, real flow + guards (`canTransition`) |
| Reviews | Demo repo, eligibility enforced (`isReviewEligible`) |
| Addresses | Demo repo, full CRUD |
| Support tickets | Demo repo, full create flow |
| Notifications | Demo repo (empty stream) → FCM |
| Online payment | Not built — needs Razorpay credentials |
| GPS location / distances | Not built — needs Maps API key |
| Totals, status guards, validators, formatting | Real shared logic in `packages/core` |
