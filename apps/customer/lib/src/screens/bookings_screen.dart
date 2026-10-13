/// My bookings — MAXIMALISM edition: vibrant tab bar, rich cards with
/// colorful status pills. Tab/filter logic unchanged.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/max_bits.dart';
import 'booking_detail_screen.dart';

enum _Tab { upcoming, completed, cancelled }

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: MaxScaffold(
        body: Column(
          children: [
            if (AppConfig.useDemoData) const DemoBanner(),
            // ---- Vibrant header ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: MaxColors.oceanGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow:
                          maxShadow(MaxColors.sky, blur: 12),
                    ),
                    child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(t.t('myBookings'),
                      style: MaxText.headline),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ---- Colorful tab pills ----
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: MaxColors.creamDeep,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    gradient: MaxColors.heroGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow:
                        maxShadow(MaxColors.orange, blur: 10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13),
                  unselectedLabelColor: MaxColors.inkSoft,
                  unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                  tabs: [
                    Tab(text: t.t('upcoming')),
                    Tab(text: t.t('completed')),
                    Tab(text: t.t('cancelled')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
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
    // Rotate card accent colors for visual rhythm
    const accents = [
      MaxColors.orange,
      MaxColors.sky,
      MaxColors.purple,
      MaxColors.mint,
      MaxColors.pink,
    ];
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _future = _load());
        await _future;
      },
      color: MaxColors.orange,
      child: FutureBuilder<List<Booking>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState ==
              ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16),
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
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final b = list[i];
              final accent = accents[i % accents.length];
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: 12),
                child: MaxCard(
                  shadowColor: accent,
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
                          // Colorful date badge
                          Container(
                            width: 52,
                            padding:
                                const EdgeInsets.symmetric(
                                    vertical: 8),
                            decoration: BoxDecoration(
                              color: accent.withValues(
                                  alpha: 0.14),
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('d').format(
                                      b.scheduledAt),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.w900,
                                    color: accent,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM').format(
                                      b.scheduledAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.w800,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(b.providerName,
                                    style: MaxText.title
                                        .copyWith(
                                            fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('EEE · h:mm a')
                                      .format(b.scheduledAt),
                                  style: MaxText.caption,
                                ),
                              ],
                            ),
                          ),
                          MaxStatusPill.booking(b.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: MaxColors.cream,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                b.items
                                    .map((e) =>
                                        '${e.quantity}× ${e.serviceName}')
                                    .join(', '),
                                style: MaxText.body.copyWith(
                                    fontSize: 12),
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(formatInr(b.totalPaise),
                                style: MaxText.title.copyWith(
                                    fontSize: 15,
                                    color:
                                        MaxColors.orangeDeep)),
                          ],
                        ),
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
