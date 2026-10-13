/// Profile tab — maximalism edition.
///
/// Gradient profile hero (as customers see it), stat strip, and a colorful
/// rotating menu. Editing reuses [ProfileSetupScreen] in edit mode.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import 'active_service_screen.dart';
import 'areas_screen.dart';
import 'availability_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'profile_setup_screen.dart';
import 'reviews_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';
import 'upcoming_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    final state = context.watch<PartnerState>();
    final p = state.profile;

    return MaxScaffold(
      appBar: AppBar(
        backgroundColor: MaxColors.cream,
        foregroundColor: MaxColors.ink,
        elevation: 0,
        title: const Text('FixinDays Partner', style: MaxText.title),
      ),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (p == null)
                    EmptyState(
                      icon: Icons.person_outline,
                      title: 'No profile yet',
                      message:
                          'Set up your business profile to get started.',
                      actionLabel: 'Set up profile',
                      onAction: () => _push(context,
                          const ProfileSetupScreen()),
                    )
                  else ...[
                    _profileHero(context, p),
                    const SizedBox(height: 12),
                    _statsStrip(p),
                    const SizedBox(height: 16),
                  ],
                  const MaxSectionHeader(title: 'Manage'),
                  const SizedBox(height: 4),
                  _tile(context, Icons.event_outlined, 'Upcoming jobs', 3,
                      () => _push(context, const UpcomingScreen())),
                  _tile(context, Icons.directions_car_outlined,
                      'Active service', 2,
                      () => _push(
                          context, const ActiveServiceScreen())),
                  _tile(context, Icons.history_outlined,
                      'Booking history', 7,
                      () => _push(context, const HistoryScreen())),
                  _tile(context, Icons.schedule_outlined,
                      'Availability', 1,
                      () => _push(
                          context, const AvailabilityScreen())),
                  _tile(context, Icons.place_outlined,
                      'Service areas', 6,
                      () =>
                          _push(context, const AreasScreen())),
                  _tile(context, Icons.star_outline, t.t('reviews'), 4,
                      () => _push(context, const ReviewsScreen())),
                  _tile(context, Icons.notifications_outlined,
                      t.t('notifications'), 0,
                      () => _push(
                          context, const NotificationsScreen())),
                  _tile(context, Icons.support_agent_outlined,
                      t.t('helpSupport'), 5,
                      () => _push(context, const SupportScreen())),
                  _tile(context, Icons.settings_outlined,
                      t.t('settings'), 3,
                      () => _push(context, const SettingsScreen())),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gradient hero: avatar, name, verified, rating, edit button.
  Widget _profileHero(BuildContext context, ProviderProfile p) {
    return MaxHeroCard(
      gradient: MaxColors.grapeGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    p.businessName.isNotEmpty
                        ? p.businessName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(p.businessName,
                              style: MaxText.onGradientBig
                                  .copyWith(fontSize: 20),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 6),
                        if (p.isVerified)
                          const Icon(Icons.verified,
                              color: Colors.white, size: 18),
                      ],
                    ),
                    Text(p.ownerName, style: MaxText.onGradient),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: MaxColors.sun, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          p.ratingCount > 0
                              ? '${p.ratingAvg.toStringAsFixed(1)} (${p.ratingCount} reviews)'
                              : 'No ratings yet',
                          style: MaxText.onGradient.copyWith(
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (p.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(p.description,
                style: MaxText.onGradient.copyWith(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _heroChip('${p.experienceYears} yrs exp'),
              ...p.serviceAreas
                  .take(3)
                  .map((a) => _heroChip(a)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _push(
                  context, ProfileSetupScreen(existing: p)),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: MaxColors.purple,
                padding:
                    const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
    );
  }

  Widget _statsStrip(ProviderProfile p) {
    return MaxCard(
      shadowColor: MaxColors.sun,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MaxStat(
            value: '${p.experienceYears}y',
            label: 'Experience',
            accent: MaxColors.orange,
          ),
          Container(width: 1, height: 44, color: MaxColors.line),
          MaxStat(
            value: '${p.serviceAreas.length}',
            label: 'Areas',
            accent: MaxColors.sky,
          ),
          Container(width: 1, height: 44, color: MaxColors.line),
          MaxStat(
            value: p.ratingCount > 0
                ? p.ratingAvg.toStringAsFixed(1)
                : '—',
            label: 'Avg rating',
            accent: const Color(0xFFB8860B),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title,
      int colorIndex, VoidCallback onTap) {
    final (bg, fg) = MaxColors.pairFor(colorIndex);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MaxCard(
        onTap: onTap,
        shadowColor: fg,
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: fg, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: MaxText.title.copyWith(fontSize: 15))),
            const Icon(Icons.chevron_right,
                color: MaxColors.inkFaint),
          ],
        ),
      ),
    );
  }
}
