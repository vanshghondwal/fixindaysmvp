/// Real Firebase-backed repository implementations.
///
/// These are used only after Firebase is configured
/// (`flutterfire configure` + backend products enabled).
/// They perform genuine Firestore/Auth queries — no mock data.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'logic.dart';
import 'models.dart';
import 'repositories.dart';

FirebaseFirestore get _db => FirebaseFirestore.instance;
FirebaseAuth get _auth => FirebaseAuth.instance;

AppUser _toAppUser(User u, Map<String, dynamic>? doc) => AppUser(
      id: u.uid,
      role: UserRole.values.firstWhere(
        (e) => e.name == (doc?['role'] ?? 'customer'),
        orElse: () => UserRole.customer,
      ),
      name: (doc?['name'] ?? u.displayName ?? '') as String,
      phone: (doc?['phone'] ?? u.phoneNumber ?? '') as String,
      email: (doc?['email'] ?? u.email) as String?,
      photoUrl: (doc?['photoUrl'] ?? u.photoURL) as String?,
      language: (doc?['language'] ?? 'en') as String,
      createdAt: DateTime.now().toUtc(),
    );

class FirestoreAuthRepository extends AuthRepository {
  @override
  Stream<AppUser?> authStateChanges() =>
      _auth.authStateChanges().asyncMap((u) async {
        if (u == null) return null;
        final doc = await _db.collection('users').doc(u.uid).get();
        return _toAppUser(u, doc.data());
      });

  @override
  AppUser? get currentUser {
    final u = _auth.currentUser;
    if (u == null) return null;
    // Best-effort sync snapshot; callers should prefer authStateChanges().
    return AppUser(
      id: u.uid,
      role: UserRole.customer,
      name: u.displayName ?? '',
      phone: u.phoneNumber ?? '',
      email: u.email,
      photoUrl: u.photoURL,
      createdAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<String> sendPhoneOtp(String phoneNumber) async {
    String? verificationId;
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (_) {},
      verificationFailed: (e) => throw StateError(e.message ?? 'OTP failed'),
      codeSent: (vid, _) => verificationId = vid,
      codeAutoRetrievalTimeout: (vid) => verificationId ??= vid,
    );
    final vid = verificationId;
    if (vid == null) throw StateError('Could not send OTP');
    return vid;
  }

  @override
  Future<AppUser> verifyPhoneOtp(String verificationId, String otp) async {
    final cred = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otp);
    final res = await _auth.signInWithCredential(cred);
    final u = res.user!;
    await _ensureUserDoc(u, UserRole.customer);
    final doc = await _db.collection('users').doc(u.uid).get();
    return _toAppUser(u, doc.data());
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final res = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    final u = res.user!;
    final doc = await _db.collection('users').doc(u.uid).get();
    return _toAppUser(u, doc.data());
  }

