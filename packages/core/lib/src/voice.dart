/// Voice assistant support for FixinDays.
///
/// * [VoiceScreenRegistry] — short spoken descriptions per screen (hi+en),
///   used by the EXPLAIN intent ("samjhao / explain / yeh kya hai").
/// * [VoiceScreenTracker] — stack-based tracking of the currently visible
///   screen, driven by [VoiceScreenTag]. Rebuilds never corrupt it because
///   only initState/dispose touch the stack.
/// * [VoiceIntent] / [detectVoiceIntent] — rule-based NLU for voice
///   transcripts. Anything not EXPLAIN is delegated to
///   [AiAssistantService] (the same honest rule engine as text).
library;

import 'package:flutter/material.dart';

import 'assistant.dart';

// ---------------------------------------------------------------------------
// Screen registry — spoken descriptions (hi + en)
// ---------------------------------------------------------------------------

class _Desc {
  final String en;
  final String hi;
  const _Desc(this.en, this.hi);
}

class VoiceScreenRegistry {
  static const _screens = <String, _Desc>{
    'home': _Desc(
      'This is the home screen. Search for services, browse categories like plumbing and electrical, and see top rated providers near you. Tap the mic anytime to ask me.',
      'यह होम स्क्रीन है। सेवाएँ खोजें, प्लंबिंग और बिजली जैसी श्रेणियाँ देखें, और अपने पास के टॉप रेटेड प्रोवाइडर देखें। कभी भी माइक दबाकर मुझसे पूछें।',
    ),
    'search': _Desc(
      'This is search. Type a service or provider name to find matching providers with real prices and ratings.',
      'यह खोज स्क्रीन है। असली कीमत और रेटिंग के साथ प्रोवाइडर खोजने के लिए सेवा या प्रोवाइडर का नाम लिखें।',
    ),
    'categories': _Desc(
      'Here are all service categories — plumbing, electrical, cleaning, painting and more. Pick one to see its providers.',
      'यहाँ सभी सेवा श्रेणियाँ हैं — प्लंबिंग, बिजली, सफ़ाई, पेंटिंग और बहुत कुछ। प्रोवाइडर देखने के लिए कोई एक चुनें।',
    ),
    'category': _Desc(
      'This shows providers for one category. You can sort by price or rating, and tap a provider to see details.',
      'यह एक श्रेणी के प्रोवाइडर दिखाता है। कीमत या रेटिंग के हिसाब से क्रमबद्ध करें, और विवरण के लिए किसी प्रोवाइडर पर टैप करें।',
    ),
    'providers': _Desc(
      'This is the provider list with real prices and ratings. Use the filters to narrow down, then tap a provider to book.',
      'यह असली कीमत और रेटिंग के साथ प्रोवाइडर सूची है। फ़िल्टर से चुनाव करें, फिर बुक करने के लिए किसी प्रोवाइडर पर टैप करें।',
    ),
    'provider': _Desc(
      'This is a provider profile — services with real prices, ratings, reviews and verification status. Tap Book to start a booking.',
      'यह प्रोवाइडर प्रोफ़ाइल है — असली कीमतों वाली सेवाएँ, रेटिंग, समीक्षाएँ और सत्यापन स्थिति। बुकिंग शुरू करने के लिए बुक दबाएँ।',
    ),
    'cart': _Desc(
      'This is your cart. Review the selected services and quantities, then continue to pick an address and time slot.',
      'यह आपकी कार्ट है। चुनी हुई सेवाएँ और मात्रा देख लें, फिर पता और समय चुनने के लिए आगे बढ़ें।',
    ),
    'schedule': _Desc(
      'Pick a date and time slot for your service. Only the provider\'s real available slots are shown.',
      'अपनी सेवा के लिए तारीख़ और समय चुनें। सिर्फ़ प्रोवाइडर के असली उपलब्ध स्लॉट दिखाए जाते हैं।',
    ),
    'review': _Desc(
      'Review your booking — provider, address, services and total — before confirming. Nothing is charged until you confirm.',
      'पुष्टि से पहले अपनी बुकिंग देख लें — प्रोवाइडर, पता, सेवाएँ और कुल राशि। पुष्टि से पहले कोई शुल्क नहीं लगता।',
    ),
    'bookings': _Desc(
      'These are your bookings — upcoming, completed and cancelled. Tap any booking for details, cancellation or rescheduling.',
      'ये तुम्हारी बुकिंग हैं — आगामी, पूर्ण और रद्द। विवरण, कैंसिल या रीशेड्यूल के लिए किसी बुकिंग पर टैप करो।',
    ),
    'profile': _Desc(
      'This is your profile — personal details, saved addresses, language and account settings.',
      'यह तुम्हारी प्रोफ़ाइल है — व्यक्तिगत विवरण, सहेजे गए पते, भाषा और खाता सेटिंग्स।',
    ),
    'booking': _Desc(
      'This is a booking detail screen — services, price breakdown, schedule and the live status of your booking.',
      'यह बुकिंग विवरण स्क्रीन है — सेवाएँ, कीमत का ब्यौरा, समय और तुम्हारी बुकिंग का लाइव स्टेटस।',
    ),
    'notifications': _Desc(
      'These are your notifications — booking updates, reminders and support replies.',
      'ये तुम्हारी सूचनाएँ हैं — बुकिंग अपडेट, रिमाइंडर और सहायता के जवाब।',
    ),
    'help': _Desc(
      'This is help and support — FAQs, contact options and a way to report issues with your bookings.',
      'यह सहायता स्क्रीन है — सामान्य प्रश्न, संपर्क विकल्प और बुकिंग की समस्या रिपोर्ट करने का तरीका।',
    ),
  };

