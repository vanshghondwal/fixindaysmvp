/// Settings — maximalism edition.
///
/// Colorful preference + account cards on cream, with the same language,
/// notification, privacy, sign-out and deactivation logic as before.
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
        backgroundColor: MaxColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Privacy', style: MaxText.title),
        content: const Text(
          'All data in this app is sample data stored in memory on '
          'this device. Nothing is uploaded anywhere. After Firebase is '
          'connected, your business profile is visible to customers in your '
          'service areas, and booking details are shared only with the '
          'parties involved.',
          style: MaxText.body,
        ),
        actions: [
          MaxButton(
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

    return MaxScaffold(
      appBar: AppBar(
        backgroundColor: MaxColors.cream,
        foregroundColor: MaxColors.ink,
        elevation: 0,
        title: Text(t.t('settings'), style: MaxText.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const MaxSectionHeader(title: 'Preferences'),
                const SizedBox(height: 4),
                MaxCard(
                  shadowColor: MaxColors.sky,
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: RadioGroup<Locale>(
                      groupValue: state.locale,
                      onChanged: (v) =>
                          context.read<PartnerState>().setLocale(v!),
                      child: Column(
                        children: [
                          RadioListTile<Locale>(
                            title: Text(t.t('language'),
                                style: MaxText.title
                                    .copyWith(fontSize: 15)),
                            subtitle: const Text('English',
                                style: MaxText.body),
                            value: const Locale('en'),
                            activeColor: MaxColors.orange,
                          ),
                          const Divider(height: 1),
                          RadioListTile<Locale>(
                            title: Text(t.t('language'),
                                style: MaxText.title
                                    .copyWith(fontSize: 15)),
                            subtitle: const Text('हिन्दी',
                                style: MaxText.body),
                            value: const Locale('hi'),
                            activeColor: MaxColors.orange,
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            title: const Text(
                                'Booking notifications',
                                style: MaxText.title),
                            subtitle: const Text(
                                'Get notified about new requests (demo).',
                                style: MaxText.caption),
                            value: state.notificationsEnabled,
                            activeThumbColor: MaxColors.orange,
                            onChanged: (v) => context
                                .read<PartnerState>()
                                .setNotificationsEnabled(v),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const MaxSectionHeader(title: 'Account'),
                const SizedBox(height: 4),
                MaxCard(
                  shadowColor: MaxColors.purple,
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        _menuRow(
                          icon: Icons.privacy_tip_outlined,
                          bg: MaxColors.skySoft,
                          fg: MaxColors.sky,
                          title: 'Privacy',
                          onTap: () => _privacy(context),
                        ),
                        const Divider(height: 1),
                        _menuRow(
                          icon: Icons.logout,
                          bg: MaxColors.creamDeep,
                          fg: MaxColors.inkSoft,
                          title: t.t('signOut'),
                          onTap: () => _signOut(context),
                        ),
                        const Divider(height: 1),
                        _menuRow(
                          icon: Icons.delete_forever_outlined,
                          bg: MaxColors.coralSoft,
                          fg: MaxColors.coral,
                          title: 'Deactivate account',
                          titleColor: MaxColors.coral,
                          onTap: () => _deactivate(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'FixinDays Partner • 1.0.0+1',
                  style: MaxText.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow({
    required IconData icon,
    required Color bg,
    required Color fg,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: fg, size: 22),
      ),
      title: Text(title,
          style: MaxText.title.copyWith(
              fontSize: 15, color: titleColor ?? MaxColors.ink)),
      trailing:
          const Icon(Icons.chevron_right, color: MaxColors.inkFaint),
      onTap: onTap,
    );
  }
}
