/// FixinDays domain models shared by customer, partner and admin apps.
///
/// Money is stored as integer paise to avoid floating point errors.
/// Timestamps are stored as UTC milliseconds since epoch in Firestore.
library;

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum UserRole { customer, provider, admin }

enum BookingStatus {
  pending, // created, awaiting provider response
  accepted, // provider accepted, awaiting confirmation finalization
  rejected, // provider declined
  confirmed, // scheduled and locked in
  enRoute, // provider on the way
  arrived, // provider arrived at address
  inProgress, // service underway
  completed, // service done
  cancelled, // cancelled by customer or provider
  disputed, // under dispute review
}

enum PaymentStatus {
  unpaid,
  pending,
  paid,
  failed,
  refunded,
  cashOnService,
}

enum PriceBasis { fixed, estimate, quote }

enum VerificationStatus {
  notApplied,
  pending,
  approved,
  rejected,
  needsInfo,
  suspended,
}

enum TicketStatus { open, inProgress, resolved, closed }

enum NotificationKind { booking, payment, review, system, support }

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

DateTime _dt(dynamic v) => v is int
    ? DateTime.fromMillisecondsSinceEpoch(v, isUtc: true)
    : DateTime.now().toUtc();

int _ts(DateTime d) => d.toUtc().millisecondsSinceEpoch;

// ---------------------------------------------------------------------------
// AppUser
// ---------------------------------------------------------------------------

class AppUser {
  final String id;
  final UserRole role;
  final String name;
  final String phone;
  final String? email;
  final String? photoUrl;
  final String language; // 'en' | 'hi'
  final bool isDeleted;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.role,
    required this.name,
    required this.phone,
    this.email,
    this.photoUrl,
    this.language = 'en',
    this.isDeleted = false,
    required this.createdAt,
  });

  factory AppUser.fromJson(String id, Map<String, dynamic> j) => AppUser(
        id: id,
        role: UserRole.values.firstWhere(
          (e) => e.name == j['role'],
          orElse: () => UserRole.customer,
        ),
        name: (j['name'] ?? '') as String,
        phone: (j['phone'] ?? '') as String,
        email: j['email'] as String?,
        photoUrl: j['photoUrl'] as String?,
        language: (j['language'] ?? 'en') as String,
        isDeleted: (j['isDeleted'] ?? false) as bool,
        createdAt: _dt(j['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'name': name,
        'phone': phone,
        'email': email,
        'photoUrl': photoUrl,
        'language': language,
        'isDeleted': isDeleted,
        'createdAt': _ts(createdAt),
      };
}

// ---------------------------------------------------------------------------
// Address
// ---------------------------------------------------------------------------

class Address {
  final String id;
  final String userId;
  final String label; // Home / Work / Other
  final String line1;
  final String? line2;
  final String? landmark;
  final String city;
  final String pincode;
  final double? lat;
  final double? lng;
  final bool isDefault;

  const Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.line1,
    this.line2,
    this.landmark,
    required this.city,
    required this.pincode,
    this.lat,
    this.lng,
    this.isDefault = false,
  });

  String get short =>
      [line1, landmark, city, pincode].whereType<String>().join(', ');

  factory Address.fromJson(String id, Map<String, dynamic> j) => Address(
        id: id,
        userId: (j['userId'] ?? '') as String,
        label: (j['label'] ?? 'Home') as String,
        line1: (j['line1'] ?? '') as String,
        line2: j['line2'] as String?,
        landmark: j['landmark'] as String?,
        city: (j['city'] ?? '') as String,
        pincode: (j['pincode'] ?? '') as String,
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
        isDefault: (j['isDefault'] ?? false) as bool,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'label': label,
        'line1': line1,
        'line2': line2,
        'landmark': landmark,
        'city': city,
        'pincode': pincode,
        'lat': lat,
        'lng': lng,
        'isDefault': isDefault,
      };
}

// ---------------------------------------------------------------------------
// ServiceCategory
// ---------------------------------------------------------------------------

class ServiceCategory {
  final String id;
  final String nameEn;
  final String nameHi;
  final String iconName; // material icon key, resolved by the app
  final int sortOrder;
  final bool active;

  const ServiceCategory({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.iconName,
    this.sortOrder = 0,
    this.active = true,
  });

  String name(String lang) => lang == 'hi' ? nameHi : nameEn;

