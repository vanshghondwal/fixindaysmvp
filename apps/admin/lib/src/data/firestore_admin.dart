/// Firestore implementation of [AdminRepository].
///
/// SECURITY NOTE — admin authorization is enforced server-side:
/// * Every Firestore read/write here is additionally guarded by
///   firestore.rules requiring `request.auth.token.admin == true`.
/// * Client-side we NEVER check a Firestore document field for admin rights
///   (any signed-in user could forge such a field). The ONLY source of
///   truth is the Firebase Auth custom claim `admin: true`, granted via the
///   `setAdminClaim` Cloud Function (itself callable only by an existing
///   admin). This rule is commented at every place it matters.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixindays_core/fixindays_core.dart';

class FirestoreAdminRepository implements AdminRepository {
  final FirebaseFirestore _db;
  FirestoreAdminRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // IMPORTANT: admin rights come ONLY from the `admin: true` custom claim on
  // the caller's ID token. Never trust a Firestore field for this — rules
  // (firestore.rules) enforce request.auth.token.admin == true.

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _providers =>
      _db.collection('providers');
  CollectionReference<Map<String, dynamic>> get _applications =>
      _db.collection('providerApplications');
  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('bookings');
  CollectionReference<Map<String, dynamic>> get _tickets =>
      _db.collection('supportTickets');
  CollectionReference<Map<String, dynamic>> get _reviews =>
      _db.collection('reviews');
  CollectionReference<Map<String, dynamic>> get _audit =>
      _db.collection('adminAuditLogs');
  DocumentReference<Map<String, dynamic>> get _config =>
      _db.collection('config').doc('platform');

  Future<void> _log(String adminId, String action, String targetType,
      String targetId, [String details = '']) async {
    final log = AdminAuditLog(
      id: '',
      adminId: adminId,
      action: action,
      targetType: targetType,
      targetId: targetId,
      details: details,
      createdAt: DateTime.now().toUtc(),
    );
    await _audit.add(log.toJson());
  }

  @override
  Future<AdminDashboard> dashboard() async {
    // NOTE: counts are fetched client-side; for a large dataset prefer
    // Firestore aggregation queries or a scheduled Cloud Function.
    final agg = await Future.wait([
      _users.count().get(),
      _providers.count().get(),
      _applications
          .where('status', isEqualTo: VerificationStatus.pending.name)
          .count()
          .get(),
      _bookings
          .where('status',
              whereIn: const ['pending', 'accepted', 'confirmed', 'enRoute', 'arrived', 'inProgress'])
          .count()
          .get(),
      _tickets.where('status', isEqualTo: TicketStatus.open.name).count().get(),
    ]);
    final todayStart = DateTime.now().toUtc();
    final dayStart = DateTime(todayStart.year, todayStart.month, todayStart.day);
    final todayCount = await _bookings
        .where('createdAt',
            isGreaterThanOrEqualTo: dayStart.millisecondsSinceEpoch)
        .count()
        .get();
    return AdminDashboard(
      totalCustomers: agg[0].count ?? 0,
      totalProviders: agg[1].count ?? 0,
      pendingApplications: agg[2].count ?? 0,
      activeBookings: agg[3].count ?? 0,
      openTickets: agg[4].count ?? 0,
      bookingsToday: todayCount.count ?? 0,
    );
  }

  @override
  Future<List<ProviderApplication>> pendingApplications() async {
    final snap = await _applications
        .where('status',
            whereIn: const ['pending', 'needsInfo'])
        .orderBy('submittedAt', descending: true)
        .limit(100)
        .get();
    return snap.docs
        .map((d) => ProviderApplication.fromJson(d.id, d.data()))
        .toList();
  }

  @override
  Future<void> reviewApplication(
      String applicationId, bool approve, String note, String adminId) async {
    final ref = _applications.doc(applicationId);
    final doc = await ref.get();
    if (!doc.exists) throw StateError('Application not found');
    final app = ProviderApplication.fromJson(doc.id, doc.data()!);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final batch = _db.batch();
    batch.update(ref, {
      'status': approve
          ? VerificationStatus.approved.name
          : VerificationStatus.rejected.name,
      'adminNote': note,
      'reviewedBy': adminId,
      'reviewedAt': now,
    });
    // Mirror the verification status onto the provider profile.
    batch.update(_providers.doc(app.providerId), {
      'verificationStatus': approve
          ? VerificationStatus.approved.name
          : VerificationStatus.rejected.name,
    });
    await batch.commit();
    await _log(adminId, 'application.${approve ? 'approved' : 'rejected'}',
        'providerApplication', applicationId, note);
  }

  @override
  Future<void> setProviderActive(
      String providerId, bool active, String adminId) async {
    final ref = _providers.doc(providerId);
    final doc = await ref.get();
    if (!doc.exists) throw StateError('Provider not found');
    final current = ProviderProfile.fromJson(doc.id, doc.data()!);
    // Suspending marks verificationStatus='suspended'; re-activating restores
    // 'approved' only if it was suspended by an admin, otherwise keeps status.
    final status = active
        ? (current.verificationStatus == VerificationStatus.suspended
            ? VerificationStatus.approved
            : current.verificationStatus)
        : VerificationStatus.suspended;
    await ref.update({'active': active, 'verificationStatus': status.name});
    await _log(adminId, active ? 'provider.activated' : 'provider.suspended',
        'provider', providerId);
  }

