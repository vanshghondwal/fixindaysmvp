/// Schedule step: next 7 days + hourly time slots, optional notes.
///
/// Slot conflicts are checked honestly against the customer's existing
/// bookings; availability itself is confirmed by the provider after booking.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'booking_review_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final ProviderProfile provider;
  final List<BookingLineItem> items;
  final Totals totals;
  final Address address;

  const ScheduleScreen({
    super.key,
    required this.provider,
    required this.items,
    required this.totals,
    required this.address,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late final List<DateTime> _days;
  int _dayIndex = 0;
  DateTime? _slot;
  final _notesCtrl = TextEditingController();
  late Future<List<DateTime>> _existingStarts;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _days = List.generate(
        7, (i) => DateTime(now.year, now.month, now.day + i));
    _existingStarts = _loadExisting();
  }

  Future<List<DateTime>> _loadExisting() async {
    final app = context.read<AppState>();
    final bookings =
        await app.repos.bookings.myBookings(app.user!.id);
    return bookings
        .where((b) => b.isActive)
        .map((b) => b.scheduledAt)
        .toList();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  List<DateTime> _slotsFor(DateTime day) {
    return List.generate(11, (i) {
      final hour = 9 + i; // 9 AM … 7 PM
      final slot =
          DateTime(day.year, day.month, day.day, hour);
      return slot;
    }).where((s) => s.isAfter(DateTime.now())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    final day = _days[_dayIndex];
    final slots = _slotsFor(day);
    return VoiceScreenTag(
      screenKey: 'schedule',
      child: Scaffold(
      appBar: AppBar(title: Text(t.t('selectSlot'))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(FxSpacing.md),
              children: [
                const Text('Pick a day', style: FxText.title),
                const SizedBox(height: 8),
                SizedBox(
                  height: 72,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _days.length,
                    itemBuilder: (_, i) {
                      final d = _days[i];
                      final selected = i == _dayIndex;
                      return Padding(
                        padding:
                            const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(DateFormat('EEE').format(d),
                                  style: const TextStyle(
                                      fontSize: 11)),
                              Text(
                                  DateFormat('d MMM')
                                      .format(d),
                                  style: const TextStyle(
                                      fontWeight:
                                          FontWeight.w700)),
                            ],
                          ),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            _dayIndex = i;
                            _slot = null;
                          }),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Pick a time', style: FxText.title),
                const SizedBox(height: 8),
                if (slots.isEmpty)
                  const Text(
                      'No slots left today — try another day.'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: slots.map((s) {
                    final selected = _slot == s;
                    return ChoiceChip(
                      label: Text(
                          DateFormat('h:mm a').format(s)),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _slot = s),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<DateTime>>(
                  future: _existingStarts,
                  builder: (_, snap) {
                    final starts = snap.data ?? [];
                    if (_slot != null &&
                        hasSlotConflict(
                          requestedStart: _slot!,
                          existingStarts: starts,
                        )) {
                      return Container(
                        margin: const EdgeInsets.only(
                            bottom: 16),
                        padding: const EdgeInsets.all(
                            FxSpacing.md),
                        decoration: BoxDecoration(
                          color: FxColors.warning
                              .withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(
                                  FxRadius.md),
                        ),
                        child: const Text(
                          'Heads up: you already have a booking around '
                          'this time. The provider will still need to '
                          'confirm the slot.',
                          style: TextStyle(
                              fontSize: 13,
                              color: FxColors.navy),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                FxTextField(
                  controller: _notesCtrl,
                  label: 'Notes for the provider (optional)',
                  hint: 'Gate code, parking info…',
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Slot availability is confirmed by the provider after '
                  'you book — this isn\'t a live calendar yet.',
                  style: FxText.caption,
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(FxSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: FxButton(
                  label: 'Continue',
                  onPressed: _slot == null
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  BookingReviewScreen(
                                draft: BookingDraft(
                                  provider: widget.provider,
                                  items: widget.items,
                                  totals: widget.totals,
                                  address: widget.address,
                                  scheduledAt: _slot!,
                                  notes: _notesCtrl.text
                                      .trim(),
                                ),
                              ),
                            ),
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