  factory ServiceCategory.fromJson(String id, Map<String, dynamic> j) =>
      ServiceCategory(
        id: id,
        nameEn: (j['nameEn'] ?? '') as String,
        nameHi: (j['nameHi'] ?? j['nameEn'] ?? '') as String,
        iconName: (j['iconName'] ?? 'handyman') as String,
        sortOrder: (j['sortOrder'] ?? 0) as int,
        active: (j['active'] ?? true) as bool,
      );

  Map<String, dynamic> toJson() => {
        'nameEn': nameEn,
        'nameHi': nameHi,
        'iconName': iconName,
        'sortOrder': sortOrder,
        'active': active,
      };
}

// ---------------------------------------------------------------------------
// ProviderProfile
// ---------------------------------------------------------------------------

class ProviderProfile {
  final String id; // == auth uid of the provider
  final String businessName;
  final String ownerName;
  final String phone;
  final String? photoUrl;
  final String description;
  final int experienceYears;
  final List<String> serviceAreas;
  final VerificationStatus verificationStatus;
  final double ratingAvg;
  final int ratingCount;
  final bool active;
  final DateTime createdAt;

  const ProviderProfile({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.phone,
    this.photoUrl,
    this.description = '',
    this.experienceYears = 0,
    this.serviceAreas = const [],
    this.verificationStatus = VerificationStatus.pending,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.active = true,
    required this.createdAt,
  });

  bool get isVerified => verificationStatus == VerificationStatus.approved;

