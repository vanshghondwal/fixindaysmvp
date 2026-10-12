/// My bookings with Upcoming / Completed / Cancelled tabs.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'booking_detail_screen.dart';

enum _Tab { upcoming, completed, cancelled }

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.t('myBookings')),
          bottom: TabBar(
            tabs: [
              Tab(text: t.t('upcoming')),
              Tab(text: t.t('completed')),
              Tab(text: t.t('cancelled')),
            ],
          ),
        ),
        body: Column(
          children: [
            if (AppConfig.useDemoData) const DemoBanner(),
            const Expanded(
              child: TabBarView(
                children: [
                  _BookingList(tab: _Tab.upcoming),
                  _BookingList(tab: _Tab.completed),
                  _BookingList(tab: _Tab.cancelled),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingList extends StatefulWidget {
  final _Tab tab;

  const _BookingList({required this.tab});

  @override
  State<_BookingList> createState() => _BookingListState();
}

class _BookingListState extends State<_BookingList> {
  late Future<List<Booking>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Booking>> _load() async {
    final app = context.read<AppState>();
    final all =
        await app.repos.bookings.myBookings(app.user!.id);
    switch (widget.tab) {
      case _Tab.upcoming:
        return all
            .where((b) =>
                b.isActive || b.status == BookingStatus.disputed)
            .toList();
      case _Tab.completed:
        return all
            .where((b) => b.status == BookingStatus.completed)
            .toList();
      case _Tab.cancelled:
        return all
            .where((b) =>
                b.status == BookingStatus.cancelled ||
                b.status == BookingStatus.rejected)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _future = _load());
        await _future;
      },
      child: FutureBuilder<List<Booking>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState ==
              ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(FxSpacing.md),
              child: FxLoadingList(),
            );
          }
          if (snap.hasError) {
            return ErrorPanel(
              message: snap.error.toString(),
              onRetry: () =>
                  setState(() => _future = _load()),
            );
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.calendar_month_outlined,
              title: 'No bookings here',
              message:
                  'Bookings in this state will show up here.',
            );
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(FxSpacing.md),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final b = list[i];
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: 12),
                child: FxCard(
                  onTap: () =>
                      Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingDetailScreen(
                          bookingId: b.id),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(b.providerName,
                                style: FxText.subtitle),
                          ),
                          StatusChip.booking(b.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEE, d MMM · h:mm a')
                            .format(b.scheduledAt),
                        style: FxText.caption,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              b.items
                                  .map((e) =>
                                      '${e.quantity}× ${e.serviceName}')
                                  .join(', '),
                              style: FxText.caption,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ),
                          Text(formatInr(b.totalPaise),
                              style: FxText.price
                                  .copyWith(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
