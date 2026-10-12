/// Booking confirmation: real booking ID, provider, time, address and
/// payment status.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'booking_detail_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;
  final bool cashOnService;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    this.cashOnService = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    final b = booking;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(FxSpacing.lg),
          children: [
            if (AppConfig.useDemoData) const DemoBanner(),
            const SizedBox(height: 24),
            const Icon(Icons.check_circle,
                size: 80, color: FxColors.primary),
            const SizedBox(height: 16),
            Text(t.t('bookingConfirmed'),
                style: FxText.headline,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'The provider will confirm your slot shortly.',
              style: FxText.body
                  .copyWith(color: FxColors.secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FxCard(
              child: Column(
                children: [
                  _row('Booking ID', b.id),
                  const Divider(),
                  _row('Provider', b.providerName),
                  const Divider(),
                  _row(
                      'Scheduled',
                      DateFormat('EEE, d MMM yyyy · h:mm a')
                          .format(b.scheduledAt)),
                  const Divider(),
                  _row('Address', b.addressSnapshot),
                  const Divider(),
                  _row(
                      'Payment',
                      cashOnService
                          ? 'Cash on service — pay after the job'
                          : b.paymentStatus.name),
                  const Divider(),
                  _row('Total',
                      formatInr(b.totalPaise),
                      bold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FxButton(
              label: 'View booking',
              onPressed: () =>
                  Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => BookingDetailScreen(
                      bookingId: b.id),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FxButton(
              label: 'Back to home',
              kind: FxButtonKind.outlined,
              onPressed: () => Navigator.of(context)
                  .popUntil((r) => r.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: FxText.caption),
          ),
          Expanded(
            child: Text(value,
                style: bold ? FxText.price : FxText.body),
          ),
        ],
      ),
    );
  }
}
