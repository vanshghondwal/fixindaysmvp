/// Runtime configuration for FixinDays apps.
///
/// Demo mode is ON until Firebase is configured. In demo mode the apps use
/// [DemoRepository] with clearly labelled seed data and show a "Demo mode"
/// banner. Nothing in demo mode is presented as real user/provider data.
class AppConfig {
  /// Set to false after `flutterfire configure` + enabling backend products.
  static bool useDemoData = true;

  /// Shown in the demo banner and README so demo data is never mistaken
  /// for real marketplace data.
  static const String demoNotice =
      'Demo mode — sample data shown. Connect Firebase for live data.';
}
