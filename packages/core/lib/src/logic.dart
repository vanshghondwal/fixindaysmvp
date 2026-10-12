/// Pure-Dart business logic for FixinDays.
///
/// No Flutter imports here — this file is unit-tested without a device.
library;

import 'models.dart';

/// Result of a totals calculation. All money in paise.
class Totals {
  final int subtotalPaise;
  final int platformFeePaise;
  final int discountPaise;
  final int totalPaise;

  const Totals({
    required this.subtotalPaise,
    required this.platformFeePaise,
    required this.discountPaise,
    required this.totalPaise,
  });
}

/// Calculates booking totals from line items.
/// [commissionBps]: basis points, e.g. 1000 = 10%.
Totals calcTotals(
  List<BookingLineItem> items, {
  required int commissionBps,
  int discountPaise = 0,
}) {
  final subtotal =
      items.fold<int>(0, (sum, i) => sum + i.lineTotalPaise);
  final fee = (subtotal * commissionBps) ~/ 10000;
  final total = (subtotal + fee - discountPaise).clamp(0, 1 << 62);
  return Totals(
    subtotalPaise: subtotal,
    platformFeePaise: fee,
    discountPaise: discountPaise,
    totalPaise: total,
  );
}

/// Allowed booking status transitions, guarded by actor role.
///
/// Customers may: cancel (from early states), dispute (from completed).
/// Providers may: accept/reject (from pending), move through the service
/// lifecycle (confirmed -> enRoute -> arrived -> inProgress -> completed),
/// cancel (from early states).
/// Admins may: move to disputed, cancel, force transitions for operations.
bool canTransition(BookingStatus from, BookingStatus to, UserRole actor) {
  const customerAllowed = {
    BookingStatus.pending: [BookingStatus.cancelled],
    BookingStatus.accepted: [BookingStatus.cancelled],
    BookingStatus.confirmed: [BookingStatus.cancelled],
    BookingStatus.completed: [BookingStatus.disputed],
  };
  const providerAllowed = {
    BookingStatus.pending: [BookingStatus.accepted, BookingStatus.rejected],
    BookingStatus.accepted: [BookingStatus.confirmed, BookingStatus.cancelled],
    BookingStatus.confirmed: [
      BookingStatus.enRoute,
      BookingStatus.cancelled,
    ],
    BookingStatus.enRoute: [BookingStatus.arrived, BookingStatus.cancelled],
    BookingStatus.arrived: [BookingStatus.inProgress, BookingStatus.cancelled],
    BookingStatus.inProgress: [BookingStatus.completed],
  };
  const adminAllowed = {
    BookingStatus.pending: [BookingStatus.cancelled, BookingStatus.disputed],
    BookingStatus.accepted: [BookingStatus.cancelled, BookingStatus.disputed],
    BookingStatus.confirmed: [BookingStatus.cancelled, BookingStatus.disputed],
    BookingStatus.completed: [BookingStatus.disputed],
    BookingStatus.disputed: [BookingStatus.completed, BookingStatus.cancelled],
    BookingStatus.inProgress: [BookingStatus.cancelled, BookingStatus.disputed],
  };

  final table = switch (actor) {
    UserRole.customer => customerAllowed,
    UserRole.provider => providerAllowed,
    UserRole.admin => adminAllowed,
  };
  return table[from]?.contains(to) ?? false;
}

/// A customer may review a booking only when it is completed, they own it,
/// and no review exists yet for that booking.
bool isReviewEligible({
  required Booking booking,
  required String customerId,
  required bool alreadyReviewed,
}) {
  return booking.status == BookingStatus.completed &&
      booking.customerId == customerId &&
      !alreadyReviewed;
}

/// Normalizes an arrival code for comparison (trims + uppercases).
String normalizeArrivalCode(String code) =>
    code.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');

/// Compares a user-entered arrival code against the expected code.
/// Server-side, only the sha256 hash is stored; this helper is for the
/// client-side pre-check and unit tests.
bool arrivalCodeMatches(String entered, String expected) {
  final a = normalizeArrivalCode(entered);
  final b = normalizeArrivalCode(expected);
  if (a.isEmpty || b.isEmpty || a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}

/// Checks whether a requested slot conflicts with existing bookings.
/// Each booking is assumed to occupy [slotMinutes] from its start.
bool hasSlotConflict({
  required DateTime requestedStart,
  required List<DateTime> existingStarts,
  int slotMinutes = 120,
}) {
  final reqEnd = requestedStart.add(Duration(minutes: slotMinutes));
  for (final s in existingStarts) {
    final end = s.add(Duration(minutes: slotMinutes));
    if (requestedStart.isBefore(end) && s.isBefore(reqEnd)) return true;
  }
  return false;
}

/// Formats paise as an INR string, e.g. 29900 -> "₹299".
String formatInr(int paise) {
  final rupees = paise ~/ 100;
  final s = rupees.toString();
  final buf = StringBuffer();
  // Indian digit grouping: last 3, then groups of 2.
  if (s.length <= 3) {
    buf.write(s);
  } else {
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    buf.write(parts.join(','));
    buf.write(',$last3');
  }
  return '₹${buf.toString()}';
}
