# FixinDays 🏠🔧
### Same Services. Brighter Days. / Local Help. Brighter Days.

Local home-services marketplace (Urban Company style) — **InnoHacks 4.0 · Open Innovation track**.
Team FixinDays: **Vansh, Divyansh, Nikhil** (DBRA CM SHRI, Yamuna Vihar, Delhi).

## Monorepo layout

| Path | What it is |
|---|---|
| `apps/customer/` | FixinDays Customer app (Flutter, Android + Web) |
| `apps/partner/` | FixinDays Partner app for providers (Flutter, Android + Web) |
| `apps/admin/` | Admin panel (Flutter Web) — verification, moderation, disputes, settings |
| `packages/core/` | Shared theme, models, repositories, widgets, l10n (en/hi), business logic |
| `functions/` | Node.js Cloud Functions — booking validation, status guards, arrival codes, reviews |
| `firestore.rules` / `firestore.indexes.json` / `storage.rules` | Backend security + indexes |
| `.github/workflows/` | CI: Android APK builds + web builds + core tests |
| `lib/` (repo root) | Legacy single-app MVP (kept for history; superseded by `apps/`) |

## Demo mode (important)

Until Firebase is configured, all three apps run on **clearly labelled demo
seed data** with a "Demo mode" banner in the UI. Demo data is never presented
as real marketplace data. See `FIREBASE_SETUP.md` for going live.

## Quick start (per app)

```bash
cd apps/customer            # or apps/partner, apps/admin
flutter create --platforms=android,ios,web .   # generates platform folders
flutter pub get
flutter run                 # demo mode, no backend needed
```

APKs are built automatically by GitHub Actions on every push to `main`
(see the **Actions** tab → Artifacts): `fixindays-customer-apk`,
`fixindays-partner-apk`. Web builds: customer + admin.

## Going live

1. Read `FIREBASE_SETUP.md` — exact steps for Firebase project, Auth,
   Firestore, Storage, Functions, FCM, App Check.
2. Set `AppConfig.useDemoData = false` (in `packages/core/lib/src/config.dart`)
   once the backend is configured.
3. Credentials you must provide (never committed): Firebase project,
   Razorpay key id/secret, Google Maps API key, Gemini server key.
   See `FIREBASE_SETUP.md` for where each goes.

## Honest status

`STATUS_REPORT.md` lists every screen, what is demo vs real, what was
tested, and what still needs credentials or manual steps.
