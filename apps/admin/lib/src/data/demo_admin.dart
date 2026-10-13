/// In-memory demo implementation of [AdminRepository].
///
/// ALL data here is fictional seed data for the hackathon demo. The console
/// shows a [DemoBanner] whenever this repository is in use so the data is
/// never mistaken for real users/providers.
library;

import 'package:fixindays_core/fixindays_core.dart';

class DemoAdminRepository implements AdminRepository {
  DemoAdminRepository() {
    _seed();
  }

  // -- seed data -----------------------------------------------------------
  final List<AppUser> _users = [];
  final List<ProviderProfile> _providers = [];
  final List<ProviderApplication> _applications = [];
  final List<Booking> _bookings = [];
  final List<Review> _reviews = [];
  final List<SupportTicket> _tickets = [];
  final List<AdminAuditLog> _audit = [];
  PlatformSettings _settings = const PlatformSettings(
    supportPhone: '+91-1800-000-000',
    supportEmail: 'support@fixindays.in',
  );
  final List<Map<String, dynamic>> _announcements = [];

  DateTime _ago({int days = 0, int hours = 0}) =>
      DateTime.now().toUtc().subtract(Duration(days: days, hours: hours));

  void _seed() {
    _users.addAll([
      AppUser(
          id: 'u_cust_1',
          role: UserRole.customer,
          name: 'Aarav Sharma',
          phone: '+919812345001',
          email: 'aarav@example.com',
          createdAt: _ago(days: 40)),
      AppUser(
          id: 'u_cust_2',
          role: UserRole.customer,
          name: 'Meera Iyer',
          phone: '+919812345002',
          email: 'meera@example.com',
          createdAt: _ago(days: 25)),
      AppUser(
          id: 'u_cust_3',
          role: UserRole.customer,
          name: 'Rohan Gupta',
          phone: '+919812345003',
          email: 'rohan@example.com',
          createdAt: _ago(days: 6)),
      AppUser(
          id: 'u_prov_1',
          role: UserRole.provider,
          name: 'Suresh Electrician',
          phone: '+919812345101',
          createdAt: _ago(days: 60)),
      AppUser(
          id: 'u_prov_2',
          role: UserRole.provider,
          name: 'Kavitha Home Care',
          phone: '+919812345102',
          createdAt: _ago(days: 30)),
    ]);

    _providers.addAll([
      ProviderProfile(
        id: 'u_prov_1',
        businessName: 'Suresh Electrical Works',
        ownerName: 'Suresh Kumar',
        phone: '+919812345101',
        description: 'Certified electrician, 8 years experience.',
        experienceYears: 8,
        serviceAreas: ['HSR Layout', 'Koramangala'],
        verificationStatus: VerificationStatus.approved,
        ratingAvg: 4.7,
        ratingCount: 132,
        active: true,
        createdAt: _ago(days: 58),
      ),
      ProviderProfile(
        id: 'u_prov_2',
        businessName: 'Kavitha Home Care',
        ownerName: 'Kavitha R',
        phone: '+919812345102',
        description: 'Home deep-cleaning specialist.',
        experienceYears: 5,
        serviceAreas: ['Whitefield'],
        verificationStatus: VerificationStatus.pending,
        ratingAvg: 0,
        ratingCount: 0,
        active: true,
        createdAt: _ago(days: 3),
      ),
      ProviderProfile(
        id: 'u_prov_3',
        businessName: 'Quick Plumbers',
        ownerName: 'Imran S',
        phone: '+919812345103',
        description: 'Same-day plumbing repairs.',
        experienceYears: 6,
        serviceAreas: ['Indiranagar', 'Domlur'],
        verificationStatus: VerificationStatus.approved,
        ratingAvg: 4.3,
        ratingCount: 41,
        active: false, // suspended in demo
        createdAt: _ago(days: 90),
      ),
    ]);

    _applications.addAll([
      ProviderApplication(
        id: 'app_1',
        providerId: 'u_prov_2',
        documents: {
          'aadhaar': 'verification-docs/u_prov_2/aadhaar.pdf',
          'trade_certificate': 'verification-docs/u_prov_2/trade_cert.pdf',
        },
        status: VerificationStatus.pending,
        submittedAt: _ago(days: 2),
      ),
      ProviderApplication(
        id: 'app_2',
        providerId: 'u_prov_9',
        documents: {
          'aadhaar': 'verification-docs/u_prov_9/aadhaar.pdf',
        },
        status: VerificationStatus.needsInfo,
        adminNote: 'Trade certificate missing — asked for re-upload.',
        submittedAt: _ago(days: 5),
      ),
    ]);

    Booking b(String id, String cust, String prov, String provName,
        BookingStatus s, int totalPaise, int hAgo) {
      final now = DateTime.now().toUtc();
      return Booking(
        id: id,
        customerId: cust,
        providerId: prov,
        providerName: provName,
        items: const [
          BookingLineItem(
              serviceId: 'svc_1',
              serviceName: 'Switch board repair',
              quantity: 1,
              unitPricePaise: 34900)
        ],
        subtotalPaise: totalPaise - (totalPaise * 1000 ~/ 10000),
        platformFeePaise: totalPaise * 1000 ~/ 10000,
        totalPaise: totalPaise,
        addressSnapshot: '221B, 4th Cross, HSR Layout, Bengaluru 560102',
        scheduledAt: now.add(Duration(hours: 24)),
        status: s,
        paymentStatus: s == BookingStatus.completed
            ? PaymentStatus.paid
            : PaymentStatus.unpaid,
        notes: 'Demo booking',
        createdAt: now.subtract(Duration(hours: hAgo)),
        updatedAt: now.subtract(Duration(hours: hAgo)),
      );
    }

    _bookings.addAll([
      b('bk_1001', 'u_cust_1', 'u_prov_1', 'Suresh Electrical Works',
          BookingStatus.pending, 38390, 3),
      b('bk_1002', 'u_cust_2', 'u_prov_1', 'Suresh Electrical Works',
          BookingStatus.confirmed, 54890, 26),
      b('bk_1003', 'u_cust_3', 'u_prov_1', 'Suresh Electrical Works',
          BookingStatus.completed, 38390, 72),
      b('bk_1004', 'u_cust_1', 'u_prov_3', 'Quick Plumbers',
          BookingStatus.cancelled, 27440, 96),
    ]);

    _reviews.addAll([
      Review(
          id: 'rev_1',
          bookingId: 'bk_1003',
          providerId: 'u_prov_1',
          customerId: 'u_cust_3',
          customerName: 'Rohan Gupta',
          rating: 5,
          text: 'On time, neat work. Will book again.',
          createdAt: _ago(days: 2)),
      Review(
          id: 'rev_2',
          bookingId: 'bk_0990',
          providerId: 'u_prov_3',
          customerId: 'u_cust_2',
          customerName: 'Meera Iyer',
          rating: 1,
          text: 'SPAM — fake review for demo moderation.',
          createdAt: _ago(days: 9)),
    ]);

    _tickets.addAll([
      SupportTicket(
        id: 'tk_1',
        userId: 'u_cust_2',
        userRole: UserRole.customer,
        bookingId: 'bk_1002',
        category: 'payment',
        description: 'Charged twice for the same booking (demo ticket).',
        status: TicketStatus.open,
        createdAt: _ago(hours: 5),
        updatedAt: _ago(hours: 5),
      ),
      SupportTicket(
        id: 'tk_2',
        userId: 'u_prov_3',
        userRole: UserRole.provider,
        category: 'account',
        description: 'Why was my account suspended? (demo ticket).',
        status: TicketStatus.inProgress,
        createdAt: _ago(days: 2),
        updatedAt: _ago(days: 1),
      ),
    ]);

    _audit.add(AdminAuditLog(
      id: 'aud_1',
      adminId: 'demo-admin',
      action: 'application.review',
      targetType: 'providerApplication',
      targetId: 'app_0',
      details: 'Approved (seed entry)',
      createdAt: _ago(days: 12),
    ));
  }

