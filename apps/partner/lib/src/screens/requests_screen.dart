/// Incoming booking requests: pending bookings with accept / reject actions.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import '../widgets/booking_card.dart';
import 'request_detail_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  late Future<List<Booking>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Booking>> _load() {
    final state = context.read<PartnerState>();
    return state.ops.incomingRequests(state.user!.id);
  }

  void _refresh() => setState(() => _future = _load());

  String _customerLine(Booking b) {
    final state = context.read<PartnerState>();
    final c = state.ops.demoCustomerContact(b.customerId);
    return '${c['name']} • Full contact is shared after you accept '
        '(demo: ${c['maskedPhone']})';
  }

  Future<void> _respond(Booking b, bool accept) async {
    final t = FxLocalizations.of(context);
    final ok = await fxConfirm(
      context,
      title: accept ? t.t('accept') : t.t('reject'),
      message: accept
          ? 'Accept this booking request? The customer will be notified.'
          : 'Reject this booking request? This cannot be undone.',
      confirmLabel: accept ? t.t('accept') : t.t('reject'),
      destructive: !accept,
    );
    if (!ok) return;
    if (!mounted) return;
    try {
      final state = context.read<PartnerState>();
      await state.ops.respondToBooking(b.id, accept);
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(accept
                ? 'Booking accepted.'
                : 'Booking rejected.')),
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
      appBar: AppBar(title: Text(t.t('requests'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
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
                  final items = snap.data!;
                  if (items.isEmpty) {
                    return SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      child: EmptyState(
                        icon: Icons.inbox_outlined,
                        title: 'No pending requests',
                        message:
                            'New booking requests from customers will appear here.',
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
                    itemBuilder: (context, i) {
                      final b = items[i];
                      return BookingCard(
                        booking: b,
                        subtitle: _customerLine(b),
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(
                              builder: (_) =>
                                  RequestDetailScreen(bookingId: b.id),
                            ))
                            .then((_) => _refresh()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FxButton(
                              label: t.t('accept'),
                              onPressed: () => _respond(b, true),
                            ),
                            const SizedBox(width: 8),
                            FxButton(
                              label: t.t('reject'),
                              kind: FxButtonKind.destructive,
                              onPressed: () => _respond(b, false),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
