/// Demo-mode repository with CLEARLY LABELLED seed data.
///
/// Everything returned here is sample data for demos and hackathon judging.
/// It must never be presented as real marketplace data — apps show the
/// "Demo mode" banner whenever this repository is in use.
library;

import 'logic.dart';
import 'models.dart';
import 'repositories.dart';

/// Marker interface so apps can detect demo mode and show the banner.
abstract mixin class DemoCapable {
  bool get isDemo => true;
}

class DemoAuthRepository extends AuthRepository with DemoCapable {
  AppUser? _user;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _user;
  }

  @override
  AppUser? get currentUser => _user;

  @override
  Future<String> sendPhoneOtp(String phoneNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return 'demo-verification-id';
  }

  @override
  Future<AppUser> verifyPhoneOtp(String verificationId, String otp) async {
    _user = AppUser(
      id: 'demo-user-1',
      role: UserRole.customer,
      name: 'Demo Customer',
      phone: '+91 98765 43210',
      createdAt: DateTime.now().toUtc(),
    );
    return _user!;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    _user = AppUser(
      id: 'demo-user-1',
      role: UserRole.customer,
      name: 'Demo Customer',
      phone: '+91 98765 43210',
      email: email,
      createdAt: DateTime.now().toUtc(),
    );
    return _user!;
  }

  @override
  Future<AppUser> signUpWithEmail(
      String email, String password, String name, UserRole role) async {
    _user = AppUser(
      id: 'demo-user-1',
      role: role,
      name: name,
      phone: '+91 98765 43210',
      email: email,
      createdAt: DateTime.now().toUtc(),
    );
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

class DemoCatalogRepository extends CatalogRepository with DemoCapable {
  static final _now = DateTime.now().toUtc();

  static final List<ServiceCategory> _categories = [
    const ServiceCategory(
        id: 'plumbing',
        nameEn: 'Plumbing',
        nameHi: 'प्लंबिंग',
        iconName: 'plumbing',
        sortOrder: 1),
    const ServiceCategory(
        id: 'electrical',
        nameEn: 'Electrical',
        nameHi: 'बिजली',
        iconName: 'bolt',
        sortOrder: 2),
    const ServiceCategory(
        id: 'cleaning',
        nameEn: 'Cleaning',
        nameHi: 'सफ़ाई',
        iconName: 'cleaning_services',
        sortOrder: 3),
    const ServiceCategory(
        id: 'appliance',
        nameEn: 'Appliance Repair',
        nameHi: 'उपकरण मरम्मत',
        iconName: 'ac_unit',
        sortOrder: 4),
    const ServiceCategory(
        id: 'painting',
        nameEn: 'Painting',
        nameHi: 'पेंटिंग',
        iconName: 'format_paint',
        sortOrder: 5),
    const ServiceCategory(
        id: 'carpentry',
        nameEn: 'Carpentry',
        nameHi: 'बढ़ई',
        iconName: 'handyman',
        sortOrder: 6),
  ];

  static final List<ProviderProfile> _providers = [
    ProviderProfile(
      id: 'demo-p1',
      businessName: 'Rajesh Electricals',
      ownerName: 'Rajesh Kumar',
      phone: '+91 98110 00001',
      description: 'Sample provider for demo only.',
      experienceYears: 8,
      serviceAreas: const ['Yamuna Vihar', 'Shahdara'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.8,
      ratingCount: 342,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p2',
      businessName: 'Sharma Home Services',
      ownerName: 'Amit Sharma',
      phone: '+91 98110 00002',
      description: 'Sample provider for demo only.',
      experienceYears: 5,
      serviceAreas: const ['Yamuna Vihar', 'Dilshad Garden'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.5,
      ratingCount: 218,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p3',
      businessName: 'LocalFix Riders',
      ownerName: 'Imran Khan',
      phone: '+91 98110 00003',
      description: 'Sample provider for demo only.',
      experienceYears: 3,
      serviceAreas: const ['Yamuna Vihar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.7,
      ratingCount: 190,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p4',
      businessName: 'Gupta Plumbing Works',
      ownerName: 'Suresh Gupta',
      phone: '+91 98110 00004',
      description: 'Sample provider for demo only.',
      experienceYears: 10,
      serviceAreas: const ['Shahdara', 'Vivek Vihar'],
      verificationStatus: VerificationStatus.pending,
      ratingAvg: 4.6,
      ratingCount: 275,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p5',
      businessName: 'Verma Power Solutions',
      ownerName: 'Deepak Verma',
      phone: '+91 98110 00005',
      description: 'Sample provider for demo only.',
      experienceYears: 6,
      serviceAreas: const ['Laxmi Nagar', 'Preet Vihar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.6,
      ratingCount: 156,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p6',
      businessName: 'Khan Electric Works',
      ownerName: 'Salim Khan',
      phone: '+91 98110 00006',
      description: 'Sample provider for demo only.',
      experienceYears: 4,
      serviceAreas: const ['Mayur Vihar', 'Dilshad Garden'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.4,
      ratingCount: 98,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p7',
      businessName: 'Sharma Plumbing Works',
      ownerName: 'Ramesh Sharma',
      phone: '+91 98110 00007',
      description: 'Sample provider for demo only.',
      experienceYears: 9,
      serviceAreas: const ['Yamuna Vihar', 'Shahdara'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.7,
      ratingCount: 203,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p8',
      businessName: 'AquaFix Plumbers',
      ownerName: 'Vikram Singh',
      phone: '+91 98110 00008',
      description: 'Sample provider for demo only.',
      experienceYears: 7,
      serviceAreas: const ['Laxmi Nagar', 'Mayur Vihar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.5,
      ratingCount: 142,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p9',
      businessName: 'Jain Pipe & Tap',
      ownerName: 'Manoj Jain',
      phone: '+91 98110 00009',
      description: 'Sample provider for demo only.',
      experienceYears: 5,
      serviceAreas: const ['Preet Vihar', 'Vivek Vihar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.3,
      ratingCount: 87,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p10',
      businessName: 'Sparkle Home Cleaning',
      ownerName: 'Priya Verma',
      phone: '+91 98110 00010',
      description: 'Sample provider for demo only.',
      experienceYears: 6,
      serviceAreas: const ['Mayur Vihar', 'Preet Vihar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.8,
      ratingCount: 321,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p11',
      businessName: 'ShineBright Services',
      ownerName: 'Kavita Rao',
      phone: '+91 98110 00011',
      description: 'Sample provider for demo only.',
      experienceYears: 4,
      serviceAreas: const ['Laxmi Nagar', 'Shahdara'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.6,
      ratingCount: 187,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p12',
      businessName: 'CleanSweep Professionals',
      ownerName: 'Arjun Mehta',
      phone: '+91 98110 00012',
      description: 'Sample provider for demo only.',
      experienceYears: 3,
      serviceAreas: const ['Dilshad Garden', 'Vivek Vihar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.4,
      ratingCount: 119,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p13',
      businessName: 'GharChamak Cleaning Co',
      ownerName: 'Sunita Devi',
      phone: '+91 98110 00013',
      description: 'Sample provider for demo only.',
      experienceYears: 2,
      serviceAreas: const ['Yamuna Vihar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.2,
      ratingCount: 76,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p14',
      businessName: 'CoolCare Appliances',
      ownerName: 'Rohit Agarwal',
      phone: '+91 98110 00014',
      description: 'Sample provider for demo only.',
      experienceYears: 8,
      serviceAreas: const ['Preet Vihar', 'Laxmi Nagar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.7,
      ratingCount: 264,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p15',
      businessName: 'FixMyFridge Services',
      ownerName: 'Naresh Kumar',
      phone: '+91 98110 00015',
      description: 'Sample provider for demo only.',
      experienceYears: 6,
      serviceAreas: const ['Shahdara', 'Dilshad Garden'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.5,
      ratingCount: 178,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p16',
      businessName: 'VoltEdge Repairs',
      ownerName: 'Sanjay Yadav',
      phone: '+91 98110 00016',
      description: 'Sample provider for demo only.',
      experienceYears: 5,
      serviceAreas: const ['Mayur Vihar', 'Vivek Vihar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.3,
      ratingCount: 94,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p17',
      businessName: 'HomeAppliance Doctors',
      ownerName: 'Prakash Tiwari',
      phone: '+91 98110 00017',
      description: 'Sample provider for demo only.',
      experienceYears: 3,
      serviceAreas: const ['Yamuna Vihar', 'Laxmi Nagar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.1,
      ratingCount: 63,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p18',
      businessName: 'RangRover Painters',
      ownerName: 'Mohan Lal',
      phone: '+91 98110 00018',
      description: 'Sample provider for demo only.',
      experienceYears: 10,
      serviceAreas: const ['Dilshad Garden', 'Shahdara'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.6,
      ratingCount: 189,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p19',
      businessName: 'ColorCraft Studios',
      ownerName: 'Anil Kapoor',
      phone: '+91 98110 00019',
      description: 'Sample provider for demo only.',
      experienceYears: 7,
      serviceAreas: const ['Preet Vihar', 'Mayur Vihar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.4,
      ratingCount: 132,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p20',
      businessName: 'GharSajja Paint Works',
      ownerName: 'Dinesh Prasad',
      phone: '+91 98110 00020',
      description: 'Sample provider for demo only.',
      experienceYears: 4,
      serviceAreas: const ['Laxmi Nagar', 'Vivek Vihar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.2,
      ratingCount: 71,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p21',
      businessName: 'WoodCraft Furniture',
      ownerName: 'Harish Chandra',
      phone: '+91 98110 00021',
      description: 'Sample provider for demo only.',
      experienceYears: 12,
      serviceAreas: const ['Shahdara', 'Yamuna Vihar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.7,
      ratingCount: 215,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p22',
      businessName: 'PerfectWood Works',
      ownerName: 'Gopal Singh',
      phone: '+91 98110 00022',
      description: 'Sample provider for demo only.',
      experienceYears: 8,
      serviceAreas: const ['Dilshad Garden', 'Preet Vihar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.5,
      ratingCount: 148,
      createdAt: _now,
    ),
    ProviderProfile(
      id: 'demo-p23',
      businessName: 'MistriWood Carpentry',
      ownerName: 'Chotu Ram',
      phone: '+91 98110 00023',
      description: 'Sample provider for demo only.',
      experienceYears: 6,
      serviceAreas: const ['Laxmi Nagar', 'Mayur Vihar'],
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.3,
      ratingCount: 89,
      createdAt: _now,
    ),
  ];

  static final Map<String, List<ProviderService>> _services = {
    'demo-p1': [
      const ProviderService(
          id: 'demo-s1',
          providerId: 'demo-p1',
          categoryId: 'electrical',
          name: 'Switch & socket repair',
          priceBasis: PriceBasis.fixed,
          pricePaise: 29900,
          unit: 'visit',
          durationMin: 45),
      const ProviderService(
          id: 'demo-s2',
          providerId: 'demo-p1',
          categoryId: 'electrical',
          name: 'Ceiling fan installation',
          priceBasis: PriceBasis.fixed,
          pricePaise: 49900,
          unit: 'fan',
          durationMin: 60),
    ],
    'demo-p2': [
      const ProviderService(
          id: 'demo-s3',
          providerId: 'demo-p2',
          categoryId: 'electrical',
          name: 'MCB & fuse repair',
          priceBasis: PriceBasis.fixed,
          pricePaise: 24900,
          unit: 'visit',
          durationMin: 40),
    ],
    'demo-p3': [
      const ProviderService(
          id: 'demo-s4',
          providerId: 'demo-p3',
          categoryId: 'electrical',
          name: 'Emergency visit',
          priceBasis: PriceBasis.fixed,
          pricePaise: 19900,
          unit: 'visit',
          durationMin: 30),
    ],
    'demo-p4': [
      const ProviderService(
          id: 'demo-s5',
          providerId: 'demo-p4',
          categoryId: 'plumbing',
          name: 'Tap & mixer repair',
          priceBasis: PriceBasis.fixed,
          pricePaise: 24900,
          unit: 'tap',
          durationMin: 40),
      const ProviderService(
          id: 'demo-s6',
          providerId: 'demo-p4',
          categoryId: 'plumbing',
          name: 'Pipe leakage fix',
          priceBasis: PriceBasis.estimate,
          pricePaise: 49900,
          unit: 'job',
          durationMin: 90),
    ],
    'demo-p5': [
      const ProviderService(
          id: 'demo-s7',
          providerId: 'demo-p5',
          categoryId: 'electrical',
          name: 'Fan repair',
          priceBasis: PriceBasis.fixed,
          pricePaise: 24900,
          unit: 'fan',
          durationMin: 45),
      const ProviderService(
          id: 'demo-s8',
          providerId: 'demo-p5',
          categoryId: 'electrical',
          name: 'Inverter installation',
          priceBasis: PriceBasis.fixed,
          pricePaise: 89900,
          unit: 'unit',
          durationMin: 90),
    ],
    'demo-p6': [
      const ProviderService(
          id: 'demo-s9',
          providerId: 'demo-p6',
          categoryId: 'electrical',
          name: 'Bulb & tube replacement',
          priceBasis: PriceBasis.fixed,
          pricePaise: 27900,
          unit: 'visit',
          durationMin: 30),
      const ProviderService(
          id: 'demo-s10',
          providerId: 'demo-p6',
          categoryId: 'electrical',
          name: 'Wiring repair',
          priceBasis: PriceBasis.estimate,
          pricePaise: 59900,
          unit: 'job',
          durationMin: 120),
    ],
    'demo-p7': [
      const ProviderService(
          id: 'demo-s11',
          providerId: 'demo-p7',
          categoryId: 'plumbing',
          name: 'Bathroom fitting',
          priceBasis: PriceBasis.fixed,
          pricePaise: 39900,
          unit: 'job',
          durationMin: 90),
      const ProviderService(
          id: 'demo-s12',
          providerId: 'demo-p7',
          categoryId: 'plumbing',
          name: 'Tank cleaning',
          priceBasis: PriceBasis.fixed,
          pricePaise: 79900,
          unit: 'tank',
          durationMin: 120),
    ],
    'demo-p8': [
      const ProviderService(
          id: 'demo-s13',
          providerId: 'demo-p8',
          categoryId: 'plumbing',
          name: 'Drain unclogging',
          priceBasis: PriceBasis.fixed,
          pricePaise: 34900,
          unit: 'drain',
          durationMin: 60),
      const ProviderService(
          id: 'demo-s14',
          providerId: 'demo-p8',
          categoryId: 'plumbing',
          name: 'Shower installation',
          priceBasis: PriceBasis.fixed,
          pricePaise: 54900,
          unit: 'shower',
          durationMin: 60),
    ],
    'demo-p9': [
      const ProviderService(
          id: 'demo-s15',
          providerId: 'demo-p9',
          categoryId: 'plumbing',
          name: 'Kitchen sink repair',
          priceBasis: PriceBasis.fixed,
          pricePaise: 29900,
          unit: 'sink',
          durationMin: 45),
      const ProviderService(
          id: 'demo-s16',
          providerId: 'demo-p9',
          categoryId: 'plumbing',
          name: 'Water motor repair',
          priceBasis: PriceBasis.estimate,
          pricePaise: 69900,
          unit: 'job',
          durationMin: 90),
    ],
    'demo-p10': [
      const ProviderService(
          id: 'demo-s17',
          providerId: 'demo-p10',
          categoryId: 'cleaning',
          name: 'Full home deep cleaning',
          priceBasis: PriceBasis.fixed,
          pricePaise: 199900,
          unit: 'home',
          durationMin: 240),
      const ProviderService(
          id: 'demo-s18',
          providerId: 'demo-p10',
          categoryId: 'cleaning',
          name: 'Sofa shampooing',
          priceBasis: PriceBasis.fixed,
          pricePaise: 49900,
          unit: 'sofa',
          durationMin: 90),
    ],
    'demo-p11': [
      const ProviderService(
          id: 'demo-s19',
          providerId: 'demo-p11',
          categoryId: 'cleaning',
          name: 'Bathroom deep cleaning',
          priceBasis: PriceBasis.fixed,
          pricePaise: 59900,
          unit: 'bathroom',
          durationMin: 90),
      const ProviderService(
          id: 'demo-s20',
          providerId: 'demo-p11',
          categoryId: 'cleaning',
          name: 'Kitchen deep cleaning',
          priceBasis: PriceBasis.fixed,
          pricePaise: 89900,
          unit: 'kitchen',
          durationMin: 120),
    ],
    'demo-p12': [
      const ProviderService(
          id: 'demo-s21',
          providerId: 'demo-p12',
          categoryId: 'cleaning',
          name: '1BHK cleaning',
          priceBasis: PriceBasis.fixed,
          pricePaise: 149900,
          unit: 'home',
          durationMin: 180),
      const ProviderService(
          id: 'demo-s22',
          providerId: 'demo-p12',
          categoryId: 'cleaning',
          name: 'Carpet cleaning',
          priceBasis: PriceBasis.fixed,
          pricePaise: 39900,
          unit: 'carpet',
          durationMin: 60),
    ],
    'demo-p13': [
      const ProviderService(
          id: 'demo-s23',
          providerId: 'demo-p13',
          categoryId: 'cleaning',
          name: 'Balcony cleaning',
          priceBasis: PriceBasis.fixed,
          pricePaise: 24900,
          unit: 'balcony',
          durationMin: 45),
      const ProviderService(
          id: 'demo-s24',
          providerId: 'demo-p13',
          categoryId: 'cleaning',
          name: 'Dusting & mopping',
          priceBasis: PriceBasis.fixed,
          pricePaise: 34900,
          unit: 'visit',
          durationMin: 60),
    ],
    'demo-p14': [
      const ProviderService(
          id: 'demo-s25',
          providerId: 'demo-p14',
          categoryId: 'appliance',
          name: 'AC deep service',
          priceBasis: PriceBasis.fixed,
          pricePaise: 79900,
          unit: 'ac',
          durationMin: 90),
      const ProviderService(
          id: 'demo-s26',
          providerId: 'demo-p14',
          categoryId: 'appliance',
          name: 'AC installation',
          priceBasis: PriceBasis.fixed,
          pricePaise: 149900,
          unit: 'ac',
          durationMin: 150),
    ],
    'demo-p15': [
      const ProviderService(
          id: 'demo-s27',
          providerId: 'demo-p15',
          categoryId: 'appliance',
          name: 'Fridge gas refill',
          priceBasis: PriceBasis.fixed,
          pricePaise: 129900,
          unit: 'fridge',
          durationMin: 90),
      const ProviderService(
          id: 'demo-s28',
          providerId: 'demo-p15',
          categoryId: 'appliance',
          name: 'Fridge thermostat repair',
          priceBasis: PriceBasis.fixed,
          pricePaise: 54900,
          unit: 'job',
          durationMin: 60),
    ],
    'demo-p16': [
      const ProviderService(
          id: 'demo-s29',
          providerId: 'demo-p16',
          categoryId: 'appliance',
          name: 'Washing machine repair',
          priceBasis: PriceBasis.fixed,
          pricePaise: 64900,
          unit: 'job',
          durationMin: 90),
      const ProviderService(
          id: 'demo-s30',
          providerId: 'demo-p16',
          categoryId: 'appliance',
          name: 'Microwave repair',
          priceBasis: PriceBasis.fixed,
          pricePaise: 54900,
          unit: 'job',
          durationMin: 60),
    ],
    'demo-p17': [
      const ProviderService(
          id: 'demo-s31',
          providerId: 'demo-p17',
          categoryId: 'appliance',
          name: 'Geyser installation',
          priceBasis: PriceBasis.fixed,
          pricePaise: 89900,
          unit: 'geyser',
          durationMin: 90),
      const ProviderService(
          id: 'demo-s32',
          providerId: 'demo-p17',
          categoryId: 'appliance',
          name: 'Chimney deep cleaning',
          priceBasis: PriceBasis.fixed,
          pricePaise: 99900,
          unit: 'chimney',
          durationMin: 90),
    ],
    'demo-p18': [
      const ProviderService(
          id: 'demo-s33',
          providerId: 'demo-p18',
          categoryId: 'painting',
          name: '1BHK full painting',
          priceBasis: PriceBasis.estimate,
          pricePaise: 149900,
          unit: 'home',
          durationMin: 480),
      const ProviderService(
          id: 'demo-s34',
          providerId: 'demo-p18',
          categoryId: 'painting',
          name: 'Single wall texture',
          priceBasis: PriceBasis.fixed,
          pricePaise: 49900,
          unit: 'wall',
          durationMin: 180),
    ],
    'demo-p19': [
      const ProviderService(
          id: 'demo-s35',
          providerId: 'demo-p19',
          categoryId: 'painting',
          name: '2BHK full painting',
          priceBasis: PriceBasis.estimate,
          pricePaise: 199900,
          unit: 'home',
          durationMin: 720),
      const ProviderService(
          id: 'demo-s36',
          providerId: 'demo-p19',
          categoryId: 'painting',
          name: 'Waterproofing',
          priceBasis: PriceBasis.estimate,
          pricePaise: 119900,
          unit: 'job',
          durationMin: 300),
    ],
    'demo-p20': [
      const ProviderService(
          id: 'demo-s37',
          providerId: 'demo-p20',
          categoryId: 'painting',
          name: 'Door & window painting',
          priceBasis: PriceBasis.fixed,
          pricePaise: 34900,
          unit: 'job',
          durationMin: 180),
      const ProviderService(
          id: 'demo-s38',
          providerId: 'demo-p20',
          categoryId: 'painting',
          name: 'Putty & primer',
          priceBasis: PriceBasis.fixed,
          pricePaise: 44900,
          unit: 'room',
          durationMin: 240),
    ],
    'demo-p21': [
      const ProviderService(
          id: 'demo-s39',
          providerId: 'demo-p21',
          categoryId: 'carpentry',
          name: 'Custom wardrobe',
          priceBasis: PriceBasis.estimate,
          pricePaise: 199900,
          unit: 'piece',
          durationMin: 480),
      const ProviderService(
          id: 'demo-s40',
          providerId: 'demo-p21',
          categoryId: 'carpentry',
          name: 'Bed repair',
          priceBasis: PriceBasis.fixed,
          pricePaise: 49900,
          unit: 'bed',
          durationMin: 120),
    ],
    'demo-p22': [
      const ProviderService(
          id: 'demo-s41',
          providerId: 'demo-p22',
          categoryId: 'carpentry',
          name: 'Modular kitchen repair',
          priceBasis: PriceBasis.estimate,
          pricePaise: 149900,
          unit: 'job',
          durationMin: 360),
      const ProviderService(
          id: 'demo-s42',
          providerId: 'demo-p22',
          categoryId: 'carpentry',
          name: 'Door lock fitting',
          priceBasis: PriceBasis.fixed,
          pricePaise: 29900,
          unit: 'lock',
          durationMin: 45),
    ],
    'demo-p23': [
      const ProviderService(
          id: 'demo-s43',
          providerId: 'demo-p23',
          categoryId: 'carpentry',
          name: 'Furniture polishing',
          priceBasis: PriceBasis.fixed,
          pricePaise: 79900,
          unit: 'job',
          durationMin: 240),
      const ProviderService(
          id: 'demo-s44',
          providerId: 'demo-p23',
          categoryId: 'carpentry',
          name: 'Shelf installation',
          priceBasis: PriceBasis.fixed,
          pricePaise: 34900,
          unit: 'shelf',
          durationMin: 90),
    ],
  };

  /// Which categories each demo provider serves (demo-only mapping).
  static const Map<String, List<String>> _providerCategories = {
    'demo-p1': ['electrical'],
    'demo-p2': ['electrical'],
    'demo-p3': ['electrical'],
    'demo-p4': ['plumbing'],
    'demo-p5': ['electrical'],
    'demo-p6': ['electrical'],
    'demo-p7': ['plumbing'],
    'demo-p8': ['plumbing'],
    'demo-p9': ['plumbing'],
    'demo-p10': ['cleaning'],
    'demo-p11': ['cleaning'],
    'demo-p12': ['cleaning'],
    'demo-p13': ['cleaning'],
    'demo-p14': ['appliance'],
    'demo-p15': ['appliance'],
    'demo-p16': ['appliance'],
    'demo-p17': ['appliance'],
    'demo-p18': ['painting'],
    'demo-p19': ['painting'],
    'demo-p20': ['painting'],
    'demo-p21': ['carpentry'],
    'demo-p22': ['carpentry'],
    'demo-p23': ['carpentry'],
  };

  @override
  Future<List<ServiceCategory>> categories() async =>
      _categories.where((c) => c.active).toList();

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
    var list = _providers.where((p) => p.active).toList();
    if (categoryId != null) {
      list = list
          .where((p) => _providerCategories[p.id]?.contains(categoryId) ?? false)
          .toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      list = list
          .where((p) =>
              p.businessName.toLowerCase().contains(q) ||
              p.ownerName.toLowerCase().contains(q))
          .toList();
    }
    if (minRating != null) {
      list = list.where((p) => p.ratingAvg >= minRating).toList();
    }
    // NOTE (demo): price filtering needs per-service prices; skipped honestly.
    switch (sortBy) {
      case 'rating':
        list.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
      case 'experience':
        list.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
    }
    return list.skip(offset).take(limit).toList();
  }

  @override
  Future<ProviderProfile?> provider(String providerId) async {
    try {
      return _providers.firstWhere((p) => p.id == providerId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ProviderService>> providerServices(String providerId,
      {bool activeOnly = true}) async {
    final list = _services[providerId] ?? const [];
    return activeOnly ? list.where((s) => s.active).toList() : list.toList();
  }

  @override
  Future<List<Review>> providerReviews(String providerId,
      {bool includeHidden = false}) async {
    return const [];
  }

  @override
  Future<double> providerRating(String providerId) async {
    final p = await provider(providerId);
    return p?.ratingAvg ?? 0;
  }
}

class DemoBookingRepository extends BookingRepository with DemoCapable {
  final List<Booking> _bookings = [];
  final Set<String> _reviewed = {};

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
    if (items.isEmpty) throw ArgumentError('Select at least one service');
    if (scheduledAt.isBefore(DateTime.now().toUtc())) {
      throw ArgumentError('Slot must be in the future');
    }
    final totals = calcTotals(items, commissionBps: 1000);
    final now = DateTime.now().toUtc();
    final booking = Booking(
      id: 'demo-b${_bookings.length + 1}',
      customerId: customerId,
      providerId: providerId,
      providerName: 'Demo Provider',
      items: items,
      subtotalPaise: totals.subtotalPaise,
      platformFeePaise: totals.platformFeePaise,
      totalPaise: totals.totalPaise,
      addressSnapshot: addressSnapshot,
      addressId: addressId,
      scheduledAt: scheduledAt,
      status: BookingStatus.pending,
      paymentStatus: paymentStatus,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    _bookings.insert(0, booking);
    return booking;
  }

  @override
  Future<List<Booking>> myBookings(String customerId,
      {BookingStatus? statusFilter}) async {
    var list = _bookings.where((b) => b.customerId == customerId).toList();
    if (statusFilter != null) {
      list = list.where((b) => b.status == statusFilter).toList();
    }
    return list;
  }

  @override
  Future<Booking?> booking(String bookingId) async {
    try {
      return _bookings.firstWhere((b) => b.id == bookingId);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<Booking?> watchBooking(String bookingId) async* {
    yield await booking(bookingId);
  }

  @override
  Future<void> cancelBooking(String bookingId, String reason) async {
    final i = _bookings.indexWhere((b) => b.id == bookingId);
    if (i == -1) throw StateError('Booking not found');
    final b = _bookings[i];
    if (!canTransition(b.status, BookingStatus.cancelled, UserRole.customer)) {
      throw StateError('Cannot cancel booking in status ${b.status.name}');
    }
    _bookings[i] = Booking(
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
      status: BookingStatus.cancelled,
      paymentStatus: b.paymentStatus,
      notes: b.notes,
      cancelReason: reason,
      createdAt: b.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> rescheduleBooking(String bookingId, DateTime newSlot) async {
    final i = _bookings.indexWhere((b) => b.id == bookingId);
    if (i == -1) throw StateError('Booking not found');
    final b = _bookings[i];
    _bookings[i] = Booking(
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
      scheduledAt: newSlot,
      status: b.status,
      paymentStatus: b.paymentStatus,
      notes: b.notes,
      createdAt: b.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<Review> submitReview({
    required String bookingId,
    required String customerId,
    required int rating,
    required String text,
  }) async {
    final b = await booking(bookingId);
    if (b == null) throw StateError('Booking not found');
    if (!isReviewEligible(
        booking: b, customerId: customerId, alreadyReviewed: _reviewed.contains(bookingId))) {
      throw StateError('Not eligible to review this booking');
    }
    _reviewed.add(bookingId);
    return Review(
      id: 'demo-r${_reviewed.length}',
      bookingId: bookingId,
      providerId: b.providerId,
      customerId: customerId,
      customerName: 'Demo Customer',
      rating: rating,
      text: text,
      createdAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<bool> hasReviewed(String bookingId) async =>
      _reviewed.contains(bookingId);
}

class DemoAddressRepository extends AddressRepository with DemoCapable {
  final List<Address> _addresses = [
    Address(
      id: 'demo-a1',
      userId: 'demo-user-1',
      label: 'Home',
      line1: 'B-42, Gali No. 3',
      landmark: 'Near Yamuna Vihar Bus Stand',
      city: 'Delhi',
      pincode: '110053',
      isDefault: true,
    ),
  ];

  @override
  Future<List<Address>> myAddresses(String userId) async =>
      _addresses.where((a) => a.userId == userId).toList();

  @override
  Future<void> saveAddress(Address address) async {
    final i = _addresses.indexWhere((a) => a.id == address.id);
    if (i == -1) {
      _addresses.add(address);
    } else {
      _addresses[i] = address;
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    _addresses.removeWhere((a) => a.id == addressId);
  }

  @override
  Future<void> setDefault(String userId, String addressId) async {
    for (var i = 0; i < _addresses.length; i++) {
      final a = _addresses[i];
      if (a.userId != userId) continue;
      _addresses[i] = Address(
        id: a.id,
        userId: a.userId,
        label: a.label,
        line1: a.line1,
        line2: a.line2,
        landmark: a.landmark,
        city: a.city,
        pincode: a.pincode,
        lat: a.lat,
        lng: a.lng,
        isDefault: a.id == addressId,
      );
    }
  }
}

class DemoSupportRepository extends SupportRepository with DemoCapable {
  final List<SupportTicket> _tickets = [];

  @override
  Future<SupportTicket> createTicket({
    required String userId,
    required UserRole userRole,
    String? bookingId,
    required String category,
    required String description,
    List<String> evidenceUrls = const [],
  }) async {
    final now = DateTime.now().toUtc();
    final t = SupportTicket(
      id: 'demo-t${_tickets.length + 1}',
      userId: userId,
      userRole: userRole,
      bookingId: bookingId,
      category: category,
      description: description,
      evidenceUrls: evidenceUrls,
      createdAt: now,
      updatedAt: now,
    );
    _tickets.insert(0, t);
    return t;
  }

  @override
  Future<List<SupportTicket>> myTickets(String userId) async =>
      _tickets.where((t) => t.userId == userId).toList();
}

class DemoNotificationRepository extends NotificationRepository
    with DemoCapable {
  @override
  Stream<List<NotificationItem>> watch(String userId) async* {
    yield const [];
  }

  @override
  Future<void> markRead(String notificationId) async {}

  @override
  Future<void> saveFcmToken(String userId, String token) async {}
}

/// Bundles all demo repositories for an app.
class DemoRepositories {
  final DemoAuthRepository auth = DemoAuthRepository();
  final DemoCatalogRepository catalog = DemoCatalogRepository();
  final DemoBookingRepository bookings = DemoBookingRepository();
  final DemoAddressRepository addresses = DemoAddressRepository();
  final DemoSupportRepository support = DemoSupportRepository();
  final DemoNotificationRepository notifications =
      DemoNotificationRepository();
}
