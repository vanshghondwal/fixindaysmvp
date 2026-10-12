/// Shared booking presentation widgets for the partner app.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Formats a scheduled slot in the device locale, e.g. "Mon, 13 Oct • 2:30 PM".
String formatSlot(DateTime dt) =>
    DateFormat('EEE, d MMM • h:mm a').format(dt.toLocal());

/// Formats a date without time, e.g. "13 Oct 2026".
String formatDay(DateTime dt) => DateFormat('d MMM yyyy').format(dt.toLocal());

/// Card summarising a booking. Used by requests / upcoming / history lists.
class BookingCard extends StatelessWidget {
  final Booking booking;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.booking,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FxCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  booking.items.map((i) => i.serviceName).join(', '),
                  style: FxText.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusChip.booking(booking.status),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 14, color: FxColors.secondaryText),
              const SizedBox(width: 4),
              Text(formatSlot(booking.scheduledAt), style: FxText.caption),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: FxColors.secondaryText),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  booking.addressSnapshot,
                  style: FxText.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: FxText.caption),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(formatInr(booking.totalPaise), style: FxText.price),
              if (trailing != null) trailing!,
            ],
          ),
        ],
      ),
    );
  }
}

/// Line items + subtotal / platform fee / total for a booking.
class BookingTotals extends StatelessWidget {
  final Booking booking;

  const BookingTotals({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...booking.items.map((i) => LineItemRow(item: i)),
        const Divider(),
        _row(t.t('subtotal'), formatInr(booking.subtotalPaise)),
        _row(t.t('platformFee'), formatInr(booking.platformFeePaise)),
        const SizedBox(height: 4),
        _row(t.t('total'), formatInr(booking.totalPaise), bold: true),
      ],
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = bold ? FxText.price : FxText.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? FxText.subtitle : FxText.body),
          Text(value, style: style),
        ],
      ),
    );
  }
}
