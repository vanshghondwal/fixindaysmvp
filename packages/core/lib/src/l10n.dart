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
  'payment': 'Payment',
  'phoneSignIn': 'Phone sign-in',
  'emailSignIn': 'Email sign-in',
  'resetPassword': 'Reset password',
  'cashOnService': 'Cash on service',
  'priceOnRequest': 'Price on request',
  'yourCart': 'Your cart',
  'bookingDetails': 'Booking details',
  'providers': 'Providers',
  'allCategories': 'All categories',
  'provider': 'Provider',
  'reportIssue': 'Report an issue',
  'editProfile': 'Edit profile',
  'setupProfile': 'Set up your profile',
  'yourLocation': 'Your location',
  'aiAssistant': 'AI Assistant',
  'aiModeOffline': 'Smart offline mode',
  'aiModeOnline': 'Gemini online',
  'aiOfflineNote':
      'AI online mode is not set up yet — smart offline mode is answering from your real data.',
  'aiDemoData': 'Demo data',
  'aiError': 'Something went wrong. Please try again.',
  'voiceTitle': 'Voice Assistant',
  'voicePrompt': 'How can I help you on this page?',
  'voiceListening': 'Listening... speak now',
  'voiceTapMic': 'Tap the mic and speak',
  'voiceNoSpeech':
      'Maaf kijiye, kuch sunai nahi diya — phir se boliye.',
  'voiceMicTitle': 'Microphone needed',
  'voiceMicBody':
      'FixinDays needs microphone access so it can hear your question. You can change this anytime in settings.',
  'voiceOpenSettings': 'Open settings',
  'voiceTtsMissing': 'Voice output is not available on this device.',
  'voiceDone': 'Done',
  'voiceExplainFallback':
      'Is screen ke baare me abhi jaankari nahi hai — koi aur sawaal poochho.',
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
  'payment': 'भुगतान',
  'phoneSignIn': 'फ़ोन से साइन-इन',
  'emailSignIn': 'ईमेल से साइन-इन',
  'resetPassword': 'पासवर्ड रीसेट',
  'cashOnService': 'सेवा पर नकद भुगतान',
  'priceOnRequest': 'कीमत अनुरोध पर',
  'yourCart': 'आपकी कार्ट',
  'bookingDetails': 'बुकिंग विवरण',
  'providers': 'सेवा प्रदाता',
  'allCategories': 'सभी श्रेणियाँ',
  'provider': 'प्रदाता',
  'reportIssue': 'समस्या रिपोर्ट करें',
  'editProfile': 'प्रोफ़ाइल संपादित करें',
  'setupProfile': 'अपनी प्रोफ़ाइल सेट करें',
  'yourLocation': 'आपका स्थान',
  'aiAssistant': 'AI सहायक',
  'aiModeOffline': 'स्मार्ट ऑफ़लाइन मोड',
  'aiModeOnline': 'Gemini ऑनलाइन',
  'aiOfflineNote':
      'AI ऑनलाइन मोड अभी सेटअप नहीं है — स्मार्ट ऑफ़लाइन मोड तुम्हारे असली डेटा से जवाब दे रहा है।',
  'aiDemoData': 'डेमो डेटा',
  'aiError': 'कुछ गड़बड़ हो गई। दोबारा कोशिश करो।',
  'voiceTitle': 'वॉइस असिस्टेंट',
  'voicePrompt': 'Aapko is page par kis tarah ki madad chahiye?',
  'voiceListening': 'सुन रहे हैं... बोलिए',
  'voiceTapMic': 'माइक दबाकर बोलिए',
  'voiceNoSpeech':
      'माफ़ कीजिए, कुछ सुनाई नहीं दिया — फिर से बोलिए।',
  'voiceMicTitle': 'माइक्रोफ़ोन चाहिए',
  'voiceMicBody':
      'तुम्हारा सवाल सुनने के लिए FixinDays को माइक्रोफ़ोन की अनुमति चाहिए। इसे कभी भी सेटिंग्स में बदल सकते हो।',
  'voiceOpenSettings': 'सेटिंग्स खोलें',
  'voiceTtsMissing': 'इस डिवाइस पर आवाज़ (TTS) उपलब्ध नहीं है।',
  'voiceDone': 'हो गया',
  'voiceExplainFallback':
      'इस स्क्रीन के बारे में अभी जानकारी नहीं है — कोई और सवाल पूछो।',
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
