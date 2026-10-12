/// Demo-mode data layer for the FixinDays Partner app.
///
/// EVERYTHING IN THIS FILE IS LABELLED DEMO DATA. It exists so the partner
/// app can be exercised end to end without Firebase. The app shows
/// [DemoBanner] whenever [AppConfig.useDemoData] is true, so this seed data
/// is never presented as real marketplace data.
///
/// Security note: the plain-text arrival code [_demoArrivalCode] lives ONLY
/// in this file. Real [Booking] models carry only [Booking.arrivalCodeHash];
/// the demo hash stored on the seeded en-route booking is a placeholder.
library;

import 'dart:async';

import 'package:fixindays_core/fixindays_core.dart';

/// Plain-text arrival code for the seeded demo en-route booking.
/// Verified with [arrivalCodeMatches]; never persisted on a model.
const String _demoArrivalCode = '4821';

/// Id of the seeded demo provider user.
const String demoProviderId = 'demo-provider-1';

// ---------------------------------------------------------------------------
// Demo auth — always signs in as a PROVIDER (role forced for this app).
// ---------------------------------------------------------------------------

/// Demo [AuthRepository] for the partner app.
///
/// Unlike the core [DemoAuthRepository] (customer role), every sign-in here
/// produces a [UserRole.provider] user, because this app is provider-only.
class PartnerDemoAuthRepository extends AuthRepository with DemoCapable {
  AppUser? _user;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _user;
  }

  @override
  AppUser? get currentUser => _user;

  AppUser _provider({String? name, String? email}) => AppUser(
        id: demoProviderId,
        role: UserRole.provider, // forced: this app is provider-only
        name: name ?? 'Demo Partner',
        phone: '+91 98110 22334',
        email: email,
        createdAt: DateTime.now().toUtc(),
      );

  @override
  Future<String> sendPhoneOtp(String phoneNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return 'demo-partner-verification-id';
  }

  @override
  Future<AppUser> verifyPhoneOtp(String verificationId, String otp) async {
    // Demo: any 6-digit OTP is accepted; the UI validates the format.
    _user = _provider();
    return _user!;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    _user = _provider(email: email);
    return _user!;
  }

  @override
  Future<AppUser> signUpWithEmail(
      String email, String password, String name, UserRole role) async {
    // The requested role is ignored: partner sign-ups are always providers.
    _user = _provider(name: name, email: email);
    return _user!;
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    final u = _user;
    if (u == null) return;
    _user = AppUser(
      id: u.id,
      role: u.role,
      name: name ?? u.name,
      phone: u.phone,
      email: u.email,
      photoUrl: photoUrl ?? u.photoUrl,
      language: u.language,
      createdAt: u.createdAt,
    );
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }

  @override
  Future<void> deleteAccount() async {
    _user = null;
  }
}

// ---------------------------------------------------------------------------
// Demo provider operations.
// ---------------------------------------------------------------------------

/// In-memory [ProviderOpsRepository] with clearly labelled seed data:
///
/// * 4 services (3 active, 1 inactive)
/// * 2 incoming pending requests
/// * 2 upcoming confirmed bookings + 1 en-route booking (the demo "active"
///   job, whose arrival code is [_demoArrivalCode])
/// * 3 history bookings (2 completed, 1 cancelled)
/// * 3 demo reviews
///
/// No profile or application is seeded: a fresh sign-in goes through the
/// real onboarding flow (profile setup -> verification application ->
/// approval gate). Earnings are computed from the completed demo bookings
/// — never invented.
class DemoProviderOpsRepository extends ProviderOpsRepository with DemoCapable {
  final Map<String, ProviderProfile> _profiles = {};
  final Map<String, ProviderApplication> _applications = {};
  final Map<String, Booking> _bookings = {};
  final Map<String, ProviderService> _services = {};
  final List<Review> _reviews = [];
  final Map<String, Map<String, String>> _customers = {};

  DemoProviderOpsRepository() {
    _seed();
  }