  factory ProviderProfile.fromJson(String id, Map<String, dynamic> j) =>
      ProviderProfile(
        id: id,
        businessName: (j['businessName'] ?? '') as String,
        ownerName: (j['ownerName'] ?? '') as String,
        phone: (j['phone'] ?? '') as String,
        photoUrl: j['photoUrl'] as String?,
        description: (j['description'] ?? '') as String,
        experienceYears: (j['experienceYears'] ?? 0) as int,
        serviceAreas: List<String>.from(j['serviceAreas'] ?? const []),
        verificationStatus: VerificationStatus.values.firstWhere(
          (e) => e.name == j['verificationStatus'],
          orElse: () => VerificationStatus.pending,
        ),
        ratingAvg: ((j['ratingAvg'] ?? 0) as num).toDouble(),
        ratingCount: (j['ratingCount'] ?? 0) as int,
        active: (j['active'] ?? true) as bool,
        createdAt: _dt(j['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        'ownerName': ownerName,
        'phone': phone,
        'photoUrl': photoUrl,
        'description': description,
        'experienceYears': experienceYears,
        'serviceAreas': serviceAreas,
        'verificationStatus': verificationStatus.name,
        'ratingAvg': ratingAvg,
        'ratingCount': ratingCount,
        'active': active,
        'createdAt': _ts(createdAt),
      };
}

// ---------------------------------------------------------------------------
// ProviderService
// ---------------------------------------------------------------------------

class ProviderService {
  final String id;
  final String providerId;
  final String categoryId;
  final String name;
  final String description;
  final PriceBasis priceBasis;
  final int pricePaise; // fixed price or starting estimate
  final String unit; // e.g. 'visit', 'hour', 'room'
  final int? durationMin;
  final bool active;

  const ProviderService({
    required this.id,
    required this.providerId,
    required this.categoryId,
    required this.name,
    this.description = '',
    this.priceBasis = PriceBasis.fixed,
    required this.pricePaise,
    this.unit = 'visit',
    this.durationMin,
    this.active = true,
  });

  factory ProviderService.fromJson(String id, Map<String, dynamic> j) =>
      ProviderService(
        id: id,
        providerId: (j['providerId'] ?? '') as String,
        categoryId: (j['categoryId'] ?? '') as String,
        name: (j['name'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        priceBasis: PriceBasis.values.firstWhere(
          (e) => e.name == j['priceBasis'],
          orElse: () => PriceBasis.fixed,
        ),
        pricePaise: (j['pricePaise'] ?? 0) as int,
        unit: (j['unit'] ?? 'visit') as String,
        durationMin: j['durationMin'] as int?,
        active: (j['active'] ?? true) as bool,
      );

  Map<String, dynamic> toJson() => {
        'providerId': providerId,
        'categoryId': categoryId,
        'name': name,
        'description': description,
        'priceBasis': priceBasis.name,
        'pricePaise': pricePaise,
        'unit': unit,
        'durationMin': durationMin,
        'active': active,
      };
}

// ---------------------------------------------------------------------------
// Booking
// ---------------------------------------------------------------------------

class BookingLineItem {
  final String serviceId;
  final String serviceName;
  final int quantity;
  final int unitPricePaise;
  final PriceBasis priceBasis;

  const BookingLineItem({
    required this.serviceId,
    required this.serviceName,
    this.quantity = 1,
    required this.unitPricePaise,
    this.priceBasis = PriceBasis.fixed,
  });

  int get lineTotalPaise => unitPricePaise * quantity;

  factory BookingLineItem.fromJson(Map<String, dynamic> j) => BookingLineItem(
        serviceId: (j['serviceId'] ?? '') as String,
        serviceName: (j['serviceName'] ?? '') as String,
        quantity: (j['quantity'] ?? 1) as int,
        unitPricePaise: (j['unitPricePaise'] ?? 0) as int,
        priceBasis: PriceBasis.values.firstWhere(
          (e) => e.name == j['priceBasis'],
          orElse: () => PriceBasis.fixed,
        ),
      );

  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'serviceName': serviceName,
        'quantity': quantity,
        'unitPricePaise': unitPricePaise,
        'priceBasis': priceBasis.name,
      };
}

class Booking {
  final String id;
  final String customerId;
  final String providerId;
  final String providerName;
  final List<BookingLineItem> items;
  final int subtotalPaise;
  final int platformFeePaise;
  final int totalPaise;
  final String addressSnapshot;
  final String? addressId;
  final DateTime scheduledAt;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? arrivalCodeHash; // sha256, never the plain code
  final String? notes;
  final String? cancelReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.providerName,
    required this.items,
    required this.subtotalPaise,
    required this.platformFeePaise,
    required this.totalPaise,
    required this.addressSnapshot,
    this.addressId,
    required this.scheduledAt,
    this.status = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.unpaid,
    this.arrivalCodeHash,
    this.notes,
    this.cancelReason,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => const {
        BookingStatus.pending,
        BookingStatus.accepted,
        BookingStatus.confirmed,
        BookingStatus.enRoute,
        BookingStatus.arrived,
        BookingStatus.inProgress,
      }.contains(status);

  factory Booking.fromJson(String id, Map<String, dynamic> j) => Booking(
        id: id,
        customerId: (j['customerId'] ?? '') as String,
        providerId: (j['providerId'] ?? '') as String,
        providerName: (j['providerName'] ?? '') as String,
        items: (j['items'] as List? ?? const [])
            .map((e) => BookingLineItem.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList(),
        subtotalPaise: (j['subtotalPaise'] ?? 0) as int,
        platformFeePaise: (j['platformFeePaise'] ?? 0) as int,
        totalPaise: (j['totalPaise'] ?? 0) as int,
        addressSnapshot: (j['addressSnapshot'] ?? '') as String,
        addressId: j['addressId'] as String?,
        scheduledAt: _dt(j['scheduledAt']),
        status: BookingStatus.values.firstWhere(
          (e) => e.name == j['status'],
          orElse: () => BookingStatus.pending,
        ),
        paymentStatus: PaymentStatus.values.firstWhere(
          (e) => e.name == j['paymentStatus'],
          orElse: () => PaymentStatus.unpaid,
        ),
        arrivalCodeHash: j['arrivalCodeHash'] as String?,
        notes: j['notes'] as String?,
        cancelReason: j['cancelReason'] as String?,
        createdAt: _dt(j['createdAt']),
        updatedAt: _dt(j['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'providerId': providerId,
        'providerName': providerName,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotalPaise': subtotalPaise,
        'platformFeePaise': platformFeePaise,
        'totalPaise': totalPaise,
        'addressSnapshot': addressSnapshot,
        'addressId': addressId,
        'scheduledAt': _ts(scheduledAt),
        'status': status.name,
        'paymentStatus': paymentStatus.name,
        'arrivalCodeHash': arrivalCodeHash,
        'notes': notes,
        'cancelReason': cancelReason,
        'createdAt': _ts(createdAt),
        'updatedAt': _ts(updatedAt),
      };
}

// ---------------------------------------------------------------------------
// BookingEvent (audit trail)
// ---------------------------------------------------------------------------

class BookingEvent {
  final String id;
  final String bookingId;
  final String type;
  final UserRole? actorRole;
  final String? actorId;
  final String? note;
  final DateTime createdAt;

  const BookingEvent({
    required this.id,
    required this.bookingId,
    required this.type,
    this.actorRole,
    this.actorId,
    this.note,
    required this.createdAt,
  });

  factory BookingEvent.fromJson(String id, Map<String, dynamic> j) =>
      BookingEvent(
        id: id,
        bookingId: (j['bookingId'] ?? '') as String,
        type: (j['type'] ?? '') as String,
        actorRole: j['actorRole'] == null
            ? null
            : UserRole.values.firstWhere(
                (e) => e.name == j['actorRole'],
                orElse: () => UserRole.customer,
              ),
        actorId: j['actorId'] as String?,
        note: j['note'] as String?,
        createdAt: _dt(j['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'type': type,
        'actorRole': actorRole?.name,
        'actorId': actorId,
        'note': note,
        'createdAt': _ts(createdAt),
      };
}

// ---------------------------------------------------------------------------
// Review
// ---------------------------------------------------------------------------

class Review {
  final String id;
  final String bookingId;
  final String providerId;
  final String customerId;
  final String customerName;
  final int rating; // 1..5
  final String text;
  final bool hidden; // moderation
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.bookingId,
    required this.providerId,
    required this.customerId,
    required this.customerName,
    required this.rating,
    this.text = '',
    this.hidden = false,
    required this.createdAt,
  });

  factory Review.fromJson(String id, Map<String, dynamic> j) => Review(
        id: id,
        bookingId: (j['bookingId'] ?? '') as String,
        providerId: (j['providerId'] ?? '') as String,
        customerId: (j['customerId'] ?? '') as String,
        customerName: (j['customerName'] ?? '') as String,
        rating: (j['rating'] ?? 5) as int,
        text: (j['text'] ?? '') as String,
        hidden: (j['hidden'] ?? false) as bool,
        createdAt: _dt(j['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'providerId': providerId,
        'customerId': customerId,
        'customerName': customerName,
        'rating': rating,
        'text': text,
        'hidden': hidden,
        'createdAt': _ts(createdAt),
      };
}

// ---------------------------------------------------------------------------
// ProviderApplication (verification)
// ---------------------------------------------------------------------------

class ProviderApplication {
  final String id;
  final String providerId;
  final Map<String, String> documents; // docType -> storage path (private)
  final VerificationStatus status;
  final String? adminNote;
  final String? reviewedBy;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  const ProviderApplication({
    required this.id,
    required this.providerId,
    this.documents = const {},
    this.status = VerificationStatus.pending,
    this.adminNote,
    this.reviewedBy,
    required this.submittedAt,
    this.reviewedAt,
  });

  factory ProviderApplication.fromJson(String id, Map<String, dynamic> j) =>
      ProviderApplication(
        id: id,
        providerId: (j['providerId'] ?? '') as String,
        documents: Map<String, String>.from(j['documents'] ?? const {}),
        status: VerificationStatus.values.firstWhere(
          (e) => e.name == j['status'],
          orElse: () => VerificationStatus.pending,
        ),
        adminNote: j['adminNote'] as String?,
        reviewedBy: j['reviewedBy'] as String?,
        submittedAt: _dt(j['submittedAt']),
        reviewedAt:
            j['reviewedAt'] == null ? null : _dt(j['reviewedAt']),
      );

  Map<String, dynamic> toJson() => {
        'providerId': providerId,
        'documents': documents,
        'status': status.name,
        'adminNote': adminNote,
        'reviewedBy': reviewedBy,
        'submittedAt': _ts(submittedAt),
        'reviewedAt': reviewedAt == null ? null : _ts(reviewedAt!),
      };
}

// ---------------------------------------------------------------------------
// NotificationItem
// ---------------------------------------------------------------------------

class NotificationItem {
  final String id;
  final String userId;
  final NotificationKind kind;
  final String title;
  final String body;
  final Map<String, String> data;
  final bool read;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.body,
    this.data = const {},
    this.read = false,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(String id, Map<String, dynamic> j) =>
      NotificationItem(
        id: id,
        userId: (j['userId'] ?? '') as String,
        kind: NotificationKind.values.firstWhere(
          (e) => e.name == j['kind'],
          orElse: () => NotificationKind.system,
        ),
        title: (j['title'] ?? '') as String,
        body: (j['body'] ?? '') as String,
        data: Map<String, String>.from(j['data'] ?? const {}),
        read: (j['read'] ?? false) as bool,
        createdAt: _dt(j['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'kind': kind.name,
        'title': title,
        'body': body,
        'data': data,
        'read': read,
        'createdAt': _ts(createdAt),
      };
}

// ---------------------------------------------------------------------------
// SupportTicket
// ---------------------------------------------------------------------------

class SupportTicket {
  final String id;
  final String userId;
  final UserRole userRole;
  final String? bookingId;
  final String category;
  final String description;
  final List<String> evidenceUrls;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.userRole,
    this.bookingId,
    required this.category,
    required this.description,
    this.evidenceUrls = const [],
    this.status = TicketStatus.open,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicket.fromJson(String id, Map<String, dynamic> j) =>
      SupportTicket(
        id: id,
        userId: (j['userId'] ?? '') as String,
        userRole: UserRole.values.firstWhere(
          (e) => e.name == j['userRole'],
          orElse: () => UserRole.customer,
        ),
        bookingId: j['bookingId'] as String?,
        category: (j['category'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        evidenceUrls: List<String>.from(j['evidenceUrls'] ?? const []),
        status: TicketStatus.values.firstWhere(
          (e) => e.name == j['status'],
          orElse: () => TicketStatus.open,
        ),
        createdAt: _dt(j['createdAt']),
        updatedAt: _dt(j['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userRole': userRole.name,
        'bookingId': bookingId,
        'category': category,
        'description': description,
        'evidenceUrls': evidenceUrls,
        'status': status.name,
        'createdAt': _ts(createdAt),
        'updatedAt': _ts(updatedAt),
      };
}

// ---------------------------------------------------------------------------
// PlatformSettings
// ---------------------------------------------------------------------------

class PlatformSettings {
  final int commissionBps; // e.g. 1000 = 10%
  final String currency; // 'INR'
  final String supportPhone;
  final String supportEmail;
  final bool cashOnServiceEnabled;
  final int providerResponseTimeoutMin;

  const PlatformSettings({
    this.commissionBps = 1000,
    this.currency = 'INR',
    this.supportPhone = '',
    this.supportEmail = '',
    this.cashOnServiceEnabled = true,
    this.providerResponseTimeoutMin = 60,
  });

  factory PlatformSettings.fromJson(Map<String, dynamic> j) =>
      PlatformSettings(
        commissionBps: (j['commissionBps'] ?? 1000) as int,
        currency: (j['currency'] ?? 'INR') as String,
        supportPhone: (j['supportPhone'] ?? '') as String,
        supportEmail: (j['supportEmail'] ?? '') as String,
        cashOnServiceEnabled: (j['cashOnServiceEnabled'] ?? true) as bool,
        providerResponseTimeoutMin:
            (j['providerResponseTimeoutMin'] ?? 60) as int,
      );

  Map<String, dynamic> toJson() => {
        'commissionBps': commissionBps,
        'currency': currency,
        'supportPhone': supportPhone,
        'supportEmail': supportEmail,
        'cashOnServiceEnabled': cashOnServiceEnabled,
        'providerResponseTimeoutMin': providerResponseTimeoutMin,
      };
}

// ---------------------------------------------------------------------------
// AdminAuditLog
// ---------------------------------------------------------------------------

class AdminAuditLog {
  final String id;
  final String adminId;
  final String action;
  final String targetType;
  final String targetId;
  final String details;
  final DateTime createdAt;

  const AdminAuditLog({
    required this.id,
    required this.adminId,
    required this.action,
    required this.targetType,
    required this.targetId,
    this.details = '',
    required this.createdAt,
  });

  factory AdminAuditLog.fromJson(String id, Map<String, dynamic> j) =>
      AdminAuditLog(
        id: id,
        adminId: (j['adminId'] ?? '') as String,
        action: (j['action'] ?? '') as String,
        targetType: (j['targetType'] ?? '') as String,
        targetId: (j['targetId'] ?? '') as String,
        details: (j['details'] ?? '') as String,
        createdAt: _dt(j['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'adminId': adminId,
        'action': action,
        'targetType': targetType,
        'targetId': targetId,
        'details': details,
        'createdAt': _ts(createdAt),
      };
}