  @override
  Future<List<Booking>> searchBookings(
      {String? query, BookingStatus? status}) async {
    Query<Map<String, dynamic>> q =
        _bookings.orderBy('createdAt', descending: true).limit(100);
    if (status != null) q = q.where('status', isEqualTo: status.name);
    final snap = await q.get();
    var list =
        snap.docs.map((d) => Booking.fromJson(d.id, d.data())).toList();
    final needle = (query ?? '').trim().toLowerCase();
    if (needle.isNotEmpty) {
      list = list
          .where((b) =>
              b.id.toLowerCase().contains(needle) ||
              b.customerId.toLowerCase().contains(needle) ||
              b.providerName.toLowerCase().contains(needle))
          .toList();
    }
    return list;
  }

  @override
  Future<List<SupportTicket>> openTickets() async {
    final snap = await _tickets
        .where('status', whereIn: const ['open', 'inProgress'])
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();
    return snap.docs.map((d) => SupportTicket.fromJson(d.id, d.data())).toList();
  }

  @override
  Future<void> updateTicketStatus(
      String ticketId, TicketStatus status, String adminId) async {
    await _tickets.doc(ticketId).update({
      'status': status.name,
      'updatedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    });
    await _log(adminId, 'ticket.${status.name}', 'supportTicket', ticketId);
  }

  @override
  Future<void> moderateReview(
      String reviewId, bool hidden, String adminId) async {
    await _reviews.doc(reviewId).update({'hidden': hidden});
    await _log(adminId, hidden ? 'review.hidden' : 'review.unhidden',
        'review', reviewId);
  }

  @override
  Future<PlatformSettings> platformSettings() async {
    final doc = await _config.get();
    if (!doc.exists || doc.data() == null) return const PlatformSettings();
    return PlatformSettings.fromJson(doc.data()!);
  }

  @override
  Future<void> updatePlatformSettings(
      PlatformSettings settings, String adminId) async {
    await _config.set(settings.toJson(), SetOptions(merge: true));
    await _log(adminId, 'settings.updated', 'platformSettings', 'config');
  }

  @override
  Future<List<AdminAuditLog>> auditLog({int limit = 100}) async {
    final snap = await _audit
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => AdminAuditLog.fromJson(d.id, d.data()))
        .toList();
  }

  @override
  Future<List<AppUser>> searchUsers(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      final snap = await _users.orderBy('createdAt', descending: true).limit(50).get();
      return snap.docs.map((d) => AppUser.fromJson(d.id, d.data())).toList();
    }
    // Firestore has no full-text search; do a prefix match on name/email and
    // let richer search (Algolia/Typesense) be added later.
    final byName = await _users
        .where('name', isGreaterThanOrEqualTo: q)
        .where('name', isLessThanOrEqualTo: '$q\uf8ff')
        .limit(25)
        .get();
    final byEmail = await _users
        .where('email', isGreaterThanOrEqualTo: q)
        .where('email', isLessThanOrEqualTo: '$q\uf8ff')
        .limit(25)
        .get();
    final seen = <String>{};
    final out = <AppUser>[];
    for (final d in [...byName.docs, ...byEmail.docs]) {
      if (seen.add(d.id)) out.add(AppUser.fromJson(d.id, d.data()));
    }
    return out;
  }

  @override
  Future<void> restrictUser(
      String userId, bool restricted, String adminId) async {
    await _users.doc(userId).update({'restricted': restricted});
    await _log(adminId, restricted ? 'user.restricted' : 'user.unrestricted',
        'user', userId);
  }

  // -- extra helpers (not in the contract) ----------------------------------

  Future<List<Review>> recentReviews({int limit = 100}) async {
    final snap = await _reviews
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => Review.fromJson(d.id, d.data())).toList();
  }

  Future<List<ProviderProfile>> searchProviders(String query) async {
    final q = query.trim();
    Query<Map<String, dynamic>> base =
        _providers.orderBy('createdAt', descending: true).limit(50);
    if (q.isNotEmpty) {
      base = _providers
          .where('businessName', isGreaterThanOrEqualTo: q)
          .where('businessName', isLessThanOrEqualTo: '$q\uf8ff')
          .limit(25);
    }
    final snap = await base.get();
    return snap.docs
        .map((d) => ProviderProfile.fromJson(d.id, d.data()))
        .toList();
  }

  Future<void> postAnnouncement(String title, String body, String adminId) async {
    await _db.collection('announcements').add({
      'title': title,
      'body': body,
      'createdAt': DateTime.now().toUtc().millisecondsSinceEpoch,
      'createdBy': adminId,
    });
    await _log(adminId, 'announcement.posted', 'announcement', title, body);
  }

  Future<List<Map<String, dynamic>>> announcements({int limit = 50}) async {
    final snap = await _db
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}
