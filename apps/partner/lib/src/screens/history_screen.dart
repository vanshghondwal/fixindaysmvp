/// Booking history: completed / cancelled / rejected with outcomes.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import '../widgets/booking_card.dart';
import 'request_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Booking>> _future;
  BookingStatus? _filter; // null = all

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Booking>> _load() {
    final state = context.read<PartnerState>();
    return state.ops.bookingHistory(state.user!.id);
  }

  void _refresh() => setState(() => _future = _load());

  String _outcome(Booking b) {
    switch (b.status) {
      case BookingStatus.completed:
        return 'Completed • ${formatInr(b.totalPaise)} earned';
      case BookingStatus.cancelled:
        return 'Cancelled${b.cancelReason != null ? ' • ${b.cancelReason}' : ''}';
      case BookingStatus.rejected:
        return 'Rejected by you';
      case BookingStatus.disputed:
        return 'Under dispute review';
      default:
        return b.status.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Booking history')),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                FxSpacing.lg, FxSpacing.md, FxSpacing.lg, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('All', null),
                  const SizedBox(width: 8),
                  _chip(t.t('completed'), BookingStatus.completed),
                  const SizedBox(width: 8),
                  _chip(t.t('cancelled'), BookingStatus.cancelled),
                  const SizedBox(width: 8),
                  _chip('Rejected', BookingStatus.rejected),
                ],
              ),
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
                  final items = snap.data!
                      .where((b) =>
                          _filter == null || b.status == _filter)
                      .toList();
                  if (items.isEmpty) {
                    return SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      child: EmptyState(
                        icon: Icons.history_outlined,
                        title: 'No history yet',
                        message:
                            'Completed and cancelled bookings will appear here.',
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
                      subtitle: _outcome(items[i]),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RequestDetailScreen(
                              bookingId: items[i].id),
                        ),
                      ),
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

  Widget _chip(String label, BookingStatus? s) {
    return FilterChip(
      label: Text(label),
      selected: _filter == s,
      onSelected: (_) => setState(() => _filter = s),
    );
  }
}
