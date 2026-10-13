/// Dispute / support ticket: booking picker, category, description.
///
/// Photo evidence upload is honestly disabled — it needs Firebase Storage
/// configuration (see FIREBASE_SETUP.md).
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

const _categories = [
  'Payment issue',
  'Service quality',
  'Provider didn\'t arrive',
  'Safety concern',
  'Pricing dispute',
  'Other',
];

class DisputeScreen extends StatefulWidget {
  final Booking? booking;

  const DisputeScreen({super.key, this.booking});

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  late Future<List<Booking>> _bookingsFuture;
  String? _selectedBookingId;
  String _category = _categories.first;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedBookingId = widget.booking?.id;
    _bookingsFuture = _loadBookings();
  }

  Future<List<Booking>> _loadBookings() async {
    final app = context.read<AppState>();
    final all =
        await app.repos.bookings.myBookings(app.user!.id);
    return all
        .where((b) =>
            b.status == BookingStatus.completed ||
            b.status == BookingStatus.cancelled)
        .toList();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final app = context.read<AppState>();
      final ticket =
          await app.repos.support.createTicket(
        userId: app.user!.id,
        userRole: UserRole.customer,
        bookingId: _selectedBookingId,
        category: _category,
        description: _descCtrl.text.trim(),
        evidenceUrls: const [],
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Ticket ${ticket.id} created — we\'ll look into it.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('reportIssue'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(FxSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const Text('Related booking (optional)',
                        style: FxText.subtitle),
                    const SizedBox(height: 6),
                    FutureBuilder<List<Booking>>(
                      future: _bookingsFuture,
                      builder: (_, snap) {
                        final waiting = snap.connectionState ==
                            ConnectionState.waiting;
                        final list = snap.data ?? [];
                        return DropdownButtonFormField<
                            String>(
                          initialValue: _selectedBookingId,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: FxColors.white,
                          ),
                          hint: Text(waiting
                              ? 'Loading bookings…'
                              : 'Select a booking'),
                          items: [
                            const DropdownMenuItem<
                                String>(
                              value: null,
                              child:
                                  const Text('No specific booking'),
                            ),
                            ...list.map((b) =>
                                DropdownMenuItem(
                                  value: b.id,
                                  child: Text(
                                    '${b.id} · ${b.providerName} · ${DateFormat('d MMM').format(b.scheduledAt)}',
                                    overflow: TextOverflow
                                        .ellipsis,
                                  ),
                                )),
                          ],
                          onChanged: (v) => setState(
                              () =>
                                  _selectedBookingId =
                                      v),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Category',
                        style: FxText.subtitle),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: FxColors.white,
                      ),
                      items: _categories
                          .map((c) => DropdownMenuItem(
                              value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(
                          () => _category = v ?? _categories.first),
                    ),
                    const SizedBox(height: 16),
                    FxTextField(
                      controller: _descCtrl,
                      label: 'Describe the issue',
                      hint:
                          'What happened? Include dates and details.',
                      maxLines: 4,
                      validator: (v) => validateRequired(
                          v, 'Description'),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding:
                          const EdgeInsets.all(FxSpacing.md),
                      decoration: BoxDecoration(
                        color: FxColors.background,
                        border: Border.all(
                            color: FxColors.borders),
                        borderRadius: BorderRadius.circular(
                            FxRadius.md),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                              Icons
                                  .add_photo_alternate_outlined,
                              color:
                                  FxColors.secondaryText),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Photo evidence uploads need Firebase '
                              'Storage — see FIREBASE_SETUP.md.',
                              style: FxText.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(
                              color: FxColors.error)),
                    ],
                    const SizedBox(height: 24),
                    FxButton(
                      label: 'Submit ticket',
                      loading: _submitting,
                      onPressed:
                          _submitting ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