  // -- seeding --------------------------------------------------------------

  void _seed() {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);

    _customers['demo-cust-1'] = const {
      'name': 'Aarav Mehta',
      'maskedPhone': '+91 •••• •• 2109',
    };
    _customers['demo-cust-2'] = const {
      'name': 'Priya Nair',
      'maskedPhone': '+91 •••• •• 8745',
    };
    _customers['demo-cust-3'] = const {
      'name': 'Rohan Gupta',
      'maskedPhone': '+91 •••• •• 6630',
    };
    _customers['demo-cust-4'] = const {
      'name': 'Sneha Iyer',
      'maskedPhone': '+91 •••• •• 1198',
    };
    _customers['demo-cust-5'] = const {
      'name': 'Vikram Rao',
      'maskedPhone': '+91 •••• •• 5527',
    };

    // NOTE: no profile or application is seeded here. A fresh demo
    // sign-in lands on profile setup, then the verification flow, so the
    // full onboarding can be exercised. Demo bookings/services below are
    // keyed by [demoProviderId], which the demo auth always returns.

    _addService(const ProviderService(
      id: 'demo-svc-1',
      providerId: demoProviderId,
      categoryId: 'plumbing',
      name: 'Tap & Mixer Repair',
      description: 'Fix leaks, replace washers and cartridges.',
      priceBasis: PriceBasis.fixed,
      pricePaise: 29900,
      unit: 'visit',
      durationMin: 45,
      active: true,
    ));
    _addService(const ProviderService(
      id: 'demo-svc-2',
      providerId: demoProviderId,
      categoryId: 'electrical',
      name: 'Switchboard Repair',
      description: 'Repair or replace faulty switches and boards.',
      priceBasis: PriceBasis.fixed,
      pricePaise: 24900,
      unit: 'visit',
      durationMin: 30,
      active: true,
    ));
    _addService(const ProviderService(
      id: 'demo-svc-3',
      providerId: demoProviderId,
      categoryId: 'cleaning',
      name: 'Bathroom Deep Cleaning',
      description: 'Tiles, fittings and sanitary deep clean.',
      priceBasis: PriceBasis.fixed,
      pricePaise: 79900,
      unit: 'bathroom',
      durationMin: 90,
      active: true,
    ));
    _addService(const ProviderService(
      id: 'demo-svc-4',
      providerId: demoProviderId,
      categoryId: 'appliance',
      name: 'AC Service (Split)',
      description: 'Foam-jet indoor unit service, gas check extra.',
      priceBasis: PriceBasis.estimate,
      pricePaise: 59900,
      unit: 'ac',
      durationMin: 60,
      active: false,
    ));

    BookingLineItem li(
            String sid, String name, int qty, int unitPaise) =>
        BookingLineItem(
          serviceId: sid,
          serviceName: name,
          quantity: qty,
          unitPricePaise: unitPaise,
        );

    // 2 incoming pending requests.
    _addBooking(_mkBooking(
      id: 'demo-b-req1',
      customerId: 'demo-cust-1',
      items: [li('demo-svc-1', 'Tap & Mixer Repair', 1, 29900)],
      addressSnapshot: 'B-42, Sector 7, Rohini, Delhi 110085',
      scheduledAt: now.add(const Duration(hours: 3)),
      status: BookingStatus.pending,
      notes: 'Kitchen tap leaking since yesterday.',
      createdAt: now.subtract(const Duration(minutes: 40)),
    ));
    _addBooking(_mkBooking(
      id: 'demo-b-req2',
      customerId: 'demo-cust-2',
      items: [li('demo-svc-3', 'Bathroom Deep Cleaning', 1, 79900)],
      addressSnapshot: 'H.No 214, Pocket C-8, Pitampura, Delhi 110034',
      scheduledAt: today.add(const Duration(days: 1, hours: 10)),
      status: BookingStatus.pending,
      notes: '2 bathrooms. Please bring own chemicals.',
      createdAt: now.subtract(const Duration(hours: 2)),
    ));

