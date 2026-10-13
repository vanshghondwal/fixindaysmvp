/// Active service: the current en-route / arrived / in-progress booking.
///
/// Status advances are guarded by the shared [canTransition] state machine:
/// En route -> Arrived -> Verify arrival code -> Start -> Complete.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import '../widgets/booking_card.dart';
import 'arrival_verify_screen.dart';

class ActiveServiceScreen extends StatefulWidget {
  const ActiveServiceScreen({super.key});

  @override
  State<ActiveServiceScreen> createState() => _ActiveServiceScreenState();
}

class _ActiveServiceScreenState extends State<ActiveServiceScreen> {
  late Future<Booking?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Booking?> _load() async {
    final state = context.read<PartnerState>();
    final upcoming = await state.ops.upcomingBookings(state.user!.id);
    for (final b in upcoming) {
      if (b.status == BookingStatus.enRoute ||
          b.status == BookingStatus.arrived ||
          b.status == BookingStatus.inProgress) {
        return b;
      }
    }
    return null;
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _transition(Booking b, BookingStatus to, String label,
      {bool destructive = false}) async {
    final t = FxLocalizations.of(context);
    final ops = context.read<PartnerState>().ops;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await fxConfirm(
      context,
      title: label,
      message: 'Move this job to "${to.name}"?',
      confirmLabel: t.t('confirm'),
      destructive: destructive,
    );
    if (!mounted) return;
    if (!ok) return;
    try {
      await ops.transitionBooking(b.id, to);
      _refresh();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Status updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger
          .showSnackBar(SnackBar(content: Text('Could not update: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active service')),
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
                    icon: Icons.directions_car_outlined,
                    title: 'No active job',
                    message:
                        'When you mark a booking en route, it will appear here.',
                    actionLabel:
                        FxLocalizations.of(context).t('retry'),
                    onAction: _refresh,
                  );
                }
                return _body(b);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(Booking b) {
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
                Text('Contact (demo): ${c['maskedPhone']}',
                    style: FxText.caption),
                const Divider(height: 20),
                const Text('Service address', style: FxText.subtitle),
                const SizedBox(height: 4),
                Text(b.addressSnapshot, style: FxText.body),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Job summary', style: FxText.subtitle),
                const SizedBox(height: 8),
                BookingTotals(booking: b),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._actions(b),
        ],
      ),
    );
  }

  List<Widget> _actions(Booking b) {
    switch (b.status) {
      case BookingStatus.enRoute:
        return [
          FxButton(
            label: 'Mark arrived',
            icon: Icons.location_on_outlined,
            onPressed: () =>
                _transition(b, BookingStatus.arrived, 'Mark arrived'),
          ),
          const SizedBox(height: 12),
          FxButton(
            label: 'Cancel booking',
            kind: FxButtonKind.destructive,
            onPressed: () => _transition(
                b, BookingStatus.cancelled, 'Cancel booking',
                destructive: true),
          ),
        ];
      case BookingStatus.arrived:
        return [
          FxButton(
            label: 'Verify arrival code',
            icon: Icons.pin_outlined,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(
                  builder: (_) =>
                      ArrivalVerifyScreen(bookingId: b.id),
                ))
                .then((ok) {
              if (ok == true) _refresh();
            }),
          ),
          const SizedBox(height: 12),
          FxButton(
            label: 'Cancel booking',
            kind: FxButtonKind.destructive,
            onPressed: () => _transition(
                b, BookingStatus.cancelled, 'Cancel booking',
                destructive: true),
          ),
        ];
      case BookingStatus.inProgress:
        return [
          FxButton(
            label: 'Complete service',
            icon: Icons.check_circle_outline,
            onPressed: () => _transition(
                b, BookingStatus.completed, 'Complete service'),
          ),
        ];
      default:
        return [];
    }
  }
}
