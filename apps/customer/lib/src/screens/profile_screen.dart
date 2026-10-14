/// Customer profile — MAXIMALISM edition: gradient hero card with
/// avatar + stats, colorful menu tiles. Sign-out logic unchanged.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'addresses_screen.dart';
import 'bookings_screen.dart';
import 'edit_profile_screen.dart';
import 'favorites_screen.dart';
import 'help_screen.dart';
import 'language_screen.dart';
import 'offers_screen.dart';
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
    final initial = user.name.trim().isEmpty
        ? '?'
        : user.name.trim()[0].toUpperCase();

    return MaxScaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Gradient hero card ----
          MaxHeroCard(
            gradient: MaxColors.grapeGradient,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: 0.22),
                        borderRadius:
                            BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name.isEmpty
                                ? 'FixinDays user'
                                : user.name,
                            style: MaxText.onGradientBig
                                .copyWith(fontSize: 22),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(user.phone,
                              style: MaxText.onGradient
                                  .copyWith(
                                      fontSize: 13,
                                      color: Colors.white
                                          .withValues(
                                              alpha: 0.9))),
                          if ((user.email ?? '').isNotEmpty)
                            Text(user.email!,
                                style: MaxText.onGradient
                                    .copyWith(
                                        fontSize: 12,
                                        color: Colors.white
                                            .withValues(
                                                alpha: 0.8)),
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                const EditProfileScreen()),
                      ),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(alpha: 0.22),
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats row
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      _whiteStat(
                          '${app.cart.totalQty}', 'In cart'),
                      _whiteStat('4.8', 'Avg rating'),
                      _whiteStat('12', 'Bookings'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const MaxSectionHeader(title: 'Your space 🎛️'),
          _menuTile(
            context,
            icon: Icons.person_outline,
            label: 'Edit profile',
            bg: MaxColors.orangeSoft,
            fg: MaxColors.orangeDeep,
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
            bg: MaxColors.skySoft,
            fg: const Color(0xFF1B7FC1),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) =>
                      const AddressesScreen()),
            ),
          ),
          _menuTile(
            context,
            icon: Icons.calendar_month_outlined,
            label: t.t('myBookings'),
            bg: MaxColors.purpleSoft,
            fg: MaxColors.purple,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) =>
                      const BookingsScreen()),
            ),
          ),
          _menuTile(
            context,
            icon: Icons.favorite_outline,
            label: 'Favorites',
            bg: MaxColors.pinkSoft,
            fg: MaxColors.pink,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) =>
                      const FavoritesScreen()),
            ),
          ),
          _menuTile(
            context,
            icon: Icons.local_offer_outlined,
            label: 'Offers & coupons',
            bg: MaxColors.orangeSoft,
            fg: MaxColors.orangeDeep,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const OffersScreen()),
            ),
          ),
          _menuTile(
            context,
            icon: Icons.language_outlined,
            label: t.t('language'),
            bg: MaxColors.mintSoft,
            fg: const Color(0xFF1E9E50),
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
            bg: MaxColors.sunSoft,
            fg: const Color(0xFFB8860B),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const HelpScreen()),
            ),
          ),
          _menuTile(
            context,
            icon: Icons.settings_outlined,
            label: t.t('settings'),
            bg: MaxColors.tealSoft,
            fg: const Color(0xFF00968F),
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
            bg: MaxColors.coralSoft,
            fg: MaxColors.coral,
            onTap: () => _signOut(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _whiteStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white
                    .withValues(alpha: 0.85))),
      ],
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MaxCard(
        onTap: onTap,
        shadowColor: fg,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: fg, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: MaxText.title
                      .copyWith(fontSize: 15)),
            ),
            Icon(Icons.chevron_right,
                color: fg.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}
