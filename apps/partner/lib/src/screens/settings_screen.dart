/// Settings: language, notification preference, privacy note, sign out,
/// and destructive deactivation.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import 'partner_gate.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final t = FxLocalizations.of(context);
    final ok = await fxConfirm(
      context,
      title: t.t('signOut'),
      message: 'Sign out of FixinDays Partner on this device?',
      confirmLabel: t.t('signOut'),
    );
    if (!ok || !context.mounted) return;
    await context.read<PartnerState>().signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PartnerGate()),
      (_) => false,
    );
  }

  Future<void> _deactivate(BuildContext context) async {
    final ok = await fxConfirm(
      context,
      title: 'Deactivate account?',
      message:
          'Your profile will be hidden from customers and you will be signed out. '
          'This is a demo — no real data is affected.',
      confirmLabel: 'Deactivate',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await context.read<PartnerState>().deactivateAccount();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PartnerGate()),
        (_) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not deactivate: $e')));
    }
  }

  void _privacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy'),
        content: const Text(
          'Demo mode: all data in this app is sample data stored in memory on '
          'this device. Nothing is uploaded anywhere. After Firebase is '
          'connected, your business profile is visible to customers in your '
          'service areas, and booking details are shared only with the '
          'parties involved.',
        ),
        actions: [
          FxButton(
            label: FxLocalizations.of(context).t('confirm'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    final state = context.watch<PartnerState>();

    return Scaffold(
      appBar: AppBar(title: Text(t.t('settings'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(FxSpacing.lg),
              children: [
                const FxSectionHeader(title: 'Preferences'),
                const SizedBox(height: 8),
                FxCard(
                  padding: EdgeInsets.zero,
                  child: RadioGroup<Locale>(
                    groupValue: state.locale,
                    onChanged: (v) =>
                        context.read<PartnerState>().setLocale(v!),
                    child: Column(
                      children: [
                        RadioListTile<Locale>(
                          title: Text(t.t('language')),
                          subtitle: const Text('English'),
                          value: const Locale('en'),
                        ),
                        const Divider(height: 1),
                        RadioListTile<Locale>(
                          title: Text(t.t('language')),
                          subtitle: const Text('हिन्दी'),
                          value: const Locale('hi'),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Booking notifications'),
                          subtitle: const Text(
                              'Get notified about new requests (demo).',
                              style: FxText.caption),
                          value: state.notificationsEnabled,
                          onChanged: (v) => context
                              .read<PartnerState>()
                              .setNotificationsEnabled(v),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const FxSectionHeader(title: 'Account'),
                const SizedBox(height: 8),
                FxCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined,
                            color: FxColors.primary),
                        title: const Text('Privacy'),
                        trailing: const Icon(Icons.chevron_right,
                            color: FxColors.secondaryText),
                        onTap: () => _privacy(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout,
                            color: FxColors.secondaryText),
                        title: Text(t.t('signOut')),
                        onTap: () => _signOut(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                            Icons.delete_forever_outlined,
                            color: FxColors.error),
                        title: const Text(
                          'Deactivate account',
                          style: TextStyle(color: FxColors.error),
                        ),
                        onTap: () => _deactivate(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'FixinDays Partner • 1.0.0+1 • Demo mode',
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
}
