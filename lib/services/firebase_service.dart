import '../models/models.dart';

/// Firebase integration layer — ready to be switched on.
///
/// Steps to connect (needs the user's Google account):
///   1. `dart pub global activate flutterfire_cli`
///   2. `flutterfire configure` (picks the Firebase project)
///   3. Generated `firebase_options.dart` is imported by main.dart.
///   4. Replace the mock data source in screens with these methods.
///
/// Collections used (per deck architecture):
///   users      — profile, addresses
///   providers  — name, category, rating, pricing, verified
///   bookings   — user ref, provider ref, slot, address, status
///   reviews    — booking ref, rating, text
class FirebaseService {
  FirebaseService._();

  /// Call once in main() after Firebase.initializeApp.
  static Future<void> init() async {
    // TODO(firebase): await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
  }

  // --- Firestore hooks (stubbed for the mock-data demo build) ---

  static Future<List<Provider>> fetchProviders(String categoryId) async {
    // TODO(firebase): query 'providers' where categoryId == categoryId
    throw UnimplementedError('Connect Firebase first — see README.md');
  }

  static Future<void> saveBooking(Booking booking) async {
    // TODO(firebase): add to 'bookings' collection
    throw UnimplementedError('Connect Firebase first — see README.md');
  }

  static Future<void> updateBookingStatus(String id, String status) async {
    // TODO(firebase): update 'bookings/$id'
    throw UnimplementedError('Connect Firebase first — see README.md');
  }
}
