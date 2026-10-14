/// Help & support: create a ticket + list my tickets.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import '../widgets/booking_card.dart' show formatDay;

const _categories = [
  'Booking issue',
  'Payment',
  'Verification',
  'Technical',
  'Other',
];

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  String _category = _categories.first;
  String? _bookingId;
  bool _submitting = false;
  late Future<_SupportData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<_SupportData> _load() async {
    final state = context.read<PartnerState>();
    final uid = state.user!.id;
    final tickets = await state.support.myTickets(uid);
    final upcoming = await state.ops.upcomingBookings(uid);
    final history = await state.ops.bookingHistory(uid);
    return _SupportData(
        tickets: tickets,
        bookings: [...upcoming, ...history]);
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final state = context.read<PartnerState>();
      await state.support.createTicket(
        userId: state.user!.id,
        userRole: UserRole.provider,
        bookingId: _bookingId,
        category: _category,
        description: _descCtrl.text.trim(),
      );
      _descCtrl.clear();
      setState(() => _bookingId = null);
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket submitted.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not submit: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Color _statusColor(TicketStatus s) {
    return switch (s) {
      TicketStatus.open => FxColors.warning,
      TicketStatus.inProgress => FxColors.navy,
      TicketStatus.resolved => FxColors.darkGreen,
      TicketStatus.closed => FxColors.secondaryText,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('helpSupport'))),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<_SupportData>(
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
                final d = snap.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(FxSpacing.lg),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      const FxSectionHeader(
                          title: 'Raise a ticket'),
                      const SizedBox(height: 8),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            const Text('Category',
                                style: FxText.subtitle),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _category,
                              items: _categories
                                  .map((c) =>
                                      DropdownMenuItem(
                                        value: c,
                                        child: Text(c),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(
                                  () => _category = v!),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                                'Related booking (optional)',
                                style: FxText.subtitle),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String?>(
                              initialValue: _bookingId,
                              decoration: const InputDecoration(
                                  hintText:
                                      'Select a booking'),
                              items: <DropdownMenuItem<String?>>[
                                const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('None')),
                                ...d.bookings.map<
                                        DropdownMenuItem<String?>>(
                                    (b) =>
                                        DropdownMenuItem<String?>(
                                          value: b.id,
                                          child: Text(
                                            '${b.items.map((i) => i.serviceName).join(', ')} • ${b.status.name}',
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        )),
                              ],
                              onChanged: (v) => setState(
                                  () => _bookingId = v),
                            ),
                            const SizedBox(height: 16),
                            FxTextField(
                              controller: _descCtrl,
                              label: 'Describe the issue',
                              hint:
                                  'What happened? What do you need help with?',
                              maxLines: 4,
                              validator: (v) => validateRequired(
                                  v, 'Description'),
                            ),
                            const SizedBox(height: 16),
                            FxButton(
                              label: t.t('submit'),
                              loading: _submitting,
                              onPressed:
                                  _submitting ? null : _submit,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const FxSectionHeader(
                          title: 'My tickets'),
                      const SizedBox(height: 8),
                      if (d.tickets.isEmpty)
                        const EmptyState(
                          icon: Icons.support_agent_outlined,
                          title: 'No tickets yet',
                          message:
                              'Tickets you raise will appear here with their status.',
                        )
                      else
                        ...d.tickets.map((ticket) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: FxSpacing.sm),
                              child: FxCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                              ticket.category,
                                              style:
                                                  FxText.subtitle),
                                        ),
                                        StatusChip(
                                          label: ticket.status.name
                                              .toUpperCase(),
                                          color: _statusColor(
                                              ticket.status),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(ticket.description,
                                        style: FxText.body),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Opened ${formatDay(ticket.createdAt)}',
                                      style: FxText.caption,
                                    ),
                                  ],
                                ),
                              ),
                            )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportData {
  final List<SupportTicket> tickets;
  final List<Booking> bookings;

  const _SupportData({required this.tickets, required this.bookings});
}
