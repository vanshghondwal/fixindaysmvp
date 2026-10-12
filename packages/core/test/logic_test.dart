import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calcTotals', () {
    test('sums line items and applies commission', () {
      final items = [
        const BookingLineItem(
            serviceId: 's1',
            serviceName: 'Switch repair',
            quantity: 2,
            unitPricePaise: 29900),
        const BookingLineItem(
            serviceId: 's2',
            serviceName: 'Fan install',
            quantity: 1,
            unitPricePaise: 49900),
      ];
      final t = calcTotals(items, commissionBps: 1000); // 10%
      expect(t.subtotalPaise, 109700);
      expect(t.platformFeePaise, 10970);
      expect(t.totalPaise, 120670);
    });

    test('empty items give zero totals', () {
      final t = calcTotals(const [], commissionBps: 1000);
      expect(t.subtotalPaise, 0);
      expect(t.totalPaise, 0);
    });

    test('discount never drives total below zero', () {
      final items = [
        const BookingLineItem(
            serviceId: 's1',
            serviceName: 'Visit',
            quantity: 1,
            unitPricePaise: 19900),
      ];
      final t = calcTotals(items, commissionBps: 1000, discountPaise: 999999);
      expect(t.totalPaise, 0);
    });
  });

  group('canTransition', () {
    test('customer can cancel a pending booking', () {
      expect(
          canTransition(
              BookingStatus.pending, BookingStatus.cancelled, UserRole.customer),
          isTrue);
    });

    test('customer cannot mark a booking completed', () {
      expect(
          canTransition(
              BookingStatus.inProgress, BookingStatus.completed, UserRole.customer),
          isFalse);
    });

    test('provider accepts pending, then moves through lifecycle', () {
      expect(
          canTransition(BookingStatus.pending, BookingStatus.accepted,
              UserRole.provider),
          isTrue);
      expect(
          canTransition(BookingStatus.confirmed, BookingStatus.enRoute,
              UserRole.provider),
          isTrue);
      expect(
          canTransition(BookingStatus.inProgress, BookingStatus.completed,
              UserRole.provider),
          isTrue);
    });

    test('provider cannot skip lifecycle steps', () {
      expect(
          canTransition(BookingStatus.confirmed, BookingStatus.completed,
              UserRole.provider),
          isFalse);
    });

    test('customer can dispute a completed booking', () {
      expect(
          canTransition(BookingStatus.completed, BookingStatus.disputed,
              UserRole.customer),
          isTrue);
    });

    test('no transitions out of terminal states', () {
      expect(
          canTransition(BookingStatus.cancelled, BookingStatus.confirmed,
              UserRole.admin),
          isFalse);
      expect(
          canTransition(BookingStatus.rejected, BookingStatus.pending,
              UserRole.provider),
          isFalse);
    });
  });

  group('isReviewEligible', () {
    Booking booking(BookingStatus s, String customerId) => Booking(
          id: 'b1',
          customerId: customerId,
          providerId: 'p1',
          providerName: 'P',
          items: const [],
          subtotalPaise: 0,
          platformFeePaise: 0,
          totalPaise: 0,
          addressSnapshot: 'addr',
          scheduledAt: DateTime.now().toUtc(),
          status: s,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        );

    test('eligible when completed, owned, not reviewed', () {
      expect(
          isReviewEligible(
              booking: booking(BookingStatus.completed, 'u1'),
              customerId: 'u1',
              alreadyReviewed: false),
          isTrue);
    });

    test('not eligible when already reviewed', () {
      expect(
          isReviewEligible(
              booking: booking(BookingStatus.completed, 'u1'),
              customerId: 'u1',
              alreadyReviewed: true),
          isFalse);
    });

    test('not eligible when not completed', () {
      expect(
          isReviewEligible(
              booking: booking(BookingStatus.inProgress, 'u1'),
              customerId: 'u1',
              alreadyReviewed: false),
          isFalse);
    });

    test('not eligible for another customer', () {
      expect(
          isReviewEligible(
              booking: booking(BookingStatus.completed, 'u1'),
              customerId: 'u2',
              alreadyReviewed: false),
          isFalse);
    });
  });

  group('arrivalCodeMatches', () {
    test('matches ignoring case and spaces', () {
      expect(arrivalCodeMatches(' ab12 ', 'AB12'), isTrue);
    });

    test('rejects wrong code', () {
      expect(arrivalCodeMatches('AB12', 'CD34'), isFalse);
    });

    test('rejects empty input', () {
      expect(arrivalCodeMatches('', 'AB12'), isFalse);
    });
  });

  group('hasSlotConflict', () {
    test('detects overlapping slots', () {
      final base = DateTime.utc(2026, 10, 20, 10);
      expect(
          hasSlotConflict(
            requestedStart: DateTime.utc(2026, 10, 20, 11),
            existingStarts: [base],
          ),
          isTrue);
    });

    test('allows non-overlapping slots', () {
      final base = DateTime.utc(2026, 10, 20, 10);
      expect(
          hasSlotConflict(
            requestedStart: DateTime.utc(2026, 10, 20, 13),
            existingStarts: [base],
          ),
          isFalse);
    });
  });

  group('formatInr', () {
    test('formats with Indian digit grouping', () {
      expect(formatInr(29900), '₹299');
      expect(formatInr(149900), '₹1,499');
      expect(formatInr(1250000), '₹12,500');
    });
  });

  group('validators', () {
    test('phone', () {
      expect(validatePhone('+919876543210'), isNull);
      expect(validatePhone('123'), isNotNull);
    });
    test('email', () {
      expect(validateEmail('a@b.com'), isNull);
      expect(validateEmail('nope'), isNotNull);
    });
    test('pincode', () {
      expect(validatePincode('110053'), isNull);
      expect(validatePincode('11005'), isNotNull);
    });
    test('otp', () {
      expect(validateOtp('123456'), isNull);
      expect(validateOtp('123'), isNotNull);
    });
    test('rating', () {
      expect(validateRating(5), isNull);
      expect(validateRating(0), isNotNull);
      expect(validateRating(6), isNotNull);
    });
  });
}
