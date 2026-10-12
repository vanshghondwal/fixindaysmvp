/// Upcoming bookings: accepted / confirmed / active, sorted by date,
/// with filter chips (All / Today / This week).
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import '../widgets/booking_card.dart';
import 'active_service_screen.dart';
import 'request_detail_screen.dart';

enum _Filter { all, today, week }

class UpcomingScreen extends StatefulWidget {
  const UpcomingScreen({super.key});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  late Future<List<Booking>> _future;
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Booking>> _load() {
    final state = context.read<PartnerState>();
    return state.ops.upcomingBookings(state.user!.id);
  }

  void _refresh() => setState(() => _future = _load());

  bool _matches(Booking b) {
    final now = DateTime.now();
    final s = b.scheduledAt.toLocal();
    switch (_filter) {
      case _Filter.all:
        return true;
      case _Filter.today:
        return s.year == now.year && s.month == now.month && s.day == now.day;
      case _Filter.week:
        return s.isBefore(now.add(const Duration(days: 7)));
    }
  }

  void _open(Booking b) {
    final active = b.status == BookingStatus.enRoute ||
        b.status == BookingStatus.arrived ||
        b.status == BookingStatus.inProgress;
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => active
              ? const ActiveServiceScreen()
              : RequestDetailScreen(bookingId: b.id),
        ))
        .then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('upcoming'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                FxSpacing.lg, FxSpacing.md, FxSpacing.lg, 0),
            child: Row(
              children: [
                _chip('All', _Filter.all),
                const SizedBox(width: 8),
                _chip('Today', _Filter.today),
                const SizedBox(width: 8),
                _chip('This week', _Filter.week),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: FutureBuilder<List<Booking>>(
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
                  final items =
                      snap.data!.where(_matches).toList();
                  if (items.isEmpty) {
                    return SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      child: EmptyState(
                        icon: Icons.event_outlined,
                        title: 'No upcoming jobs',
                        message:
                            'Accepted and confirmed bookings will appear here.',
                        actionLabel: t.t('retry'),
                        onAction: _refresh,
                      ),
                    );
                  }
                  return ListView.separated(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(FxSpacing.lg),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, i) => BookingCard(
                      booking: items[i],
                      onTap: () => _open(items[i]),
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

  Widget _chip(String label, _Filter f) {
    return FilterChip(
      label: Text(label),
      selected: _filter == f,
      onSelected: (_) => setState(() => _filter = f),
    );
  }
}
