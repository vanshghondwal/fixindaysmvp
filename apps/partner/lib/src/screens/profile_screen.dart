/// Profile tab: business preview (as customers see it) + shortcuts to all
/// partner sections. Editing reuses [ProfileSetupScreen] in edit mode.
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

    return Scaffold(
      appBar: AppBar(title: const Text('FixinDays Partner')),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(FxSpacing.lg),
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
                    FxCard(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              FxAvatar(
                                  name: p.businessName, radius: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(p.businessName,
                                              style: FxText.title,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                        ),
                                        const SizedBox(width: 6),
                                        VerifiedBadge(
                                            verified:
                                                p.isVerified),
                                      ],
                                    ),
                                    Text(p.ownerName,
                                        style: FxText.caption),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        RatingStars(
                                            rating: p.ratingAvg,
                                            size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          p.ratingCount > 0
                                              ? '${p.ratingAvg.toStringAsFixed(1)} (${p.ratingCount})'
                                              : 'No ratings yet',
                                          style: FxText.caption,
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
                                style: FxText.body),
                          ],
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(
                                label: Text(
                                    '${p.experienceYears} yrs exp'),
                                avatar: const Icon(
                                    Icons.workspace_premium_outlined,
                                    size: 16),
                              ),
                              ...p.serviceAreas.map((a) =>
                                  Chip(label: Text(a))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FxButton(
                            label: 'Edit profile',
                            kind: FxButtonKind.outlined,
                            icon: Icons.edit_outlined,
                            onPressed: () => _push(
                                context,
                                ProfileSetupScreen(
                                    existing: p)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const FxSectionHeader(title: 'Manage'),
                  const SizedBox(height: 8),
                  _tile(context, Icons.event_outlined, 'Upcoming jobs',
                      () => _push(context, const UpcomingScreen())),
                  _tile(
                      context,
                      Icons.directions_car_outlined,
                      'Active service',
                      () => _push(
                          context, const ActiveServiceScreen())),
                  _tile(context, Icons.history_outlined,
                      'Booking history',
                      () => _push(context, const HistoryScreen())),
                  _tile(context, Icons.schedule_outlined,
                      'Availability',
                      () => _push(
                          context, const AvailabilityScreen())),
                  _tile(context, Icons.place_outlined,
                      'Service areas',
                      () =>
                          _push(context, const AreasScreen())),
                  _tile(context, Icons.star_outline, t.t('reviews'),
                      () => _push(context, const ReviewsScreen())),
                  _tile(context, Icons.notifications_outlined,
                      t.t('notifications'),
                      () => _push(
                          context, const NotificationsScreen())),
                  _tile(context, Icons.support_agent_outlined,
                      t.t('helpSupport'),
                      () => _push(context, const SupportScreen())),
                  _tile(context, Icons.settings_outlined,
                      t.t('settings'),
                      () => _push(context, const SettingsScreen())),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title,
      VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FxSpacing.sm),
      child: FxCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
            horizontal: FxSpacing.md, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: FxColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: FxText.subtitle)),
            const Icon(Icons.chevron_right,
                color: FxColors.secondaryText),
          ],
        ),
      ),
    );
  }
}