    // 2 upcoming confirmed bookings.
    _addBooking(_mkBooking(
      id: 'demo-b-up1',
      customerId: 'demo-cust-3',
      items: [li('demo-svc-2', 'Switchboard Repair', 1, 24900)],
      addressSnapshot: 'A-77, Laxmi Nagar, Near Vikas Marg, Delhi 110092',
      scheduledAt: today.add(const Duration(days: 1, hours: 14)),
      status: BookingStatus.confirmed,
      paymentStatus: PaymentStatus.pending,
      createdAt: now.subtract(const Duration(days: 1)),
    ));
    _addBooking(_mkBooking(
      id: 'demo-b-up2',
      customerId: 'demo-cust-4',
      items: [
        li('demo-svc-1', 'Tap & Mixer Repair', 1, 29900),
        li('demo-svc-2', 'Switchboard Repair', 1, 24900),
      ],
      addressSnapshot: 'Plot 9, Sector 11, Dwarka, Delhi 110075',
      scheduledAt:
          today.add(const Duration(days: 2, hours: 11, minutes: 30)),
      status: BookingStatus.confirmed,
      paymentStatus: PaymentStatus.pending,
      createdAt: now.subtract(const Duration(days: 1, hours: 5)),
    ));

    // 1 en-route booking = the demo "active" job.
    _addBooking(_mkBooking(
      id: 'demo-b-act',
      customerId: 'demo-cust-5',
      items: [li('demo-svc-4', 'AC Service (Split)', 1, 59900)],
      addressSnapshot: 'C-301, Green View Apartments, Saket, Delhi 110017',
      scheduledAt: now.add(const Duration(minutes: 45)),
      status: BookingStatus.enRoute,
      paymentStatus: PaymentStatus.pending,
      // Placeholder only. The real plain code lives in [_demoArrivalCode].
      arrivalCodeHash: 'demo-sha256-placeholder',
      createdAt: now.subtract(const Duration(hours: 3)),
    ));

    // 3 history bookings: 2 completed, 1 cancelled.
    _addBooking(_mkBooking(
      id: 'demo-b-h1',
      customerId: 'demo-cust-2',
      items: [li('demo-svc-3', 'Bathroom Deep Cleaning', 1, 79900)],
      addressSnapshot: 'H.No 214, Pocket C-8, Pitampura, Delhi 110034',
      scheduledAt: now.subtract(const Duration(days: 3)),
      status: BookingStatus.completed,
      paymentStatus: PaymentStatus.paid,
      createdAt: now.subtract(const Duration(days: 4)),
    ));
    _addBooking(_mkBooking(
      id: 'demo-b-h2',
      customerId: 'demo-cust-4',
      items: [li('demo-svc-1', 'Tap & Mixer Repair', 2, 29900)],
      addressSnapshot: 'Plot 9, Sector 11, Dwarka, Delhi 110075',
      scheduledAt: now.subtract(const Duration(days: 5)),
      status: BookingStatus.completed,
      paymentStatus: PaymentStatus.paid,
      createdAt: now.subtract(const Duration(days: 6)),
    ));
    _addBooking(_mkBooking(
      id: 'demo-b-h3',
      customerId: 'demo-cust-1',
      items: [li('demo-svc-2', 'Switchboard Repair', 1, 24900)],
      addressSnapshot: 'B-42, Sector 7, Rohini, Delhi 110085',
      scheduledAt: now.subtract(const Duration(days: 2)),
      status: BookingStatus.cancelled,
      cancelReason: 'Customer rescheduled to next week.',
      createdAt: now.subtract(const Duration(days: 3)),
    ));

