/// Small maximalist bits: booking status pills with vibrant colors.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';

/// Colorful status pill for a booking status — maximalist style.
class MaxStatusPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const MaxStatusPill({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
  });

  factory MaxStatusPill.booking(BookingStatus s) {
    final (Color bg, Color fg) = switch (s) {
      BookingStatus.pending => (MaxColors.sunSoft, const Color(0xFFB8860B)),
      BookingStatus.accepted => (MaxColors.skySoft, const Color(0xFF1B7FC1)),
      BookingStatus.rejected => (MaxColors.coralSoft, MaxColors.coral),
      BookingStatus.confirmed => (MaxColors.mintSoft, const Color(0xFF1E9E50)),
      BookingStatus.enRoute => (MaxColors.purpleSoft, MaxColors.purple),
      BookingStatus.arrived => (MaxColors.purpleSoft, MaxColors.purple),
      BookingStatus.inProgress => (MaxColors.orangeSoft, MaxColors.orangeDeep),
      BookingStatus.completed => (MaxColors.mintSoft, const Color(0xFF1E9E50)),
      BookingStatus.cancelled => (MaxColors.creamDeep, MaxColors.inkSoft),
      BookingStatus.disputed => (MaxColors.coralSoft, MaxColors.coral),
    };
    return MaxStatusPill(label: s.name.toUpperCase(), bg: bg, fg: fg);
  }

  @override
  Widget build(BuildContext context) {
    return MaxPill(label: label, bg: bg, fg: fg);
  }
}
