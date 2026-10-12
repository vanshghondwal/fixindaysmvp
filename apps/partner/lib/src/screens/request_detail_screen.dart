/// Full booking detail with state-appropriate provider actions.
///
/// * pending   -> accept / reject
/// * accepted  -> confirm (locks the schedule)
/// * confirmed -> mark en route
/// * enRoute+  -> open the active-service screen
/// A reschedule note points to support (providers cannot edit slots here).
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import '../widgets/booking_card.dart';
import 'active_service_screen.dart';
import 'support_screen.dart';

class RequestDetailScreen extends StatefulWidget {
  final String bookingId;

  const RequestDetailScreen({super.key, required this.bookingId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late Future<Booking?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Booking?> _load() {
    final state = context.read<PartnerState>();
    return state.ops.booking(widget.bookingId);
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _respond(Booking b, bool accept) async {
    final t = FxLocalizations.of(context);
    final ok = await fxConfirm(
      context,
      title: accept ? t.t('accept') : t.t('reject'),
      message: accept
          ? 'Accept this booking request?'
          : 'Reject this booking request? This cannot be undone.',
      confirmLabel: accept ? t.t('accept') : t.t('reject'),
      destructive: !accept,
    );
    if (!ok) return;
    await _run(() =>
        context.read<PartnerState>().ops.respondToBooking(b.id, accept));
  }

  Future<void> _transition(Booking b, BookingStatus to, String label) async {
    final ok = await fxConfirm(
      context,
      title: label,
      message: 'Move this booking to "${to.name}"?',
      confirmLabel: FxLocalizations.of(context).t('confirm'),
    );
    if (!ok) return;
    await _run(
        () => context.read<PartnerState>().ops.transitionBooking(b.id, to));
  }

  Future<void> _run(Future<void> Function() op) async {
    try {
      await op();
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Booking details')),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: FutureBuilder<Booking?>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SingleChildScrollView(
                    padding: EdgeInsets.all(FxSpacing.lg),
                    child: FxLoadingList(count: 2),
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
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: t.t('noResults'),
                    message: t.t('tryDifferentSearch'),
                    actionLabel: t.t('retry'),
                    onAction: _refresh,
                  );
                }
                return _detail(context, b, t);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(BuildContext context, Booking b, FxLocalizations t) {
    final state = context.read<PartnerState>();
    final c = state.ops.demoCustomerContact(b.customerId);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FxSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusChip.booking(b.status),
              Text(formatSlot(b.scheduledAt), style: FxText.caption),
            ],
          ),
          const SizedBox(height: 12),
          FxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer', style: FxText.subtitle),
                const SizedBox(height: 4),
                Text(c['name']!, style: FxText.body),
                Text(
                  b.status == BookingStatus.pending
                      ? 'Full contact is shared after you accept '
                          '(demo: ${c['maskedPhone']})'
                      : 'Contact (demo): ${c['maskedPhone']}',
                  style: FxText.caption,
                ),
                const Divider(height: 20),
                const Text('Service address', style: FxText.subtitle),
                const SizedBox(height: 4),
                Text(b.addressSnapshot, style: FxText.body),
                if (b.notes != null && b.notes!.isNotEmpty) ...[
                  const Divider(height: 20),
                  const Text('Customer notes', style: FxText.subtitle),
                  const SizedBox(height: 4),
                  Text(b.notes!, style: FxText.body),
                ],
                if (b.cancelReason != null &&
                    b.cancelReason!.isNotEmpty) ...[
                  const Divider(height: 20),
                  const Text('Cancellation reason',
                      style: FxText.subtitle),
                  const SizedBox(height: 4),
                  Text(b.cancelReason!, style: FxText.body),
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
                const SizedBox(height: 8),
                BookingTotals(booking: b),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FxCard(
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: FxColors.secondaryText),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Need a different time? Providers cannot edit the slot '
                    'directly — raise a support ticket and we will help '
                    'reschedule.',
                    style: FxText.caption,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const SupportScreen()),
                  ),
                  child: const Text('Support'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._actions(b, t),
        ],
      ),
    );
  }

  List<Widget> _actions(Booking b, FxLocalizations t) {
    switch (b.status) {
      case BookingStatus.pending:
        return [
          FxButton(
              label: t.t('accept'), onPressed: () => _respond(b, true)),
          const SizedBox(height: 12),
          FxButton(
            label: t.t('reject'),
            kind: FxButtonKind.destructive,
            onPressed: () => _respond(b, false),
          ),
        ];
      case BookingStatus.accepted:
        return [
          FxButton(
            label: 'Confirm booking',
            onPressed: () =>
                _transition(b, BookingStatus.confirmed, 'Confirm booking'),
          ),
        ];
      case BookingStatus.confirmed:
        return [
          FxButton(
            label: 'Mark en route',
            onPressed: () =>
                _transition(b, BookingStatus.enRoute, 'Mark en route'),
            icon: Icons.directions_car,
          ),
        ];
      case BookingStatus.enRoute:
      case BookingStatus.arrived:
      case BookingStatus.inProgress:
        return [
          FxButton(
            label: 'Open active service',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const ActiveServiceScreen()),
            ),
          ),
        ];
      default:
        return [];
    }
  }
}
