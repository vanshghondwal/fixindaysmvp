/// App state for the FixinDays Partner app.
///
/// Holds the demo auth + provider-ops repositories, the signed-in [AppUser],
/// their [ProviderProfile] / [ProviderApplication], the UI [Locale], and
/// in-memory availability (honestly labelled as device-local until Firebase
/// is connected).
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';

import '../data/demo_provider_ops.dart';

/// copyWith-style helper — the core model is immutable and has no copyWith.
extension ProviderProfileCopy on ProviderProfile {
  ProviderProfile copyWith({
    String? businessName,
    String? ownerName,
    String? phone,
    String? photoUrl,
    String? description,
    int? experienceYears,
    List<String>? serviceAreas,
    VerificationStatus? verificationStatus,
    double? ratingAvg,
    int? ratingCount,
    bool? active,
  }) {
    return ProviderProfile(
      id: id,
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      description: description ?? this.description,
      experienceYears: experienceYears ?? this.experienceYears,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      active: active ?? this.active,
      createdAt: createdAt,
    );
  }
}

class PartnerState extends ChangeNotifier {
  final PartnerDemoAuthRepository auth = PartnerDemoAuthRepository();
  final DemoProviderOpsRepository ops = DemoProviderOpsRepository();
  final DemoSupportRepository support = DemoSupportRepository();
  final PartnerDemoNotificationRepository notifications =
      PartnerDemoNotificationRepository();

  AppUser? user;
  ProviderProfile? profile;
  ProviderApplication? application;
  Locale locale = const Locale('en');
  bool notificationsEnabled = true;
  bool restoring = true;

  // In-memory availability (demo): kept on device until Firebase connects.
  Set<int> workingDays = {1, 2, 3, 4, 5, 6};
  TimeOfDay openTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay closeTime = const TimeOfDay(hour: 19, minute: 0);
  String breakNote = '';

  /// Restores the demo session on app start.
  Future<void> restore() async {
    user = auth.currentUser;
    if (user != null) {
      await refreshPartnerData(notify: false);
    }
    restoring = false;
    notifyListeners();
  }

  Future<void> refreshPartnerData({bool notify = true}) async {
    final u = user;
    if (u == null) return;
    profile = await ops.myProfile(u.id);
    application = await ops.myApplication(u.id);
    if (notify) notifyListeners();
  }

  Future<void> signInWithPhone(String verificationId, String otp) async {
    user = await auth.verifyPhoneOtp(verificationId, otp);
    await refreshPartnerData();
  }

  Future<void> signInWithEmail(String email, String password) async {
    user = await auth.signInWithEmail(email, password);
    await refreshPartnerData();
  }

  Future<void> signUpWithEmail(
      String email, String password, String name) async {
    // Role is forced to provider by the demo auth repository.
    user = await auth.signUpWithEmail(email, password, name, UserRole.provider);
    await refreshPartnerData();
  }

  Future<void> signOut() async {
    await auth.signOut();
    user = null;
    profile = null;
    application = null;
    notifyListeners();
  }

  /// Deactivates the provider profile, then wipes the local session.
  Future<void> deactivateAccount() async {
    final p = profile;
    if (p != null) {
      await ops.updateProfile(p.copyWith(active: false));
    }
    await auth.deleteAccount();
    user = null;
    profile = null;
    application = null;
    notifyListeners();
  }

  void setLocale(Locale l) {
    locale = l;
    notifyListeners();
  }

  void setNotificationsEnabled(bool v) {
    notificationsEnabled = v;
    notifyListeners();
  }

  void setAvailability({
    required Set<int> days,
    required TimeOfDay open,
    required TimeOfDay close,
    required String breakNote,
  }) {
    workingDays = days;
    openTime = open;
    closeTime = close;
    this.breakNote = breakNote;
    notifyListeners();
  }
}
