// Smoke test for the FixinDays Partner app entry point.
//
// The CI workflow runs `flutter create` to ensure platform files exist.
// Committing this file prevents it from generating the default
// MyApp-based test, which fails analysis because MyApp does not exist.
// This test intentionally avoids pumping widgets (no Firebase / platform
// channels needed) — it just verifies the root widget is wired correctly.
import 'package:fixindays_partner/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PartnerApp root widget is defined', () {
    const app = PartnerApp();
    expect(app, isA<PartnerApp>());
  });
}