  void _log(String adminId, String action, String targetType, String targetId,
      [String details = '']) {
    _audit.insert(
        0,
        AdminAuditLog(
          id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
          adminId: adminId,
          action: action,
          targetType: targetType,
          targetId: targetId,
          details: details,
          createdAt: DateTime.now().toUtc(),
        ));
  }

  // -- AdminRepository ------------------------------------------------------

  @override
  Future<AdminDashboard> dashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final today = DateTime.now().toUtc();
    return AdminDashboard(
      totalCustomers: _users.where((u) => u.role == UserRole.customer).length,
      totalProviders: _providers.length,
      pendingApplications:
          _applications.where((a) => a.status == VerificationStatus.pending).length,
      activeBookings: _bookings.where((b) => b.isActive).length,
      openTickets:
          _tickets.where((t) => t.status == TicketStatus.open).length,
      bookingsToday: _bookings
          .where((b) =>
              b.createdAt.year == today.year &&
              b.createdAt.month == today.month &&
              b.createdAt.day == today.day)
          .length,
    );
  }

  @override
  Future<List<ProviderApplication>> pendingApplications() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _applications
        .where((a) =>
            a.status == VerificationStatus.pending ||
            a.status == VerificationStatus.needsInfo)
        .toList();
  }

  @override
  Future<void> reviewApplication(
      String applicationId, bool approve, String note, String adminId) async {
    final i = _applications.indexWhere((a) => a.id == applicationId);
    if (i == -1) throw StateError('Application not found');
    final a = _applications[i];
    final now = DateTime.now().toUtc();
    _applications[i] = ProviderApplication(
      id: a.id,
      providerId: a.providerId,
      documents: a.documents,
      status: approve ? VerificationStatus.approved : VerificationStatus.rejected,
      adminNote: note.isEmpty ? null : note,
      reviewedBy: adminId,
      submittedAt: a.submittedAt,
      reviewedAt: now,
    );
    // Mirror onto the provider profile.
    final p = _providers.indexWhere((p) => p.id == a.providerId);
    if (p != -1) {
      final old = _providers[p];
      _providers[p] = ProviderProfile(
        id: old.id,
        businessName: old.businessName,
        ownerName: old.ownerName,
        phone: old.phone,
        photoUrl: old.photoUrl,
        description: old.description,
        experienceYears: old.experienceYears,
        serviceAreas: old.serviceAreas,
        verificationStatus:
            approve ? VerificationStatus.approved : VerificationStatus.rejected,
        ratingAvg: old.ratingAvg,
        ratingCount: old.ratingCount,
        active: old.active,
        createdAt: old.createdAt,
      );
    }
    _log(adminId, 'application.${approve ? 'approved' : 'rejected'}',
        'providerApplication', applicationId, note);
  }

  @override
  Future<void> setProviderActive(
      String providerId, bool active, String adminId) async {
    final i = _providers.indexWhere((p) => p.id == providerId);
    if (i == -1) throw StateError('Provider not found');
    final old = _providers[i];
    _providers[i] = ProviderProfile(
      id: old.id,
      businessName: old.businessName,
      ownerName: old.ownerName,
      phone: old.phone,
      photoUrl: old.photoUrl,
      description: old.description,
      experienceYears: old.experienceYears,
      serviceAreas: old.serviceAreas,
      verificationStatus:
          active ? old.verificationStatus : VerificationStatus.suspended,
      ratingAvg: old.ratingAvg,
      ratingCount: old.ratingCount,
      active: active,
      createdAt: old.createdAt,
    );
    _log(adminId, active ? 'provider.activated' : 'provider.suspended',
        'provider', providerId);
  }

  @override
  Future<List<Booking>> searchBookings(
      {String? query, BookingStatus? status}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final q = (query ?? '').trim().toLowerCase();
    return _bookings.where((b) {
      final okStatus = status == null || b.status == status;
      final okQuery = q.isEmpty ||
          b.id.toLowerCase().contains(q) ||
          b.customerId.toLowerCase().contains(q) ||
          b.providerName.toLowerCase().contains(q);
      return okStatus && okQuery;
    }).toList();
  }

  @override
  Future<List<SupportTicket>> openTickets() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _tickets
        .where((t) =>
            t.status == TicketStatus.open ||
            t.status == TicketStatus.inProgress)
        .toList();
  }

  @override
  Future<void> updateTicketStatus(
      String ticketId, TicketStatus status, String adminId) async {
    final i = _tickets.indexWhere((t) => t.id == ticketId);
    if (i == -1) throw StateError('Ticket not found');
    final t = _tickets[i];
    _tickets[i] = SupportTicket(
      id: t.id,
      userId: t.userId,
      userRole: t.userRole,
      bookingId: t.bookingId,
      category: t.category,
      description: t.description,
      evidenceUrls: t.evidenceUrls,
      status: status,
      createdAt: t.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    _log(adminId, 'ticket.${status.name}', 'supportTicket', ticketId);
  }

  @override
  Future<void> moderateReview(String reviewId, bool hidden, String adminId) async {
    final i = _reviews.indexWhere((r) => r.id == reviewId);
    if (i == -1) throw StateError('Review not found');
    final r = _reviews[i];
    _reviews[i] = Review(
      id: r.id,
      bookingId: r.bookingId,
      providerId: r.providerId,
      customerId: r.customerId,
      customerName: r.customerName,
      rating: r.rating,
      text: r.text,
      hidden: hidden,
      createdAt: r.createdAt,
    );
    _log(adminId, hidden ? 'review.hidden' : 'review.unhidden', 'review',
        reviewId);
  }

  @override
  Future<PlatformSettings> platformSettings() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _settings;
  }

  @override
  Future<void> updatePlatformSettings(
      PlatformSettings settings, String adminId) async {
    _settings = settings;
    _log(adminId, 'settings.updated', 'platformSettings', 'config',
        'commissionBps=${settings.commissionBps}');
  }

  @override
  Future<List<AdminAuditLog>> auditLog({int limit = 100}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _audit.take(limit).toList();
  }

  @override
  Future<List<AppUser>> searchUsers(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.of(_users);
    return _users
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.phone.contains(q) ||
            (u.email ?? '').toLowerCase().contains(q) ||
            u.id.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<void> restrictUser(
      String userId, bool restricted, String adminId) async {
    final i = _users.indexWhere((u) => u.id == userId);
    if (i == -1) throw StateError('User not found');
    // Demo: restriction is tracked via the audit log only; the Firestore
    // implementation flips a `restricted` field on the user document.
    _log(adminId, restricted ? 'user.restricted' : 'user.unrestricted',
        'user', userId);
  }

  // -- demo-only helpers (not part of the AdminRepository contract) ---------

  Future<List<Review>> allReviews() async => List.of(_reviews);

  Future<List<ProviderProfile>> allProviders({String? query}) async {
    final q = (query ?? '').trim().toLowerCase();
    if (q.isEmpty) return List.of(_providers);
    return _providers
        .where((p) =>
            p.businessName.toLowerCase().contains(q) ||
            p.ownerName.toLowerCase().contains(q) ||
            p.phone.contains(q))
        .toList();
  }

  Future<List<Map<String, dynamic>>> announcements() async =>
      List.of(_announcements);

  Future<void> postAnnouncement(String title, String body) async {
    _announcements.insert(0, {
      'title': title,
      'body': body,
      'createdAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    });
    _log('demo-admin', 'announcement.posted', 'announcement', title, body);
  }
}
