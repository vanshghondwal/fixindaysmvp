/// Customer profile: user info + menu (edit profile, addresses, language,
/// help, settings, sign out).
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'addresses_screen.dart';
import 'edit_profile_screen.dart';
import 'help_screen.dart';
import 'language_screen.dart';
import 'settings_screen.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.user!;
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('profile'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(FxSpacing.md),
              children: [
                FxCard(
                  child: Row(
                    children: [
                      FxAvatar(
                          name: user.name, radius: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                                user.name.isEmpty
                                    ? 'FixinDays user'
                                    : user.name,
                                style: FxText.title),
                            const SizedBox(height: 2),
                            Text(user.phone,
                                style: FxText.caption),
                            if ((user.email ?? '')
                                .isNotEmpty)
                              Text(user.email!,
                                  style: FxText.caption),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  const EditProfileScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _menuTile(
                  context,
                  icon: Icons.person_outline,
                  label: 'Edit profile',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            const EditProfileScreen()),
                  ),
                ),
                _menuTile(
                  context,
                  icon: Icons.location_on_outlined,
                  label: 'My addresses',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            const AddressesScreen()),
                  ),
                ),
                _menuTile(
                  context,
                  icon: Icons.language_outlined,
                  label: t.t('language'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            const LanguageScreen(
                                fromSettings: true)),
                  ),
                ),
                _menuTile(
                  context,
                  icon: Icons.help_outline,
                  label: t.t('helpSupport'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            const HelpScreen()),
                  ),
                ),
                _menuTile(
                  context,
                  icon: Icons.settings_outlined,
                  label: t.t('settings'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            const SettingsScreen()),
                  ),
                ),
                const SizedBox(height: 8),
                _menuTile(
                  context,
                  icon: Icons.logout,
                  label: t.t('signOut'),
                  danger: true,
                  onTap: () => _signOut(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FxCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
            horizontal: FxSpacing.md, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                color: danger
                    ? FxColors.error
                    : FxColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: danger
                      ? FxText.body.copyWith(
                          color: FxColors.error,
                          fontWeight: FontWeight.w600)
                      : FxText.body),
            ),
            const Icon(Icons.chevron_right,
                color: FxColors.secondaryText),
          ],
        ),
      ),
    );
  }
}
