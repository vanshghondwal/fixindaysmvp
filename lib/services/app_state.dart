import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Local app state for the demo build.
///
/// Firestore wiring points are marked with `TODO(firebase)`.
/// When Firebase is connected, `addBooking` / `cancelBooking` should also
/// write to `bookings` collection via FirebaseService.
class AppState extends ChangeNotifier {
  final List<Booking> _bookings = [];

  List<Booking> get bookings => List.unmodifiable(_bookings);

  String userName = 'Vansh';
  String userAddress = 'Yamuna Vihar, Delhi';

  void addBooking(Booking booking) {
    _bookings.insert(0, booking);
    notifyListeners();
    // TODO(firebase): FirebaseService.saveBooking(booking);
  }

  void cancelBooking(String id) {
    final i = _bookings.indexWhere((b) => b.id == id);
    if (i != -1) {
      _bookings[i] = _bookings[i].copyWith(status: 'Cancelled');
      notifyListeners();
      // TODO(firebase): FirebaseService.updateBookingStatus(id, 'Cancelled');
    }
  }
}
