/// Booking detail: summary, line items, status chip, timeline and actions
/// (cancel with reason, reschedule, review, dispute).
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'dispute_screen.dart';
import 'reviews_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState
    extends State<BookingDetailScreen> {
  late Future<Booking?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Booking?> _load() =>
      context.read<AppState>().repos.bookings.booking(widget.bookingId);

  void _refresh() => setState(() => _future = _load());

  Future<void> _cancel(Booking b) async {
    if (!canTransition(
        b.status, BookingStatus.cancelled, UserRole.customer)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'This booking can\'t be cancelled at its current stage.')),
      );
      return;
    }
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Please tell us why — it helps us improve.'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                  hintText: 'Reason for cancellation'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep booking'),
          ),
          FxButton(
            label: 'Cancel booking',
            kind: FxButtonKind.destructive,
            onPressed: () {
              if (validateRequired(reasonCtrl.text,
                      'Reason') !=
                  null) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Please enter a reason')),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context
          .read<AppState>()
          .repos
          .bookings
          .cancelBooking(b.id, reasonCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled')),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _reschedule(Booking b) async {
    final date = await showDatePicker(
      context: context,
      initialDate: b.scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final slot = await showDialog<DateTime>(
      context: context,
      builder: (ctx) {
        final slots = List.generate(
            11,
            (i) => DateTime(
                date.year, date.month, date.day, 9 + i));
        return AlertDialog(
          title: const Text('Pick a time'),
          content: SizedBox(
            width: double.maxFinite,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots
                  .map((s) => ActionChip(
                        label: Text(
                            DateFormat('h:mm a').format(s)),
                        onPressed: () =>
                            Navigator.pop(ctx, s),
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
    if (slot == null || !mounted) return;
    try {
      await context
          .read<AppState>()
          .repos
          .bookings
          .rescheduleBooking(b.id, slot);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking rescheduled')),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return VoiceScreenTag(
      screenKey: 'booking',
      child: Scaffold(
      appBar: AppBar(title: Text(t.t('bookingDetails'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: FutureBuilder<Booking?>(
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
                    onRetry: _refresh,
                  );
                }
                final b = snap.data;
                if (b == null) {
                  return const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Booking not found',
                    message:
                        'It may have been deleted.',
                  );
                }
                return _content(b);
              },
            ),
          ),
        ],
      ),
    ));
  }

  Widget _content(Booking b) {
    final t = FxLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(FxSpacing.md),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Booking ${b.id}',
                  style: FxText.title),
            ),
            StatusChip.booking(b.status),
          ],
        ),
        const SizedBox(height: 12),
        FxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.providerName, style: FxText.subtitle),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEE, d MMM yyyy · h:mm a')
                    .format(b.scheduledAt),
                style: FxText.caption,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16,
                      color: FxColors.secondaryText),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(b.addressSnapshot,
                          style: FxText.body)),
                ],
              ),
              if (b.notes?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text('Notes: ${b.notes}',
                    style: FxText.caption),
              ],
              if (b.cancelReason?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text('Cancel reason: ${b.cancelReason}',
                    style: const TextStyle(
                        color: FxColors.error,
                        fontSize: 13)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        FxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Services', style: FxText.subtitle),
              const SizedBox(height: 4),
              ...b.items.map((i) => LineItemRow(item: i)),
              const Divider(),
              _moneyRow(t.t('subtotal'), b.subtotalPaise),
              _moneyRow(
                  t.t('platformFee'), b.platformFeePaise),
              _moneyRow(t.t('total'), b.totalPaise,
                  bold: true),
              const SizedBox(height: 4),
              Text('Payment: ${b.paymentStatus.name}',
                  style: FxText.caption),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const FxSectionHeader(title: 'Timeline'),
        const SizedBox(height: 4),
        _timelineStep(
            Icons.receipt_long, 'Booked', b.createdAt),
        _timelineStep(Icons.calendar_month,
            'Scheduled for', b.scheduledAt),
        _timelineStep(Icons.update,
            'Status: ${b.status.name}', b.updatedAt,
            last: true),
        const SizedBox(height: 16),
        _actions(b),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _moneyRow(String label, int paise,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: bold ? FxText.subtitle : FxText.body),
          Text(formatInr(paise),
              style: bold ? FxText.price : FxText.body),
        ],
      ),
    );
  }

  Widget _timelineStep(
      IconData icon, String label, DateTime at,
      {bool last = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, size: 20, color: FxColors.primary),
            if (!last)
              Container(
                  width: 2, height: 20, color: FxColors.borders),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: FxText.body),
                Text(
                    DateFormat('d MMM yyyy · h:mm a')
                        .format(at),
                    style: FxText.caption),
                if (!last) const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actions(Booking b) {
    final app = context.read<AppState>();
    final buttons = <Widget>[];
    if (canTransition(b.status, BookingStatus.cancelled,
        UserRole.customer)) {
      buttons.add(FxButton(
        label: 'Cancel booking',
        kind: FxButtonKind.outlined,
        onPressed: () => _cancel(b),
      ));
    }
    if (b.isActive) {
      buttons.add(FxButton(
        label: 'Reschedule',
        kind: FxButtonKind.outlined,
        onPressed: () => _reschedule(b),
      ));
    }
    if (b.status == BookingStatus.completed ||
        b.status == BookingStatus.cancelled) {
      buttons.add(FxButton(
        label: 'Report issue',
        kind: FxButtonKind.outlined,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DisputeScreen(booking: b),
          ),
        ),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FutureBuilder<bool>(
          future:
              app.repos.bookings.hasReviewed(b.id),
          builder: (_, snap) {
            final eligible = snap.data == false &&
                isReviewEligible(
                  booking: b,
                  customerId: app.user!.id,
                  alreadyReviewed: false,
                );
            if (!eligible) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: 8),
              child: FxButton(
                label: 'Write a review',
                icon: Icons.star_outline,
                onPressed: () async {
                  final changed =
                      await Navigator.of(context)
                          .push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ReviewsScreen(
                        providerId: b.providerId,
                        booking: b,
                      ),
                    ),
                  );
                  if (changed == true) _refresh();
                },
              ),
            );
          },
        ),
        ...buttons.map((w) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                  width: double.infinity, child: w),
            )),
      ],
    );
  }
}
