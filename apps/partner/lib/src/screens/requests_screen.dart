/// Incoming booking requests — maximalism edition.
///
/// Colorful request cards with NEW pills, customer + payout highlights,
/// and bold gradient accept / soft reject actions.
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

  Future<void> _respond(Booking b, bool accept) async {
    final t = FxLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
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
      messenger.showSnackBar(
        SnackBar(
            content: Text(accept
                ? 'Booking accepted. 🎉'
                : 'Booking rejected.')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger
          .showSnackBar(SnackBar(content: Text('Could not update: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return MaxScaffold(
      appBar: AppBar(
        backgroundColor: MaxColors.cream,
        foregroundColor: MaxColors.ink,
        elevation: 0,
        title: Text(t.t('requests'), style: MaxText.title),
      ),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: RefreshIndicator(
              color: MaxColors.orange,
              backgroundColor: MaxColors.cardWhite,
              onRefresh: () async => _refresh(),
              child: FutureBuilder<List<Booking>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SingleChildScrollView(
                      padding: EdgeInsets.all(16),
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, i) =>
                        _requestCard(items[i], t),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestCard(Booking b, FxLocalizations t) {
    final state = context.read<PartnerState>();
    final c = state.ops.demoCustomerContact(b.customerId);
    final services = b.items.map((i) => i.serviceName).join(', ');
    final (bg, fg) = MaxColors.pairFor(b.id.hashCode.abs());
    return MaxCard(
      shadowColor: fg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.handyman, color: fg, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(services,
                        style: MaxText.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('${c['name']} • ${c['maskedPhone']}',
                        style: MaxText.body),
                  ],
                ),
              ),
              const MaxPill(
                  label: 'NEW',
                  bg: MaxColors.coralSoft,
                  fg: MaxColors.coral),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MaxColors.cream,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _infoRow(Icons.schedule_outlined, formatSlot(b.scheduledAt)),
                const SizedBox(height: 6),
                _infoRow(Icons.place_outlined, b.addressSnapshot),
                const SizedBox(height: 6),
                _infoRow(Icons.payments_outlined,
                    'Payout ${formatInr(b.totalPaise)}',
                    bold: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MaxButton(
                  label: t.t('accept'),
                  icon: Icons.check,
                  gradient: MaxColors.mintGradient,
                  onPressed: () => _respond(b, true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _respond(b, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MaxColors.coral,
                    side: const BorderSide(
                        color: MaxColors.coral, width: 1.5),
                    padding:
                        const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  child: Text(t.t('reject')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (_) =>
                        RequestDetailScreen(bookingId: b.id),
                  ))
                  .then((_) => _refresh()),
              style: TextButton.styleFrom(
                foregroundColor: MaxColors.inkSoft,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('View full details'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {bool bold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: MaxColors.inkFaint),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: bold ? MaxText.title.copyWith(fontSize: 14) : MaxText.body,
          ),
        ),
      ],
    );
  }
}
