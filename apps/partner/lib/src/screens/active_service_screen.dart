/// Active service — maximalism edition.
///
/// Bold gradient status header, vertical timeline of job progress, customer
/// card, job summary, and vibrant action buttons. Status advances are guarded
/// by the shared [canTransition] state machine:
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
    return MaxScaffold(
      appBar: AppBar(
        backgroundColor: MaxColors.cream,
        foregroundColor: MaxColors.ink,
        elevation: 0,
        title: const Text('Active service', style: MaxText.title),
      ),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: FutureBuilder<Booking?>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SingleChildScrollView(
                    padding: EdgeInsets.all(16),
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
    final services = b.items.map((i) => i.serviceName).join(', ');
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _statusHero(b, services),
          const SizedBox(height: 16),
          const MaxSectionHeader(title: 'Job progress'),
          MaxCard(
            shadowColor: MaxColors.sky,
            child: _timeline(b.status),
          ),
          const SizedBox(height: 16),
          MaxCard(
            shadowColor: MaxColors.purple,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: MaxColors.purpleSoft,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.person_outline,
                          color: MaxColors.purple, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text('CUSTOMER',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: MaxColors.inkFaint,
                                  letterSpacing: 1.1)),
                          Text(c['name']!,
                              style: MaxText.title),
                        ],
                      ),
                    ),
                    MaxPill(
                      label: formatInr(b.totalPaise),
                      bg: MaxColors.mintSoft,
                      fg: const Color(0xFF1E9E50),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 16, color: MaxColors.inkFaint),
                    const SizedBox(width: 6),
                    Text('Contact (demo): ${c['maskedPhone']}',
                        style: MaxText.body),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 16, color: MaxColors.inkFaint),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(b.addressSnapshot,
                          style: MaxText.body),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          MaxCard(
            shadowColor: MaxColors.sun,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Job summary', style: MaxText.title),
                const SizedBox(height: 8),
                BookingTotals(booking: b),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._actions(b),
        ],
      ),
    );
  }

  /// Gradient header with live status pill + service + slot.
  Widget _statusHero(Booking b, String services) {
    final (pillBg, pillFg, label) = switch (b.status) {
      BookingStatus.enRoute =>
        (MaxColors.skySoft, MaxColors.sky, 'EN ROUTE'),
      BookingStatus.arrived =>
        (MaxColors.sunSoft, const Color(0xFFB8860B), 'ARRIVED'),
      BookingStatus.inProgress =>
        (MaxColors.mintSoft, const Color(0xFF1E9E50), 'IN PROGRESS'),
      _ => (MaxColors.creamDeep, MaxColors.inkSoft, b.status.name.toUpperCase()),
    };
    final gradient = switch (b.status) {
      BookingStatus.enRoute => MaxColors.oceanGradient,
      BookingStatus.arrived => MaxColors.heroGradient,
      BookingStatus.inProgress => MaxColors.mintGradient,
      _ => MaxColors.inkGradient,
    };
    return MaxHeroCard(
      gradient: gradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MaxPill(label: label, bg: pillBg, fg: pillFg),
          const SizedBox(height: 10),
          Text(services,
              style: MaxText.onGradientBig.copyWith(fontSize: 22),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule_outlined,
                  color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(formatSlot(b.scheduledAt),
                  style: MaxText.onGradient),
            ],
          ),
        ],
      ),
    );
  }

  /// Vertical timeline: En route → Arrived → In progress → Completed.
  Widget _timeline(BookingStatus status) {
    const steps = [
      (BookingStatus.enRoute, 'En route', Icons.directions_car),
      (BookingStatus.arrived, 'Arrived', Icons.location_on_outlined),
      (BookingStatus.inProgress, 'Work in progress', Icons.handyman),
      (BookingStatus.completed, 'Completed', Icons.check_circle_outline),
    ];
    final order = [
      BookingStatus.enRoute,
      BookingStatus.arrived,
      BookingStatus.inProgress,
      BookingStatus.completed,
    ];
    final currentIdx = order.indexOf(status);
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _timelineRow(
            icon: steps[i].$3,
            label: steps[i].$2,
            done: i < currentIdx,
            current: i == currentIdx,
          ),
          if (i < steps.length - 1)
            Container(
              margin: const EdgeInsets.only(left: 21),
              width: 2,
              height: 18,
              color: i < currentIdx
                  ? MaxColors.mint
                  : MaxColors.line,
            ),
        ],
      ],
    );
  }

  Widget _timelineRow(
      {required IconData icon,
      required String label,
      required bool done,
      required bool current}) {
    final Color dotBg;
    final Color dotFg;
    if (done) {
      dotBg = MaxColors.mint;
      dotFg = Colors.white;
    } else if (current) {
      dotBg = MaxColors.orange;
      dotFg = Colors.white;
    } else {
      dotBg = MaxColors.creamDeep;
      dotFg = MaxColors.inkFaint;
    }
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: dotBg,
            shape: BoxShape.circle,
            boxShadow: (done || current)
                ? maxShadow(dotBg, blur: 10)
                : null,
          ),
          child: Icon(
              done ? Icons.check : icon, color: dotFg, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: (done || current)
                ? MaxText.title
                : MaxText.title.copyWith(color: MaxColors.inkFaint),
          ),
        ),
        if (current)
          const MaxPill(
              label: 'NOW',
              bg: MaxColors.orangeSoft,
              fg: MaxColors.orangeDeep),
        if (done)
          const Icon(Icons.check_circle,
              color: MaxColors.mint, size: 20),
      ],
    );
  }

  List<Widget> _actions(Booking b) {
    switch (b.status) {
      case BookingStatus.enRoute:
        return [
          MaxButton(
            label: 'Mark arrived',
            icon: Icons.location_on_outlined,
            onPressed: () =>
                _transition(b, BookingStatus.arrived, 'Mark arrived'),
          ),
          const SizedBox(height: 12),
          _ghostDestructive(
            label: 'Cancel booking',
            onPressed: () => _transition(
                b, BookingStatus.cancelled, 'Cancel booking',
                destructive: true),
          ),
        ];
      case BookingStatus.arrived:
        return [
          MaxButton(
            label: 'Verify arrival code',
            icon: Icons.pin_outlined,
            gradient: MaxColors.oceanGradient,
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
          _ghostDestructive(
            label: 'Cancel booking',
            onPressed: () => _transition(
                b, BookingStatus.cancelled, 'Cancel booking',
                destructive: true),
          ),
        ];
      case BookingStatus.inProgress:
        return [
          MaxButton(
            label: 'Complete service',
            icon: Icons.check_circle_outline,
            gradient: MaxColors.mintGradient,
            onPressed: () => _transition(
                b, BookingStatus.completed, 'Complete service'),
          ),
        ];
      default:
        return [];
    }
  }

  /// Soft destructive button — coral tint, no heavy gradient.
  Widget _ghostDestructive(
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: MaxColors.coral,
          side: const BorderSide(color: MaxColors.coral, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w800),
        ),
        child: Text(label),
      ),
    );
  }
}