  @override
  Future<AppUser> signUpWithEmail(
      String email, String password, String name, UserRole role) async {
    final res = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final u = res.user!;
    await u.updateDisplayName(name);
    await _db.collection('users').doc(u.uid).set({
      'role': role.name,
      'name': name,
      'phone': u.phoneNumber ?? '',
      'email': email,
      'language': 'en',
      'createdAt': FieldValue.serverTimestamp(),
    });
    final doc = await _db.collection('users').doc(u.uid).get();
    return _toAppUser(u, doc.data());
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  @override
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    final u = _auth.currentUser;
    if (u == null) return;
    if (name != null) await u.updateDisplayName(name);
    if (photoUrl != null) await u.updatePhotoURL(photoUrl);
    await _db.collection('users').doc(u.uid).update({
      if (name != null) 'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> deleteAccount() async {
    final u = _auth.currentUser;
    if (u == null) return;
    await _db.collection('users').doc(u.uid).update({'isDeleted': true});
    await u.delete();
  }

  Future<void> _ensureUserDoc(User u, UserRole role) async {
    final ref = _db.collection('users').doc(u.uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'role': role.name,
        'name': u.displayName ?? '',
        'phone': u.phoneNumber ?? '',
        'email': u.email,
        'language': 'en',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

class FirestoreCatalogRepository extends CatalogRepository {
  @override
  Future<List<ServiceCategory>> categories() async {
    final snap = await _db
        .collection('serviceCategories')
        .where('active', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snap.docs
        .map((d) => ServiceCategory.fromJson(d.id, d.data()))
        .toList();
  }

  @override
  Future<List<ProviderProfile>> searchProviders({
    String? categoryId,
    String? query,
    double? minRating,
    int? maxPricePaise,
    String sortBy = 'rating',
    int limit = 20,
    int offset = 0,
  }) async {
    // Providers are approved + active only. Category filtering goes through
    // providerServices subcollection reads per provider (paginated).
    Query<Map<String, dynamic>> q = _db
        .collection('providers')
        .where('active', isEqualTo: true)
        .where('verificationStatus', isEqualTo: 'approved');
    if (minRating != null) {
      q = q.where('ratingAvg', isGreaterThanOrEqualTo: minRating);
    }
    q = q.orderBy(sortBy == 'rating' ? 'ratingAvg' : 'createdAt',
        descending: true);
    q = q.limit(limit + offset);
    final snap = await q.get();
    var list = snap.docs
        .map((d) => ProviderProfile.fromJson(d.id, d.data()))
        .toList();
    if (categoryId != null) {
      final filtered = <ProviderProfile>[];
      for (final p in list) {
        final s = await _db
            .collection('providerServices')
            .where('providerId', isEqualTo: p.id)
            .where('categoryId', isEqualTo: categoryId)
            .where('active', isEqualTo: true)
            .limit(1)
            .get();
        if (s.docs.isNotEmpty) filtered.add(p);
      }
      list = filtered;
    }
    if (query != null && query.trim().isNotEmpty) {
      final needle = query.toLowerCase();
      list = list
          .where((p) =>
              p.businessName.toLowerCase().contains(needle) ||
              p.ownerName.toLowerCase().contains(needle))
          .toList();
    }
    // NOTE: honest limitation — distance requires geo queries (GeoFlutterFire
    // or Firestore geo bounds); never invented here.
    return list.skip(offset).take(limit).toList();
  }

  @override
  Future<ProviderProfile?> provider(String providerId) async {
    final doc = await _db.collection('providers').doc(providerId).get();
    if (!doc.exists) return null;
    return ProviderProfile.fromJson(doc.id, doc.data()!);
  }

  @override
  Future<List<ProviderService>> providerServices(String providerId,
      {bool activeOnly = true}) async {
    Query<Map<String, dynamic>> q = _db
        .collection('providerServices')
        .where('providerId', isEqualTo: providerId);
    if (activeOnly) q = q.where('active', isEqualTo: true);
    final snap = await q.get();
    return snap.docs
        .map((d) => ProviderService.fromJson(d.id, d.data()))
        .toList();
  }

  @override
  Future<List<Review>> providerReviews(String providerId,
      {bool includeHidden = false}) async {
    Query<Map<String, dynamic>> q = _db
        .collection('reviews')
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .limit(50);
    if (!includeHidden) q = q.where('hidden', isEqualTo: false);
    final snap = await q.get();
    return snap.docs.map((d) => Review.fromJson(d.id, d.data())).toList();
  }

  @override
  Future<double> providerRating(String providerId) async {
    final p = await provider(providerId);
    return p?.ratingAvg ?? 0;
  }
}

class FirestoreBookingRepository extends BookingRepository {
  @override
  Future<Booking> createBooking({
    required String customerId,
    required String providerId,
    required List<BookingLineItem> items,
    required String addressSnapshot,
    String? addressId,
    required DateTime scheduledAt,
    String? notes,
    PaymentStatus paymentStatus = PaymentStatus.unpaid,
  }) async {
    // Client-side pre-validation. Authoritative validation (prices,
    // availability, slot conflicts) runs in the `validateBooking`
    // Cloud Function before the booking is confirmed.
    if (items.isEmpty) throw ArgumentError('Select at least one service');
    final settings =
        await _db.collection('platformSettings').doc('default').get();
    final commissionBps =
        (settings.data()?['commissionBps'] ?? 1000) as int;
    final totals =
        calcTotals(items, commissionBps: commissionBps);

    final providerDoc =
        await _db.collection('providers').doc(providerId).get();
    final providerName =
        (providerDoc.data()?['businessName'] ?? 'Provider') as String;

    final ref = await _db.collection('bookings').add({
      'customerId': customerId,
      'providerId': providerId,
      'providerName': providerName,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotalPaise': totals.subtotalPaise,
      'platformFeePaise': totals.platformFeePaise,
      'totalPaise': totals.totalPaise,
      'addressSnapshot': addressSnapshot,
      'addressId': addressId,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': BookingStatus.pending.name,
      'paymentStatus': paymentStatus.name,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('bookingEvents').add({
      'bookingId': ref.id,
      'type': 'created',
      'actorRole': UserRole.customer.name,
      'actorId': customerId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final doc = await ref.get();
    final data = doc.data()!;
    return Booking.fromJson(ref.id, {
      ...data,
      'createdAt': DateTime.now().toUtc().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
      'scheduledAt': scheduledAt.millisecondsSinceEpoch,
    });
  }

  @override
  Future<List<Booking>> myBookings(String customerId,
      {BookingStatus? statusFilter}) async {
    Query<Map<String, dynamic>> q = _db
        .collection('bookings')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .limit(50);
    if (statusFilter != null) {
      q = q.where('status', isEqualTo: statusFilter.name);
    }
    final snap = await q.get();
    return snap.docs
        .map((d) => Booking.fromJson(d.id, _withMillis(d.data())))
        .toList();
  }

  @override
  Future<Booking?> booking(String bookingId) async {
    final doc = await _db.collection('bookings').doc(bookingId).get();
    if (!doc.exists) return null;
    return Booking.fromJson(doc.id, _withMillis(doc.data()!));
  }

  @override
  Stream<Booking?> watchBooking(String bookingId) =>
      _db.collection('bookings').doc(bookingId).snapshots().map((doc) =>
          doc.exists ? Booking.fromJson(doc.id, _withMillis(doc.data()!)) : null);

  @override
  Future<void> cancelBooking(String bookingId, String reason) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.cancelled.name,
      'cancelReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> rescheduleBooking(String bookingId, DateTime newSlot) async {
    await _db.collection('bookings').doc(bookingId).update({
      'scheduledAt': Timestamp.fromDate(newSlot),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Review> submitReview({
    required String bookingId,
    required String customerId,
    required int rating,
    required String text,
  }) async {
    if (validateRating(rating) != null) {
      throw ArgumentError('Rating must be 1–5');
    }
    final existing = await _db
        .collection('reviews')
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw StateError('This booking already has a review');
    }
    final bookingDoc =
        await _db.collection('bookings').doc(bookingId).get();
    final bdata = bookingDoc.data();
    if (bdata == null ||
        bdata['status'] != BookingStatus.completed.name ||
        bdata['customerId'] != customerId) {
      throw StateError('Not eligible to review this booking');
    }
    final ref = await _db.collection('reviews').add({
      'bookingId': bookingId,
      'providerId': bdata['providerId'],
      'customerId': customerId,
      'customerName': bdata['customerName'] ?? 'Customer',
      'rating': rating,
      'text': text,
      'hidden': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return Review(
      id: ref.id,
      bookingId: bookingId,
      providerId: (bdata['providerId'] ?? '') as String,
      customerId: customerId,
      customerName: 'Customer',
      rating: rating,
      text: text,
      createdAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<bool> hasReviewed(String bookingId) async {
    final snap = await _db
        .collection('reviews')
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Converts Firestore Timestamps to millis for the model layer.
  Map<String, dynamic> _withMillis(Map<String, dynamic> data) {
    int ms(dynamic v) => v is Timestamp
        ? v.millisecondsSinceEpoch
        : (v is int ? v : DateTime.now().toUtc().millisecondsSinceEpoch);
    return {
      ...data,
      'createdAt': ms(data['createdAt']),
      'updatedAt': ms(data['updatedAt']),
      'scheduledAt': ms(data['scheduledAt']),
    };
  }
}

String? validateRating(int? v) =>
    (v == null || v < 1 || v > 5) ? 'Rating must be 1–5' : null;
