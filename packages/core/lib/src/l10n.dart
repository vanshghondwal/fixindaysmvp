/// Lightweight localization for FixinDays (English + Hindi).
///
/// Uses Flutter's [LocalizationsDelegate] system without code generation,
/// so CI builds never depend on gen-l10n output.
library;

import 'package:flutter/material.dart';

const _en = <String, String>{
  'appName': 'FixinDays',
  'tagline': 'Same Services. Brighter Days.',
  'searchServices': 'Search services...',
  'book': 'Book',
  'cancel': 'Cancel',
  'confirm': 'Confirm',
  'retry': 'Retry',
  'save': 'Save',
  'home': 'Home',
  'bookings': 'Bookings',
  'profile': 'Profile',
  'myBookings': 'My Bookings',
  'verified': 'Verified',
  'unverified': 'Unverified',
  'onwards': 'onwards',
  'demoBanner': 'Demo mode — sample data shown. Connect Firebase for live data.',
  'noResults': 'No results found',
  'tryDifferentSearch': 'Try a different search or category.',
  'selectSlot': 'Select date & time',
  'address': 'Address',
  'addAddress': 'Add address',
  'confirmBooking': 'Confirm Booking',
  'bookingConfirmed': 'Booking confirmed!',
  'total': 'Total',
  'subtotal': 'Subtotal',
  'platformFee': 'Platform fee',
  'upcoming': 'Upcoming',
  'completed': 'Completed',
  'cancelled': 'Cancelled',
  'notifications': 'Notifications',
  'settings': 'Settings',
  'helpSupport': 'Help & Support',
  'signOut': 'Sign out',
  'language': 'Language',
  'reviews': 'Reviews',
  'writeReview': 'Write a review',
  'submit': 'Submit',
  'accept': 'Accept',
  'reject': 'Reject',
  'dashboard': 'Dashboard',
  'services': 'Services',
  'earnings': 'Earnings',
  'requests': 'Requests',
};

const _hi = <String, String>{
  'appName': 'फिक्सिनडेज़',
  'tagline': 'वही सेवाएँ। बेहतर दिन।',
  'searchServices': 'सेवाएँ खोजें...',
  'book': 'बुक करें',
  'cancel': 'रद्द करें',
  'confirm': 'पुष्टि करें',
  'retry': 'पुनः प्रयास',
  'save': 'सहेजें',
  'home': 'होम',
  'bookings': 'बुकिंग',
  'profile': 'प्रोफ़ाइल',
  'myBookings': 'मेरी बुकिंग',
  'verified': 'सत्यापित',
  'unverified': 'असत्यापित',
  'onwards': 'से शुरू',
  'demoBanner':
      'डेमो मोड — नमूना डेटा दिखाया जा रहा है। लाइव डेटा के लिए Firebase जोड़ें।',
  'noResults': 'कोई परिणाम नहीं मिला',
  'tryDifferentSearch': 'कोई और खोज या श्रेणी आज़माएँ।',
  'selectSlot': 'तारीख़ और समय चुनें',
  'address': 'पता',
  'addAddress': 'पता जोड़ें',
  'confirmBooking': 'बुकिंग पुष्टि करें',
  'bookingConfirmed': 'बुकिंग पक्की हो गई!',
  'total': 'कुल',
  'subtotal': 'उप-योग',
  'platformFee': 'प्लेटफ़ॉर्म शुल्क',
  'upcoming': 'आगामी',
  'completed': 'पूर्ण',
  'cancelled': 'रद्द',
  'notifications': 'सूचनाएँ',
  'settings': 'सेटिंग्स',
  'helpSupport': 'सहायता',
  'signOut': 'साइन आउट',
  'language': 'भाषा',
  'reviews': 'समीक्षाएँ',
  'writeReview': 'समीक्षा लिखें',
  'submit': 'जमा करें',
  'accept': 'स्वीकार करें',
  'reject': 'अस्वीकार करें',
  'dashboard': 'डैशबोर्ड',
  'services': 'सेवाएँ',
  'earnings': 'कमाई',
  'requests': 'अनुरोध',
};

class FxLocalizations {
  final Locale locale;
  const FxLocalizations(this.locale);

  static FxLocalizations of(BuildContext context) =>
      Localizations.of<FxLocalizations>(context, FxLocalizations) ??
      const FxLocalizations(Locale('en'));

  String t(String key) {
    final table = locale.languageCode == 'hi' ? _hi : _en;
    return table[key] ?? _en[key] ?? key;
  }

  static const LocalizationsDelegate<FxLocalizations> delegate =
      _FxLocalizationsDelegate();
}

class _FxLocalizationsDelegate
    extends LocalizationsDelegate<FxLocalizations> {
  const _FxLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<FxLocalizations> load(Locale locale) async =>
      FxLocalizations(locale);

  @override
  bool shouldReload(_FxLocalizationsDelegate old) => false;
}
