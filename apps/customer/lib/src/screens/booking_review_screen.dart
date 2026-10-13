/// Booking review: provider, address, schedule, line items, totals and
/// terms — before payment.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../state/app_state.dart';
import 'payment_screen.dart';

class BookingReviewScreen extends StatelessWidget {
  final BookingDraft draft;

  const BookingReviewScreen({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    final d = draft;
    return VoiceScreenTag(
      screenKey: 'review',
      child: Scaffold(
      appBar: AppBar(title: Text(t.t('confirmBooking'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(FxSpacing.md),
              children: [
                FxCard(
                  child: Row(
                    children: [
                      FxAvatar(
                          name: d.provider.businessName,
                          radius: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(d.provider.businessName,
                                style: FxText.subtitle),
                            Text(
                              '${d.provider.ratingAvg.toStringAsFixed(1)} '
                              '(${d.provider.ratingCount})',
                              style: FxText.caption,
                            ),
                          ],
                        ),
                      ),
                      VerifiedBadge(
                          verified:
                              d.provider.isVerified),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FxCard(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _row(Icons.location_on_outlined,
                          'Address', d.address.short),
                      const Divider(),
                      _row(
                          Icons.calendar_month_outlined,
                          'Scheduled',
                          DateFormat(
                                  'EEE, d MMM yyyy · h:mm a')
                              .format(d.scheduledAt)),
                      if (d.notes.isNotEmpty) ...[
                        const Divider(),
                        _row(Icons.note_outlined, 'Notes',
                            d.notes),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const FxSectionHeader(title: 'Services'),
                const SizedBox(height: 4),
                FxCard(
                  child: Column(
                    children: d.items
                        .map((i) => LineItemRow(item: i))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
                FxCard(
                  child: Column(
                    children: [
                      _totalRow(t.t('subtotal'),
                          d.totals.subtotalPaise),
                      _totalRow(t.t('platformFee'),
                          d.totals.platformFeePaise),
                      const Divider(),
                      _totalRow(t.t('total'),
                          d.totals.totalPaise,
                          bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'By confirming you agree to the FixinDays booking terms: '
                  'free cancellation until the provider accepts, and payment '
                  'is due after the service for cash bookings.',
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
                  label: 'Pay & Confirm',
                  onPressed: () =>
                      Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PaymentScreen(draft: d),
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

  Widget _row(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: FxColors.secondaryText),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: FxText.caption),
              const SizedBox(height: 2),
              Text(value, style: FxText.body),
            ],
          ),
        ),
      ],
    );
  }

  Widget _totalRow(String label, int paise, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: bold ? FxText.title : FxText.body),
          Text(formatInr(paise),
              style: bold
                  ? FxText.price.copyWith(fontSize: 18)
                  : FxText.body),
        ],
      ),
    );
  }
}
