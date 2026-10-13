/// Partner dashboard — maximalism edition.
///
/// Gradient hero greeting, bold stat cards, incoming requests as colorful
/// cards, quick actions grid. Stats computed from demo repos — no fake charts.
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
import 'notifications_screen.dart';
import 'request_detail_screen.dart';
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

    return MaxScaffold(
      appBar: AppBar(
        backgroundColor: MaxColors.cream,
        foregroundColor: MaxColors.ink,
        elevation: 0,
        title: const Text('FixinDays Partner', style: MaxText.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: MaxColors.orange),
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
              color: MaxColors.orange,
              backgroundColor: MaxColors.cardWhite,
              onRefresh: () async => _refresh(),
              child: FutureBuilder<_DashboardData>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SingleChildScrollView(
                      padding: EdgeInsets.all(16),
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _hero(name, d),
                        const SizedBox(height: 16),
                        _statsCard(d, state),
                        if (d.activeJob != null) ...[
                          const SizedBox(height: 16),
                          _activeJobCard(d.activeJob!),
                        ],
                        const SizedBox(height: 8),
                        MaxSectionHeader(
                          title: 'Incoming requests',
                          actionLabel: d.incoming.isEmpty
                              ? null
                              : 'View all',
                          onAction: d.incoming.isEmpty
                              ? null
                              : () => _push(const RequestsScreen()),
                        ),
                        if (d.incoming.isEmpty)
                          const MaxCard(
                            shadowColor: MaxColors.sky,
                            child: Row(
                              children: [
                                Icon(Icons.inbox_outlined,
                                    color: MaxColors.sky),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No pending requests. New customer bookings will pop up here.',
                                    style: MaxText.body,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...d.incoming
                              .take(3)
                              .map((b) => _requestCard(b, state)),
                        const SizedBox(height: 8),
                        const MaxSectionHeader(title: 'Quick actions'),
                        _quickGrid(t),
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

  /// Gradient hero: greeting + net earnings spotlight (tap → earnings).
  Widget _hero(String name, _DashboardData d) {
    return GestureDetector(
      onTap: () => _push(const EarningsScreen()),
      child: MaxHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Namaste, $name 👋', style: MaxText.onGradientBig.copyWith(fontSize: 24)),
                    const SizedBox(height: 4),
                    const Text(
                      'Here is your business at a glance.',
                      style: MaxText.onGradient,
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.handyman,
                    color: Colors.white, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NET EARNINGS',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.2)),
                    SizedBox(height: 2),
                    Text('Tap to see breakdown',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
                  ],
                ),
                Text(formatInr(d.earnings.netPaise),
                    style: MaxText.onGradientBig),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// Bold stat strip: requests / today's jobs / rating.
  Widget _statsCard(_DashboardData d, PartnerState state) {
    final rating = state.profile?.ratingAvg ?? 0.0;
    return MaxCard(
      shadowColor: MaxColors.purple,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MaxStat(
            value: '${d.incoming.length}',
            label: 'Requests',
            accent: MaxColors.coral,
          ),
          Container(width: 1, height: 44, color: MaxColors.line),
          MaxStat(
            value: '${d.upcomingToday}',
            label: "Today's jobs",
            accent: MaxColors.sky,
          ),
          Container(width: 1, height: 44, color: MaxColors.line),
          MaxStat(
            value: rating > 0
                ? '${rating.toStringAsFixed(1)}★'
                : '—',
            label: 'Rating',
            accent: const Color(0xFFB8860B),
          ),
        ],
      ),
    );
  }

  Widget _activeJobCard(Booking b) {
    return MaxCard(
      shadowColor: MaxColors.mint,
      onTap: () => _push(const ActiveServiceScreen()),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: MaxColors.mintSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.directions_car,
                color: MaxColors.mint, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ongoing job — tap to manage',
                    style: MaxText.title),
                SizedBox(height: 2),
                MaxPill(
                    label: 'LIVE',
                    bg: MaxColors.mintSoft,
                    fg: Color(0xFF1E9E50)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: MaxColors.inkFaint),
        ],
      ),
    );
  }

  Widget _requestCard(Booking b, PartnerState state) {
    final c = state.ops.demoCustomerContact(b.customerId);
    final services = b.items.map((i) => i.serviceName).join(', ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MaxCard(
        shadowColor: MaxColors.coral,
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (_) => RequestDetailScreen(bookingId: b.id),
            ))
            .then((_) => _refresh()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const MaxPill(
                    label: 'NEW REQUEST',
                    bg: MaxColors.coralSoft,
                    fg: MaxColors.coral),
                const Spacer(),
                Text(formatSlot(b.scheduledAt),
                    style: MaxText.caption),
              ],
            ),
            const SizedBox(height: 8),
            Text(services,
                style: MaxText.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${c['name']} • ${formatInr(b.totalPaise)}',
                style: MaxText.body),
          ],
        ),
      ),
    );
  }

  Widget _quickGrid(FxLocalizations t) {
    final tiles = [
      (Icons.event_outlined, 'Upcoming', 3,
          () => _push(const UpcomingScreen())),
      (Icons.inventory_2_outlined, t.t('services'), 0,
          () => _push(const CatalogueScreen())),
      (Icons.schedule_outlined, 'Availability', 7,
          () => _push(const AvailabilityScreen())),
      (Icons.star_outline, t.t('reviews'), 1,
          () => _push(const ReviewsScreen())),
      (Icons.support_agent_outlined, t.t('helpSupport'), 4,
          () => _push(const SupportScreen())),
      (Icons.settings_outlined, t.t('settings'), 5,
          () => _push(const SettingsScreen())),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: tiles.map((tile) {
        return MaxCategoryTile(
          icon: tile.$1,
          label: tile.$2,
          colorIndex: tile.$3,
          onTap: tile.$4,
        );
      }).toList(),
    );
  }
}
