import 'package:flutter/material.dart';
import '../models/models.dart';

/// Mock catalogue mirroring the pitch-deck demo data.
/// Swap with Firestore reads via FirebaseService once connected.
class MockData {
  static const List<ServiceCategory> categories = [
    ServiceCategory(
      id: 'plumber',
      name: 'Plumber',
      icon: Icons.plumbing,
      tagline: 'Taps, pipes & leaks',
    ),
    ServiceCategory(
      id: 'electrician',
      name: 'Electrician',
      icon: Icons.bolt,
      tagline: 'Wiring, switches & fans',
    ),
    ServiceCategory(
      id: 'carpenter',
      name: 'Carpenter',
      icon: Icons.handyman,
      tagline: 'Furniture & fittings',
    ),
    ServiceCategory(
      id: 'painter',
      name: 'Painter',
      icon: Icons.format_paint,
      tagline: 'Walls & rooms',
    ),
    ServiceCategory(
      id: 'ac',
      name: 'AC Repair',
      icon: Icons.ac_unit,
      tagline: 'Cooling & servicing',
    ),
    ServiceCategory(
      id: 'more',
      name: 'Many More',
      icon: Icons.apps,
      tagline: 'Coming soon',
    ),
  ];

  static const List<Provider> providers = [
    // --- Electricians (deck data) ---
    Provider(
      id: 'p1',
      categoryId: 'electrician',
      name: 'Rajesh Electricals',
      rating: 4.8,
      reviewsCount: 342,
      priceOnwards: 299,
      distance: '1.2 km',
      verified: true,
      services: ['Switch repair', 'Fan installation', 'Wiring check'],
    ),
    Provider(
      id: 'p2',
      categoryId: 'electrician',
      name: 'Sharma Home Services',
      rating: 4.5,
      reviewsCount: 218,
      priceOnwards: 249,
      distance: '2.0 km',
      verified: true,
      services: ['MCB repair', 'Light fitting', 'Inverter setup'],
    ),
    Provider(
      id: 'p3',
      categoryId: 'electrician',
      name: 'LocalFix Riders',
      rating: 4.7,
      reviewsCount: 190,
      priceOnwards: 199,
      distance: '0.8 km',
      verified: true,
      services: ['Emergency visit', 'Appliance wiring'],
    ),
    // --- Plumbers ---
    Provider(
      id: 'p4',
      categoryId: 'plumber',
      name: 'Gupta Plumbing Works',
      rating: 4.6,
      reviewsCount: 275,
      priceOnwards: 249,
      distance: '1.5 km',
      verified: true,
      services: ['Tap repair', 'Pipe leakage', 'Bathroom fittings'],
    ),
    Provider(
      id: 'p5',
      categoryId: 'plumber',
      name: 'QuickFlow Services',
      rating: 4.3,
      reviewsCount: 142,
      priceOnwards: 199,
      distance: '2.4 km',
      verified: false,
      services: ['Drain cleaning', 'Tank cleaning'],
    ),
    // --- Carpenters ---
    Provider(
      id: 'p6',
      categoryId: 'carpenter',
      name: 'Verma Wood Works',
      rating: 4.7,
      reviewsCount: 166,
      priceOnwards: 349,
      distance: '1.9 km',
      verified: true,
      services: ['Furniture repair', 'Door hinges', 'Modular kitchen'],
    ),
    // --- Painters ---
    Provider(
      id: 'p7',
      categoryId: 'painter',
      name: 'RangSajja Painters',
      rating: 4.4,
      reviewsCount: 98,
      priceOnwards: 1499,
      distance: '3.1 km',
      verified: true,
      services: ['1BHK painting', 'Touch-ups', 'Waterproofing'],
    ),
    // --- AC Repair ---
    Provider(
      id: 'p8',
      categoryId: 'ac',
      name: 'CoolBreeze AC Care',
      rating: 4.8,
      reviewsCount: 410,
      priceOnwards: 499,
      distance: '1.1 km',
      verified: true,
      services: ['AC servicing', 'Gas refill', 'Installation'],
    ),
  ];

  static List<Provider> providersFor(String categoryId) =>
      providers.where((p) => p.categoryId == categoryId).toList();

  /// Next 3 days for the slot picker.
  static List<String> slotDates() {
    final now = DateTime.now();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return List.generate(3, (i) {
      final d = now.add(Duration(days: i));
      final prefix = i == 0 ? 'Today' : weekdays[d.weekday - 1];
      return '$prefix, ${d.day} ${months[d.month - 1]}';
    });
  }

  static const List<String> timeSlots = [
    '09:00 – 11:00',
    '11:00 – 01:00',
    '02:00 – 04:00',
    '04:00 – 06:00',
  ];
}
