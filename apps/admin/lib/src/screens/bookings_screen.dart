/// Booking oversight: search by ID/customer, filter by status, inspect a
/// booking's line items, totals and status.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/admin_state.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final _search = TextEditingController();
  BookingStatus? _status;
  late Future<List<Booking>> _future;

  @override
  void initState() {
    super.initState();
    _reload(initial: true);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload({bool initial = false}) {
    final f = context
        .read<AdminState>()
        .repo
        .searchBookings(query: _search.text, status: _status);
    if (initial) {
      _future = f;
    } else {
      setState(() => _future = f);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg, FxSpacing.lg, FxSpacing.lg, 0),
          child: Column(
            children: [
              FxTextField(
                controller: _search,
                label: 'Search bookings',
                hint: 'Booking ID, customer ID or provider name…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _search.clear();
                    _reload();
                  },
                ),
              ),
              const SizedBox(height: FxSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('All', _status == null, () {
                      _status = null;
                      _reload();
                    }),
                    for (final s in BookingStatus.values)
                      _chip(s.name, _status == s, () {
                        _status = s;
                        _reload();
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Booking>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const FxLoadingList(count: 5);
              }
              if (snap.hasError) {
                return ErrorPanel(
                    message: '${snap.error}', onRetry: () => _reload());
              }
              final list = snap.data!;
              if (list.isEmpty) {
                return EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No bookings found',
                  message:
                      'Try a different search term or status filter.',
                  actionLabel: 'Refresh',
                  onAction: () => _reload(),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(FxSpacing.lg),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: FxSpacing.md),
                  itemBuilder: (context, i) =>
                      _bookingCard(context, list[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: FxColors.primary.withOpacity(0.2),
      ),
    );
  }

  Widget _bookingCard(BuildContext context, Booking b) {
    return FxCard(
      onTap: () => _detailDialog(context, b),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.id, style: FxText.subtitle),
                Text('${b.providerName} · ${_fmtDate(b.scheduledAt)}',
                    style: FxText.caption),
                const SizedBox(height: 4),
                Text(formatInr(b.totalPaise), style: FxText.price),
              ],
            ),
          ),
          StatusChip.booking(b.status),
        ],
      ),
    );
  }

  Future<void> _detailDialog(BuildContext context, Booking b) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Booking ${b.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusChip.booking(b.status),
              const SizedBox(height: FxSpacing.md),
              _kv('Customer', b.customerId),
              _kv('Provider', '${b.providerName} (${b.providerId})'),
              _kv('Scheduled', _fmtDateTime(b.scheduledAt)),
              _kv('Address', b.addressSnapshot),
              _kv('Payment', b.paymentStatus.name),
              if (b.notes != null) _kv('Notes', b.notes!),
              if (b.cancelReason != null)
                _kv('Cancel reason', b.cancelReason!),
              const SizedBox(height: FxSpacing.md),
              const Text('Items', style: FxText.subtitle),
              const SizedBox(height: FxSpacing.sm),
              for (final item in b.items) LineItemRow(item: item),
              const Divider(),
              _kv('Subtotal', formatInr(b.subtotalPaise)),
              _kv('Platform fee', formatInr(b.platformFeePaise)),
              _kv('Total', formatInr(b.totalPaise)),
              const SizedBox(height: FxSpacing.md),
              const Text('Timeline', style: FxText.subtitle),
              const SizedBox(height: FxSpacing.sm),
              _timelineRow('Created', b.createdAt),
              _timelineRow('Last updated', b.updatedAt),
              const SizedBox(height: FxSpacing.sm),
              const Text(
                'Full event history lives in the bookingEvents subcollection '
                '(written by Cloud Functions). Admins view it here in a '
                'future revision.',
                style: FxText.caption,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 110,
                child: Text(k, style: FxText.caption)),
            Expanded(child: Text(v, style: FxText.body)),
          ],
        ),
      );

  Widget _timelineRow(String label, DateTime d) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            const Icon(Icons.circle, size: 8, color: FxColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: FxText.body)),
            Text(_fmtDateTime(d), style: FxText.caption),
          ],
        ),
      );

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtDateTime(DateTime d) =>
      '${_fmtDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
