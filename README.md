# FixinDays 🏠🔧
### Same Services. Brighter Days.

Local home services app (Urban Company style) — **InnoHacks 4.0 · Open Innovation track**.
Built by Team FixinDays: **Vansh, Divyansh, Nikhil** (DBRA CM SHRI, Yamuna Vihar, Delhi).

## What's in this demo build

Full working MVP on **mock data** — no backend needed to run:

- **Home** — search bar, 6-tile category grid (Plumber, Electrician, Carpenter,
  Painter, AC Repair, Many More), trust badges (Verified Providers / Transparent
  Pricing / Real Reviews), top-rated providers
- **Providers** — per-category listing with rating ⭐, reviews count, ₹(onwards)
  pricing, verified tick, Book button (deck data: Rajesh Electricals 4.8 ₹299,
  Sharma Home Services 4.5 ₹249, LocalFix Riders 4.7 ₹199)
- **Booking flow** — describe the issue → pick day + time slot → address →
  price summary → Confirm Booking
- **My Bookings** — booking list with status + cancel
- **Profile** — addresses, history, reviews, about

## Run it

Needs Flutter SDK (3.2+) installed:

```bash
cd fixindays
flutter pub get
flutter run            # debug on connected device / emulator
flutter build apk      # release APK for hackathon demo
```

## Connect Firebase (needs Vansh's Google account)

```bash
dart pub global activate flutterfire_cli
flutterfire configure          # generates lib/firebase_options.dart
```

Then in `lib/main.dart` uncomment `FirebaseService.init()`, and swap the
mock source in `MockData` with the `FirebaseService` stubs in
`lib/services/firebase_service.dart`. Firestore collections: `users`,
`providers`, `bookings`, `reviews` (see deck page 5 — Tech Stack).

## Hackathon demo tips

1. Open Home → tap **Electrician** → shows the exact deck rows (Rajesh
   Electricals 4.8 ⭐ ₹299 onwards + Book)
2. Book → pick "Today" slot → Confirm → switch to **Bookings** tab
3. Talking points from the deck: transparent pricing, verified providers,
   real reviews, single codebase Flutter + Firebase, scalable architecture

## Status

- [x] Full mock-data MVP (this folder)
- [ ] Firebase connect (needs user's Google account)
- [ ] Release APK build (needs Flutter + Android SDK on a build machine)
