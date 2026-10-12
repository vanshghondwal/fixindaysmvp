/// Language selection (English / हिन्दी).
///
/// Used on first run and from Settings. The choice is in-memory for now;
/// TODO(firebase): persist to the user document / device storage.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'onboarding_screen.dart';
import 'root_shell.dart';
import 'welcome_screen.dart';

class LanguageScreen extends StatelessWidget {
  /// When opened from Settings, just pop back after choosing.
  final bool fromSettings;

  const LanguageScreen({super.key, this.fromSettings = false});

  void _choose(BuildContext context, String code) {
    final app = context.read<AppState>();
    app.setLocale(Locale(code));
    app.completeLanguage();
    if (fromSettings) {
      Navigator.of(context).pop();
      return;
    }
    final Widget next;
    if (!app.onboardingSeen) {
      next = const OnboardingScreen();
    } else if (app.user == null) {
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
    final current = context.watch<AppState>().locale.languageCode;
    return Scaffold(
      appBar: fromSettings
          ? AppBar(title: Text(FxLocalizations.of(context).t('language')))
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FxSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!fromSettings) ...[
                const SizedBox(height: 32),
                Text('Choose your language', style: FxText.headline),
                const SizedBox(height: 4),
                Text(
                  'अपनी भाषा चुनें',
                  style: FxText.body.copyWith(color: FxColors.secondaryText),
                ),
                const SizedBox(height: 24),
              ],
              _langTile(context,
                  code: 'en',
                  label: 'English',
                  native: 'English',
                  selected: current == 'en'),
              const SizedBox(height: 12),
              _langTile(context,
                  code: 'hi',
                  label: 'Hindi',
                  native: 'हिन्दी',
                  selected: current == 'hi'),
              const Spacer(),
              if (!fromSettings)
                Text(
                  'You can change this later from Profile → Settings.',
                  style: FxText.caption,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langTile(
    BuildContext context, {
    required String code,
    required String label,
    required String native,
    required bool selected,
  }) {
    return FxCard(
      onTap: () => _choose(context, code),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: FxText.title),
                Text(native, style: FxText.caption),
              ],
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle, color: FxColors.primary),
        ],
      ),
    );
  }
}
