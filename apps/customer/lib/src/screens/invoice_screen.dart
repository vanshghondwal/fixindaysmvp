/// Booking invoice / receipt view with GST breakdown.
///
/// Mock data only; in production this renders the booking's real
/// line items.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';

class InvoiceScreen extends StatelessWidget {
  final String bookingId;

  const InvoiceScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    // Mock line items (paise).
    const items = [
      ('Switchboard repair', 1, 29900),
      ('Ceiling fan installation', 1, 34900),
    ];
    const subtotal = 64800;
    const platformFee = 4900;
    const gst = 12546; // 18% on (subtotal + platformFee)
    const total = 82246;

    return MaxScaffold(
      appBar: AppBar(
        backgroundColor: MaxColors.cream,
        foregroundColor: MaxColors.ink,
        elevation: 0,
        title: const Text('Invoice', style: MaxText.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                MaxHeroCard(
                  gradient: MaxColors.inkGradient,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text('FixinDays',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white)),
                          MaxPill(
                            label: 'PAID',
                            bg: MaxColors.mint,
                            fg: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Invoice #$bookingId',
                          style: MaxText.onGradient
                              .copyWith(fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('Issued on 14 Oct 2026',
                          style: MaxText.onGradient.copyWith(
                              fontSize: 12,
                              color: Colors.white
                                  .withValues(alpha: 0.7))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const MaxSectionHeader(title: 'Line items'),
                MaxCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        _row(items[i].$1,
                            'Qty ${items[i].$2}',
                            formatInr(items[i].$3)),
                        if (i < items.length - 1)
                          const Divider(
                              height: 20,
                              color: MaxColors.line),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const MaxSectionHeader(title: 'Breakdown'),
                MaxCard(
                  child: Column(
                    children: [
                      _row('Subtotal', '', formatInr(subtotal)),
                      const SizedBox(height: 10),
                      _row('Platform fee', '', formatInr(platformFee)),
                      const SizedBox(height: 10),
                      _row('GST (18%)', '', formatInr(gst)),
                      const Divider(
                          height: 24, color: MaxColors.line),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total paid',
                              style: MaxText.title),
                          Text(formatInr(total),
                              style: MaxText.bigNumber.copyWith(
                                  fontSize: 22,
                                  color: MaxColors.orangeDeep)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                MaxButton(
                  label: 'Download PDF',
                  icon: Icons.download_outlined,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Invoice download will be available soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String subtitle, String amount) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: MaxText.title.copyWith(fontSize: 14)),
              if (subtitle.isNotEmpty)
                Text(subtitle, style: MaxText.caption),
            ],
          ),
        ),
        Text(amount,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: MaxColors.ink)),
      ],
    );
  }
}
