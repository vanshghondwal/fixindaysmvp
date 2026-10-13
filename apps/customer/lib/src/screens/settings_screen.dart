/// Settings: language, notification preference (in-memory), legal
/// placeholders, sign out, delete account.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'language_screen.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final ok = await fxConfirm(
      context,
      title: 'Sign out?',
      message: 'You\'ll need to sign in again to book services.',
      confirmLabel: 'Sign out',
    );
    if (!ok || !context.mounted) return;
    await context.read<AppState>().signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final ok = await fxConfirm(
      context,
      title: 'Delete account?',
      message:
          'This permanently deletes your account and booking history. '
          'This can\'t be undone.',
      confirmLabel: 'Delete my account',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    await context.read<AppState>().deleteAccount();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = FxLocalizations.of(context);
    final langLabel =
        app.locale.languageCode == 'hi' ? 'हिन्दी' : 'English';
    return Scaffold(
      appBar: AppBar(title: Text(t.t('settings'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(FxSpacing.md),
              children: [
                FxCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            const LanguageScreen(
                                fromSettings: true)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.language_outlined,
                          color: FxColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(t.t('language'),
                              style: FxText.body)),
                      Text(langLabel,
                          style: FxText.caption),
                      const Icon(Icons.chevron_right,
                          color: FxColors.secondaryText),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                FxCard(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        value: app.notificationsEnabled,
                        onChanged:
                            app.setNotificationsEnabled,
                        title: const Text(
                            'Push notifications'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Text(
                        'Stored on this device only for now — per-user '
                        'preferences move to Firestore once the backend '
                        'is connected.',
                        style: FxText.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                FxCard(
                  onTap: () => showLegalDialog(
                    context,
                    title: 'Privacy Policy',
                    body:
                        'Placeholder — the full Privacy Policy is being '
                        'drafted and will be reviewed by legal before the '
                        'production launch.',
                  ),
                  child: _row(Icons.privacy_tip_outlined,
                      'Privacy Policy'),
                ),
                const SizedBox(height: 8),
                FxCard(
                  onTap: () => showLegalDialog(
                    context,
                    title: 'Terms of Service',
                    body:
                        'Placeholder — the full Terms of Service are being '
                        'drafted and will be reviewed by legal before the '
                        'production launch.',
                  ),
                  child: _row(
                      Icons.description_outlined,
                      'Terms of Service'),
                ),
                const SizedBox(height: 16),
                FxButton(
                  label: t.t('signOut'),
                  kind: FxButtonKind.outlined,
                  onPressed: () => _signOut(context),
                ),
                const SizedBox(height: 8),
                FxButton(
                  label: 'Delete account',
                  kind: FxButtonKind.destructive,
                  onPressed: () =>
                      _deleteAccount(context),
                ),
                const SizedBox(height: 16),
                const Text(
                  'FixinDays customer v1.0.0 · demo mode',
                  style: FxText.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: FxColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: FxText.body)),
        const Icon(Icons.chevron_right,
            color: FxColors.secondaryText),
      ],
    );
  }
}
