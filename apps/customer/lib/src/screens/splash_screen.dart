/// Splash screen: brand mark + tagline, then routes based on auth state.
///
/// No fake delays — it only waits for the first auth event (plus a short
/// beat so the splash actually paints).
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'language_screen.dart';
import 'onboarding_screen.dart';
import 'root_shell.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final app = context.read<AppState>();
    final results = await Future.wait([
      app.repos.auth.authStateChanges().first,
      Future<void>.delayed(const Duration(milliseconds: 500)),
    ]);
    final user = results[0] as AppUser?;
    app.setUser(user);
    if (!mounted) return;

    final Widget next;
    if (!app.languageChosen) {
      next = const LanguageScreen();
    } else if (!app.onboardingSeen) {
      next = const OnboardingScreen();
    } else if (user == null) {
      next = const WelcomeScreen();
    } else {
      next = const RootShell();
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      backgroundColor: FxColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.handyman, size: 72, color: FxColors.white),
            const SizedBox(height: 12),
            Text(
              t.t('appName'),
              style: FxText.headline.copyWith(color: FxColors.white),
            ),
            const SizedBox(height: 6),
            Text(
              t.t('tagline'),
              style: const TextStyle(color: FxColors.white, fontSize: 14),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: FxColors.white),
          ],
        ),
      ),
    );
  }
}
