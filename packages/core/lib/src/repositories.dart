/// Repository abstractions shared by all FixinDays apps.
///
/// Two implementations exist:
/// * [DemoRepository] — clearly labelled seed data for demos.
/// * [FirestoreRepository] — real Firebase backend (needs configuration).
library;

import 'models.dart';

/// Authentication + current user.
abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;

  Future<String> sendPhoneOtp(String phoneNumber);
  Future<AppUser> verifyPhoneOtp(String verificationId, String otp);
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signUpWithEmail(
      String email, String password, String name, UserRole role);
  Future<void> sendPasswordReset(String email);
  Future<void> updateProfile({String? name, String? photoUrl});
  Future<void> signOut();
  Future<void> deleteAccount();
}

/// Read-only marketplace catalogue.
abstract class CatalogRepository {
  Future<List<ServiceCategory>> categories();
  Future<List<ProviderProfile>> searchProviders({
    String? categoryId,
    String? query,
    double? minRating,
    int? maxPricePaise,
    String sortBy, // 'rating' | 'priceAsc' | 'priceDesc'
    int limit,
    int offset,
  });
  Future<ProviderProfile?> provider(String providerId);
  Future<List<ProviderService>> providerServices(String providerId,
      {bool activeOnly = true});
  Future<List<Review>> providerReviews(String providerId,
      {bool includeHidden = false});
  Future<double> providerRating(String providerId);
}

/// Customer booking lifecycle.
abstract class BookingRepository {
  Future<Booking> createBooking({
    required String customerId,
    required String providerId,
    required List<BookingLineItem> items,
    required String addressSnapshot,
    String? addressId,
    required DateTime scheduledAt,
    String? notes,
    PaymentStatus paymentStatus = PaymentStatus.unpaid,
  });
  Future<List<Booking>> myBookings(String customerId,
      {BookingStatus? statusFilter});
  Future<Booking?> booking(String bookingId);
  Stream<Booking?> watchBooking(String bookingId);
  Future<void> cancelBooking(String bookingId, String reason);
  Future<void> rescheduleBooking(String bookingId, DateTime newSlot);
  Future<Review> submitReview({
    required String bookingId,
    required String customerId,
    required int rating,
    required String text,
  });
  Future<bool> hasReviewed(String bookingId);
}

/// Provider-side operations.
abstract class ProviderOpsRepository {
  Future<ProviderProfile?> myProfile(String providerId);
  Future<void> updateProfile(ProviderProfile profile);
  Future<List<Booking>> incomingRequests(String providerId);
  Future<List<Booking>> upcomingBookings(String providerId);
  Future<List<Booking>> bookingHistory(String providerId);
  Future<void> respondToBooking(String bookingId, bool accept);
  Future<void> transitionBooking(
    String bookingId,
    BookingStatus to, {
    String? arrivalCode,
  });
  Future<List<ProviderService>> myServices(String providerId);
  Future<void> upsertService(ProviderService service);
  Future<void> setServiceActive(String serviceId, bool active);
  Future<ProviderApplication?> myApplication(String providerId);
  Future<void> submitApplication(
      String providerId, Map<String, String> documents);
  Future<ProviderEarnings> earnings(String providerId);
}

class ProviderEarnings {
  final int grossPaise;
  final int commissionPaise;
  final int refundsPaise;
  final int netPaise;
  final int completedJobs;

  const ProviderEarnings({
    required this.grossPaise,
    required this.commissionPaise,
    required this.refundsPaise,
    required this.netPaise,
    required this.completedJobs,
  });
}

/// Customer addresses.
abstract class AddressRepository {
  Future<List<Address>> myAddresses(String userId);
  Future<void> saveAddress(Address address);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefault(String userId, String addressId);
}

/// Support tickets / disputes.
abstract class SupportRepository {
  Future<SupportTicket> createTicket({
    required String userId,
    required UserRole userRole,
    String? bookingId,
    required String category,
    required String description,
    List<String> evidenceUrls,
  });
  Future<List<SupportTicket>> myTickets(String userId);
}

/// Push/in-app notifications.
abstract class NotificationRepository {
  Stream<List<NotificationItem>> watch(String userId);
  Future<void> markRead(String notificationId);
  Future<void> saveFcmToken(String userId, String token);
}

/// Admin operations. Server-side authorization uses Firebase custom claims
/// (`admin: true`); never a client-editable Firestore field.
abstract class AdminRepository {
  Future<AdminDashboard> dashboard();
  Future<List<ProviderApplication>> pendingApplications();
  Future<void> reviewApplication(
      String applicationId, bool approve, String note, String adminId);
  Future<void> setProviderActive(String providerId, bool active, String adminId);
  Future<List<Booking>> searchBookings({String? query, BookingStatus? status});
  Future<List<SupportTicket>> openTickets();
  Future<void> updateTicketStatus(
      String ticketId, TicketStatus status, String adminId);
  Future<void> moderateReview(String reviewId, bool hidden, String adminId);
  Future<PlatformSettings> platformSettings();
  Future<void> updatePlatformSettings(
      PlatformSettings settings, String adminId);
  Future<List<AdminAuditLog>> auditLog({int limit});
  Future<List<AppUser>> searchUsers(String query);
  Future<void> restrictUser(String userId, bool restricted, String adminId);
}

class AdminDashboard {
  final int totalCustomers;
  final int totalProviders;
  final int pendingApplications;
  final int activeBookings;
  final int openTickets;
  final int bookingsToday;

  const AdminDashboard({
    required this.totalCustomers,
    required this.totalProviders,
    required this.pendingApplications,
    required this.activeBookings,
    required this.openTickets,
    required this.bookingsToday,
  });
}
