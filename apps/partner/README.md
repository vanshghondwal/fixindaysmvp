# FixinDays Partner

The provider-side Flutter app for FixinDays — booking requests, service
catalogue, availability, earnings, reviews and verification.

## Status: demo mode

`AppConfig.useDemoData` is `true`. The app runs on in-memory demo
repositories (`lib/src/data/demo_provider_ops.dart`) and shows a
**Demo mode** banner on every screen. Nothing shown is real marketplace
data.

Demo highlights:

- Sign in with **any 6-digit OTP** (phone tab) or any email/password —
  the account is always created with the **provider** role.
- Seeded data: 2 incoming requests, 2 upcoming confirmed bookings,
  1 en-route job, 3 history bookings, 4 services, 3 reviews.
- The en-route demo job's arrival code is `4821` (kept only in the demo
  data file; real models carry only a hash). Enter it on the
  *Verify arrival code* screen to start the job.
- Verification: document uploads are **disabled in demo** (Firebase
  Storage is not connected). Submit the application with the declaration
  checkbox, then use **Simulate admin approval (demo only)** on the
  status screen to unlock the dashboard.
- Availability is stored **on device** in demo mode; it syncs to
  Firestore after Firebase is connected.
- Earnings are computed from completed demo bookings. Settlements are
  pending — payouts need payment gateway configuration. No fake settled
  payouts are ever shown.

## Structure

```
lib/
  main.dart                      # Firebase init (try/catch) + MultiProvider + MaterialApp
  src/
    data/
      demo_provider_ops.dart     # PartnerDemoAuthRepository, DemoProviderOpsRepository,
                                 # PartnerDemoNotificationRepository (all labelled demo)
      delhi_localities.dart      # Service-area chip list (demo)
    state/
      partner_state.dart         # ChangeNotifier: user, profile, application,
                                 # locale, availability, auth actions
    screens/                     # 23 screens (see below) + partner_gate.dart + home_shell.dart
    widgets/
      booking_card.dart          # BookingCard, BookingTotals, formatSlot/formatDay
```

Screens: splash, welcome, auth (phone OTP + email), profile setup,
verification apply, verification status (gate), home shell (bottom nav:
Dashboard, Requests, Services, Earnings, Profile), dashboard, requests,
request detail, upcoming, active service, arrival verify, history,
catalogue, service edit, availability, areas, earnings, reviews,
notifications, profile, support, settings.

Every screen implements loading (`FxLoadingList`), empty (`EmptyState`)
and error (`ErrorPanel` + retry) states.

## Verification flow

1. New partner signs in → `ProfileSetupScreen` (business details).
2. `VerificationApplyScreen` — upload buttons disabled in demo with an
   honest note; submit with the declaration checkbox.
3. `VerificationStatusScreen` — shows the real application status and any
   admin note. The dashboard is **blocked** until status is `approved`.
4. Demo shortcut: *Simulate admin approval (demo only)*.

## Run

```bash
cd apps/partner
flutter pub get
flutter run
```

## Platforms

`android/` and `ios/` are intentionally omitted. Generate them with:

```bash
cd apps/partner
flutter create --platforms=android,ios,web .
```

Use application id **`com.fixindays.partner`**. Then follow
[FIREBASE_SETUP.md](FIREBASE_SETUP.md) and set
`AppConfig.useDemoData = false` in `packages/core/lib/src/config.dart`.
