/// Partner dashboard: greeting, real stat cards, active-job banner, quick
/// actions. Stats are computed from the demo repositories — no fake charts.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import '../widgets/booking_card.dart';
import 'active_service_screen.dart';
import 'availability_screen.dart';
import 'catalogue_screen.dart';
import 'earnings_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'requests_screen.dart';
import 'reviews_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';
import 'upcoming_screen.dart';

class _DashboardData {
  final List<Booking> incoming;
  final List<Booking> upcoming;
  final List<Booking> history;
  final ProviderEarnings earnings;

  const _DashboardData({
    required this.incoming,
    required this.upcoming,
    required this.history,
    required this.earnings,
  });

  Booking? get activeJob {
    for (final b in upcoming) {
      if (b.status == BookingStatus.enRoute ||
          b.status == BookingStatus.arrived ||
          b.status == BookingStatus.inProgress) {
        return b;
      }
    }
    return null;
  }

  int get upcomingToday {
    final now = DateTime.now();
    return upcoming.where((b) {
      final s = b.scheduledAt.toLocal();
      return s.year == now.year && s.month == now.month && s.day == now.day;
    }).length;
  }

  int get completedThisWeek {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return history
        .where((b) =>
            b.status == BookingStatus.completed &&
            b.scheduledAt.isAfter(cutoff))
        .length;
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DashboardData> _load() async {
    final state = context.read<PartnerState>();
    final uid = state.user!.id;
    final results = await Future.wait([
      state.ops.incomingRequests(uid),
      state.ops.upcomingBookings(uid),
      state.ops.bookingHistory(uid),
      state.ops.earnings(uid),
    ]);
    return _DashboardData(
      incoming: results[0] as List<Booking>,
      upcoming: results[1] as List<Booking>,
      history: results[2] as List<Booking>,
      earnings: results[3] as ProviderEarnings,
    );
  }

  void _refresh() => setState(() => _future = _load());

  void _push(Widget screen) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen))
        .then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PartnerState>();
    final t = FxLocalizations.of(context);
    final name = state.profile?.businessName ?? state.user?.name ?? 'Partner';

    return Scaffold(
      appBar: AppBar(
        title: const Text('FixinDays Partner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: t.t('notifications'),
            onPressed: () => _push(const NotificationsScreen()),
          ),
        ],
      ),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: FutureBuilder<_DashboardData>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SingleChildScrollView(
                      padding: EdgeInsets.all(FxSpacing.lg),
                      child: FxLoadingList(),
                    );
                  }
                  if (snap.hasError) {
                    return ErrorPanel(
                      message: snap.error.toString(),
                      onRetry: _refresh,
                    );
                  }
                  final d = snap.data!;
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(FxSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Namaste, $name', style: FxText.headline),
                        const SizedBox(height: 4),
                        Text(
                          'Here is your business at a glance.',
                          style: FxText.body
                              .copyWith(color: FxColors.secondaryText),
                        ),
                        const SizedBox(height: 16),
                        if (d.activeJob != null)
                          _activeJobCard(d.activeJob!),
                        _statGrid(d, t),
                        const SizedBox(height: 16),
                        FxSectionHeader(
                            title: 'Quick actions', onAction: null),
                        const SizedBox(height: 8),
                        _quickTile(
                          Icons.event_outlined,
                          'Upcoming jobs',
                          '${d.upcoming.length} scheduled',
                          () => _push(const UpcomingScreen()),
                        ),
                        _quickTile(
                          Icons.inventory_2_outlined,
                          t.t('services'),
                          'Manage your catalogue',
                          () => _push(const CatalogueScreen()),
                        ),
                        _quickTile(
                          Icons.schedule_outlined,
                          'Availability',
                          'Working days & hours',
                          () => _push(const AvailabilityScreen()),
                        ),
                        _quickTile(
                          Icons.star_outline,
                          t.t('reviews'),
                          'What customers say',
                          () => _push(const ReviewsScreen()),
                        ),
                        _quickTile(
                          Icons.support_agent_outlined,
                          t.t('helpSupport'),
                          'Raise a ticket',
                          () => _push(const SupportScreen()),
                        ),
                        _quickTile(
                          Icons.settings_outlined,
                          t.t('settings'),
                          'Language, sign out & more',
                          () => _push(const SettingsScreen()),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeJobCard(Booking b) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FxSpacing.md),
      child: FxCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: FxColors.navy.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.circular(FxRadius.md),
              ),
              child:
                  const Icon(Icons.directions_car, color: FxColors.navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ongoing job', style: FxText.subtitle),
                  Text(formatSlot(b.scheduledAt), style: FxText.caption),
                ],
              ),
            ),
            FxButton(
              label: 'Open',
              onPressed: () => _push(const ActiveServiceScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statGrid(_DashboardData d, FxLocalizations t) {
    final cards = [
      (
        '${d.incoming.length}',
        t.t('requests'),
        Icons.inbox_outlined,
        FxColors.warning,
        () => _push(const RequestsScreen())
      ),
      (
        '${d.upcomingToday}',
        'Jobs today',
        Icons.event_outlined,
        FxColors.primary,
        () => _push(const UpcomingScreen())
      ),
      (
        '${d.completedThisWeek}',
        'Done this week',
        Icons.check_circle_outline,
        FxColors.darkGreen,
        () => _push(const HistoryScreen())
      ),
      (
        formatInr(d.earnings.netPaise),
        'Net earnings',
        Icons.payments_outlined,
        FxColors.navy,
        () => _push(const EarningsScreen())
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: cards.map((c) {
        return FxCard(
          onTap: c.$5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(c.$3, color: c.$4),
              const SizedBox(height: 8),
              Text(c.$1,
                  style: FxText.headline.copyWith(fontSize: 20)),
              Text(c.$2, style: FxText.caption),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _quickTile(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: FxText.subtitle),
                  Text(subtitle, style: FxText.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: FxColors.secondaryText),
          ],
        ),
      ),
    );
  }
}