  /// Spoken description for [key] in the user's language.
  /// Returns null when the screen is not registered — callers must then
  /// answer honestly instead of guessing.
  static String? describe(String key, bool hindi) {
    final d = _screens[key];
    if (d == null) return null;
    return hindi ? d.hi : d.en;
  }
}

// ---------------------------------------------------------------------------
// Screen tracking — stack based, immune to rebuilds
// ---------------------------------------------------------------------------

/// Tracks the currently visible screen for the EXPLAIN intent.
///
/// Screens wrap their scaffold in [VoiceScreenTag]; initState pushes the
/// key, dispose pops it. Plain rebuilds never touch the stack, so a
/// background tab rebuilding cannot clobber the visible screen.
/// Tab shells (IndexedStack) call [setBase] when the tab changes.
class VoiceScreenTracker {
  static final List<String> _stack = [];

  static void push(String key) => _stack.add(key);

  static void pop(String key) {
    // Remove the nearest matching entry from the top.
    for (var i = _stack.length - 1; i >= 0; i--) {
      if (_stack[i] == key) {
        _stack.removeAt(i);
        return;
      }
    }
  }

  /// For tab shells: the visible tab becomes the single base entry.
  static void setBase(String key) {
    _stack
      ..clear()
      ..add(key);
  }

  static String get currentKey =>
      _stack.isEmpty ? 'generic' : _stack.last;

  // Visible for tests.
  static List<String> get debugStack => List.unmodifiable(_stack);
}

/// Wrap a screen's scaffold so the voice assistant knows what is visible.
///
/// ```dart
/// return VoiceScreenTag(
///   screenKey: 'home',
///   child: Scaffold(...),
/// );
/// ```
class VoiceScreenTag extends StatefulWidget {
  final String screenKey;
  final Widget child;

  const VoiceScreenTag({
    super.key,
    required this.screenKey,
    required this.child,
  });

  @override
  State<VoiceScreenTag> createState() => _VoiceScreenTagState();
}

class _VoiceScreenTagState extends State<VoiceScreenTag> {
  @override
  void initState() {
    super.initState();
    VoiceScreenTracker.push(widget.screenKey);
  }

  @override
  void dispose() {
    VoiceScreenTracker.pop(widget.screenKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ---------------------------------------------------------------------------
// Voice NLU — EXPLAIN is screen-aware; everything else delegates to the
// honest rule engine ([RuleBasedAssistant]) over real repository data.
// ---------------------------------------------------------------------------

enum VoiceIntent { explain, delegate }

/// Explicit "explain this screen" phrasing (Hindi + English + Hinglish).
/// Kept narrow on purpose: "sasta electrician batao" must NOT match here —
/// it belongs to the provider-search intent in [RuleBasedAssistant].
bool _isExplain(String q) {
  const words = [
    'samjhao',
    'samjha',
    'samjhaiye',
    'samjhaye',
    'explain',
    'yeh kya hai',
    'ye kya hai',
    'yeh kya',
    'what is this',
    "what's this",
    'whats this',
    'is screen',
    'is page',
    'yeh screen',
    'ye screen',
  ];
  final padded = ' $q ';
  return words.any(padded.contains);
}

VoiceIntent detectVoiceIntent(String transcript) {
  final q = transcript.toLowerCase().trim();
  if (q.isEmpty) return VoiceIntent.delegate;
  if (_isExplain(q)) return VoiceIntent.explain;
  return VoiceIntent.delegate;
}