    _reviews.addAll([
      Review(
        id: 'demo-r1',
        bookingId: 'demo-b-h1',
        providerId: demoProviderId,
        customerId: 'demo-cust-2',
        customerName: 'Priya Nair',
        rating: 5,
        text: 'Very professional — the bathroom looks brand new.',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Review(
        id: 'demo-r2',
        bookingId: 'demo-b-h2',
        providerId: demoProviderId,
        customerId: 'demo-cust-4',
        customerName: 'Sneha Iyer',
        rating: 4,
        text: 'Good work, arrived a little late.',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Review(
        id: 'demo-r3',
        bookingId: 'demo-b-h0',
        providerId: demoProviderId,
        customerId: 'demo-cust-5',
        customerName: 'Vikram Rao',
        rating: 5,
        text: 'Excellent AC service, highly recommended.',
        createdAt: now.subtract(const Duration(days: 9)),
      ),
    ]);
  }

  void _addService(ProviderService s) => _services[s.id] = s;

  void _addBooking(Booking b) => _bookings[b.id] = b;

  Booking _mkBooking({
    required String id,
    required String customerId,
    required List<BookingLineItem> items,
    required String addressSnapshot,
    required DateTime scheduledAt,
    required BookingStatus status,
    PaymentStatus paymentStatus = PaymentStatus.unpaid,
    String? notes,
    String? cancelReason,
    String? arrivalCodeHash,
    required DateTime createdAt,
  }) {
    final t = calcTotals(items, commissionBps: 1000);
    return Booking(
      id: id,
      customerId: customerId,
      providerId: demoProviderId,
      providerName: 'Sharma Home Services',
      items: items,
      subtotalPaise: t.subtotalPaise,
      platformFeePaise: t.platformFeePaise,
      totalPaise: t.totalPaise,
      addressSnapshot: addressSnapshot,
      scheduledAt: scheduledAt,
      status: status,
      paymentStatus: paymentStatus,
      arrivalCodeHash: arrivalCodeHash,
      notes: notes,
      cancelReason: cancelReason,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  // -- helpers --------------------------------------------------------------

  Booking _get(String bookingId) {
    final b = _bookings[bookingId];
    if (b == null) throw StateError('Booking not found: $bookingId');
    return b;
  }

  /// Guards every mutation with the shared [canTransition] state machine.
  void _guard(BookingStatus from, BookingStatus to) {
    if (!canTransition(from, to, UserRole.provider)) {
      throw StateError(
          'Providers cannot move a booking from ${from.name} to ${to.name}.');
    }
  }

  Booking _withStatus(Booking b, BookingStatus to) => Booking(
        id: b.id,
        customerId: b.customerId,
        providerId: b.providerId,
        providerName: b.providerName,
        items: b.items,
        subtotalPaise: b.subtotalPaise,
        platformFeePaise: b.platformFeePaise,
        totalPaise: b.totalPaise,
        addressSnapshot: b.addressSnapshot,
        addressId: b.addressId,
        scheduledAt: b.scheduledAt,
        status: to,
        paymentStatus: b.paymentStatus,
        arrivalCodeHash: b.arrivalCodeHash,
        notes: b.notes,
        cancelReason: b.cancelReason,
        createdAt: b.createdAt,
        updatedAt: DateTime.now().toUtc(),
      );

  ProviderProfile _withVerification(
          ProviderProfile p, VerificationStatus status) =>
      ProviderProfile(
        id: p.id,
        businessName: p.businessName,
        ownerName: p.ownerName,
        phone: p.phone,
        photoUrl: p.photoUrl,
        description: p.description,
        experienceYears: p.experienceYears,
        serviceAreas: p.serviceAreas,
        verificationStatus: status,
        ratingAvg: p.ratingAvg,
        ratingCount: p.ratingCount,
        active: p.active,
        createdAt: p.createdAt,
      );

  // -- ProviderOpsRepository --------------------------------------------------

  @override
  Future<ProviderProfile?> myProfile(String providerId) async =>
      _profiles[providerId];

  @override
  Future<void> updateProfile(ProviderProfile profile) async {
    _profiles[profile.id] = profile;
  }

  @override
  Future<List<Booking>> incomingRequests(String providerId) async {
    final list = _bookings.values
        .where((b) =>
            b.providerId == providerId && b.status == BookingStatus.pending)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return list;
  }

  static const _upcomingStatuses = {
    BookingStatus.accepted,
    BookingStatus.confirmed,
    BookingStatus.enRoute,
    BookingStatus.arrived,
    BookingStatus.inProgress,
  };

  @override
  Future<List<Booking>> upcomingBookings(String providerId) async {
    final list = _bookings.values
        .where((b) =>
            b.providerId == providerId &&
            _upcomingStatuses.contains(b.status))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return list;
  }

  static const _historyStatuses = {
    BookingStatus.completed,
    BookingStatus.cancelled,
    BookingStatus.rejected,
    BookingStatus.disputed,
  };

  @override
  Future<List<Booking>> bookingHistory(String providerId) async {
    final list = _bookings.values
        .where((b) =>
            b.providerId == providerId &&
            _historyStatuses.contains(b.status))
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return list;
  }

  @override
  Future<void> respondToBooking(String bookingId, bool accept) async {
    final b = _get(bookingId);
    final to = accept ? BookingStatus.accepted : BookingStatus.rejected;
    _guard(b.status, to);
    _bookings[bookingId] = _withStatus(b, to);
  }

  @override
  Future<void> transitionBooking(
    String bookingId,
    BookingStatus to, {
    String? arrivalCode,
  }) async {
    final b = _get(bookingId);
    _guard(b.status, to);
    if (to == BookingStatus.inProgress) {
      // Demo check against the plain code kept ONLY in this file.
      if (arrivalCode == null ||
          !arrivalCodeMatches(arrivalCode, _demoArrivalCode)) {
        throw StateError(
            'Arrival code does not match. Ask the customer for the 4-digit '
            'code shown in their app.');
      }
    }
    _bookings[bookingId] = _withStatus(b, to);
  }

  @override
  Future<List<ProviderService>> myServices(String providerId) async =>
      _services.values
          .where((s) => s.providerId == providerId)
          .toList();

  @override
  Future<void> upsertService(ProviderService service) async {
    final id = service.id.isEmpty
        ? 'demo-svc-${DateTime.now().millisecondsSinceEpoch}'
        : service.id;
    _services[id] = ProviderService(
      id: id,
      providerId:
          service.providerId.isEmpty ? demoProviderId : service.providerId,
      categoryId: service.categoryId,
      name: service.name,
      description: service.description,
      priceBasis: service.priceBasis,
      pricePaise: service.pricePaise,
      unit: service.unit,
      durationMin: service.durationMin,
      active: service.active,
    );
  }

  @override
  Future<void> setServiceActive(String serviceId, bool active) async {
    final s = _services[serviceId];
    if (s == null) throw StateError('Service not found: $serviceId');
    _services[serviceId] = ProviderService(
      id: s.id,
      providerId: s.providerId,
      categoryId: s.categoryId,
      name: s.name,
      description: s.description,
      priceBasis: s.priceBasis,
      pricePaise: s.pricePaise,
      unit: s.unit,
      durationMin: s.durationMin,
      active: active,
    );
  }

  @override
  Future<ProviderApplication?> myApplication(String providerId) async =>
      _applications[providerId];

  @override
  Future<void> submitApplication(
      String providerId, Map<String, String> documents) async {
    final now = DateTime.now().toUtc();
    _applications[providerId] = ProviderApplication(
      id: 'demo-app-$providerId',
      providerId: providerId,
      documents: Map<String, String>.from(documents),
      status: VerificationStatus.pending,
      submittedAt: now,
    );
  }

  @override
  Future<ProviderEarnings> earnings(String providerId) async {
    final mine = _bookings.values.where((b) => b.providerId == providerId);
    final completed =
        mine.where((b) => b.status == BookingStatus.completed).toList();
    final gross = completed.fold<int>(0, (s, b) => s + b.totalPaise);
    final commission = gross * 1000 ~/ 10000; // 10% demo commission
    final refunds = mine
        .where((b) => b.paymentStatus == PaymentStatus.refunded)
        .fold<int>(0, (s, b) => s + b.totalPaise);
    return ProviderEarnings(
      grossPaise: gross,
      commissionPaise: commission,
      refundsPaise: refunds,
      netPaise: gross - commission - refunds,
      completedJobs: completed.length,
    );
  }

  // -- demo-only helpers (not part of the repository interface) --------------

  /// Single-booking fetch for detail screens (demo only).
  Future<Booking?> booking(String bookingId) async => _bookings[bookingId];

  /// Masked customer contact for demo display — never a real phone number.
  Map<String, String> demoCustomerContact(String customerId) =>
      _customers[customerId] ??
      const {'name': 'Customer', 'maskedPhone': '+91 •••• •• ••••'};

  /// Demo reviews shown on the reviews screen.
  List<Review> get demoReviews => List<Review>.unmodifiable(_reviews);

  /// Demo-only: pretend an admin approved the application so the demo flow
  /// can continue past the verification gate. Labelled as demo in the UI.
  Future<void> simulateApproval(String providerId) async {
    final now = DateTime.now().toUtc();
    final app = _applications[providerId];
    if (app != null) {
      _applications[providerId] = ProviderApplication(
        id: app.id,
        providerId: app.providerId,
        documents: app.documents,
        status: VerificationStatus.approved,
        adminNote: 'Demo approval — documents accepted.',
        reviewedBy: 'demo-admin',
        submittedAt: app.submittedAt,
        reviewedAt: now,
      );
    } else {
      _applications[providerId] = ProviderApplication(
        id: 'demo-app-$providerId',
        providerId: providerId,
        status: VerificationStatus.approved,
        adminNote: 'Demo approval.',
        reviewedBy: 'demo-admin',
        submittedAt: now,
        reviewedAt: now,
      );
    }
    final p = _profiles[providerId];
    if (p != null) {
      _profiles[providerId] =
          _withVerification(p, VerificationStatus.approved);
    }
  }
}

// ---------------------------------------------------------------------------
// Demo notifications with seeded items (core demo yields an empty list).
// ---------------------------------------------------------------------------

/// [DemoNotificationRepository] seeded with partner notifications and a
/// working [markRead]. Still labelled demo data.
class PartnerDemoNotificationRepository extends DemoNotificationRepository {
  final List<NotificationItem> _items = [];
  final StreamController<List<NotificationItem>> _ctrl =
      StreamController<List<NotificationItem>>.broadcast();

  PartnerDemoNotificationRepository() {
    final now = DateTime.now().toUtc();
    _items.addAll([
      NotificationItem(
        id: 'demo-n1',
        userId: demoProviderId,
        kind: NotificationKind.booking,
        title: 'New booking request',
        body: 'Tap & Mixer Repair in Rohini — respond within 60 minutes.',
        createdAt: now.subtract(const Duration(minutes: 40)),
      ),
      NotificationItem(
        id: 'demo-n2',
        userId: demoProviderId,
        kind: NotificationKind.review,
        title: 'New 5-star review',
        body: 'Priya Nair rated your bathroom deep cleaning 5 stars.',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      NotificationItem(
        id: 'demo-n3',
        userId: demoProviderId,
        kind: NotificationKind.system,
        title: 'Welcome to FixinDays Partner',
        body: 'Complete verification to start receiving bookings.',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ]);
  }

  List<NotificationItem> _sorted(String userId) {
    final list = _items.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Stream<List<NotificationItem>> watch(String userId) async* {
    yield _sorted(userId);
    yield* _ctrl.stream;
  }

  @override
  Future<void> markRead(String notificationId) async {
    final i = _items.indexWhere((n) => n.id == notificationId);
    if (i == -1) return;
    final n = _items[i];
    _items[i] = NotificationItem(
      id: n.id,
      userId: n.userId,
      kind: n.kind,
      title: n.title,
      body: n.body,
      data: n.data,
      read: true,
      createdAt: n.createdAt,
    );
    _ctrl.add(_sorted(n.userId));
  }
}
