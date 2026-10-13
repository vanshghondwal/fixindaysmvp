/// FixinDays AI Assistant — service layer.
///
/// Pure Dart (no Flutter imports) so the rule engine is unit-testable.
///
/// Two modes:
/// * [RuleBasedAssistant] — works NOW, no API key. Answers ONLY from real
///   repository data. It NEVER invents prices, ratings, availability or
///   reviews. When data does not exist it says so honestly.
/// * [GeminiAssistant] — online mode. Calls the `askAssistant` Cloud
///   Function; the Gemini API key lives server-side (env), never in the
///   client. Until it is configured, the UI must show the honest
///   "online mode not set up" state and keep using the rule-based mode.
///   Never display "Powered by Gemini" while the rule engine is answering.
///
/// The assistant never performs booking or payment actions. Instead it
/// returns [AssistantAction] deep-links that navigate to the real screens.
library;

import 'logic.dart';
import 'models.dart';
import 'repositories.dart';

// ---------------------------------------------------------------------------
// Modes, replies, actions
// ---------------------------------------------------------------------------

/// Which engine produced a reply. The UI shows this honestly.
enum AssistantMode { ruleBased, gemini }

/// A deep-link rendered as a button under an assistant message.
/// Tapping navigates to a REAL screen — never a fake action.
enum AssistantActionKind { openProvider, openBookings, openSearch }

class AssistantAction {
  final AssistantActionKind kind;
  final String label;
  final String? providerId;
  final String? searchQuery;

  const AssistantAction({
    required this.kind,
    required this.label,
    this.providerId,
    this.searchQuery,
  });
}

class AssistantReply {
  /// Localised answer text (already in [AssistantContext.locale]).
  final String text;

  /// Deep-link buttons shown under the message.
  final List<AssistantAction> actions;

  /// True when the answer was built from demo seed data.
  /// The UI MUST show a "Demo data" label in this case.
  final bool fromDemoData;

  /// Engine that actually produced this reply.
  final AssistantMode mode;

  const AssistantReply({
    required this.text,
    this.actions = const [],
    required this.fromDemoData,
    required this.mode,
  });
}

/// Real data access handed to the assistant. Answers are computed from
/// these repositories — never hardcoded.
class AssistantContext {
  final CatalogRepository catalog;
  final BookingRepository bookings;
  final String? customerId;
  final String locale; // 'en' | 'hi'
  final bool isDemo;
  final PlatformSettings platformSettings;

  const AssistantContext({
    required this.catalog,
    required this.bookings,
    this.customerId,
    this.locale = 'en',
    this.isDemo = false,
    this.platformSettings = const PlatformSettings(),
  });

  bool get hindi => locale == 'hi';
}

abstract class AiAssistantService {
  AssistantMode get mode;
  bool get isConfigured;
  Future<AssistantReply> ask(String question, AssistantContext ctx);
}

// ---------------------------------------------------------------------------
// Localised strings (pure-Dart tables; UI strings live in l10n.dart)
// ---------------------------------------------------------------------------

class _S {
  static const _t = <String, Map<String, String>>{
    'greeting': {
      'en':
          'Namaste! Main FixinDays assistant hoon. Providers compare karna ho, price samajhna ho ya booking ka status — real data se jawab dunga. Kya poochna hai?',
      'hi':
          'नमस्ते! मैं FixinDays असिस्टेंट हूँ। प्रोवाइडर तुलना, कीमत की जानकारी या बुकिंग का स्टेटस — असली डेटा से जवाब दूँगा। क्या पूछना है?',
    },
    'capabilities': {
      'en':
          'Main ye kar sakta hoon:\n• Providers dhoondhna aur compare karna (asli price/rating ke saath)\n• Price kyun hai, ye samjhana\n• Tumhari booking ka status batana\n• Cancellation ka tareeka batana\n\nMain booking ya payment khud nahi karta — uske liye sahi screen ka button de dunga.',
      'hi':
          'मैं ये कर सकता हूँ:\n• प्रोवाइडर खोजना और तुलना करना (असली कीमत/रेटिंग के साथ)\n• कीमत क्यों है, ये समझाना\n• तुम्हारी बुकिंग का स्टेटस बताना\n• कैंसिल करने का तरीका बताना\n\nमैं बुकिंग या पेमेंट खुद नहीं करता — उसके लिए सही स्क्रीन का बटन दे दूँगा।',
    },
    'dontKnow': {
      'en':
          'Mere paas iski jaankari nahi hai — main andaza nahi lagata. Provider, price ya booking ke baare me poocho, main real data se jawab dunga.',
      'hi':
          'मेरे पास इसकी जानकारी नहीं है — मैं अंदाज़ा नहीं लगाता। प्रोवाइडर, कीमत या बुकिंग के बारे में पूछो, मैं असली डेटा से जवाब दूँगा।',
    },
    'signInNeeded': {
      'en':
          'Booking status dekhne ke liye pehle sign in karo. Sign in ke baad main tumhari asli bookings se status bata dunga.',
      'hi':
          'बुकिंग स्टेटस देखने के लिए पहले साइन इन करो। साइन इन के बाद मैं तुम्हारी असली बुकिंग से स्टेटस बता दूँगा।',
    },
    'noBookings': {
      'en': 'Tumhari koi active booking nahi hai abhi.',
      'hi': 'तुम्हारी कोई एक्टिव बुकिंग नहीं है अभी।',
    },
    'noProviders': {
      'en':
          'Is category me abhi koi provider nahi mila. Koi aur service try karo.',
      'hi':
          'इस श्रेणी में अभी कोई प्रोवाइडर नहीं मिला। कोई और सेवा आज़माओ।',
    },
    'noPriceInfo': {
      'en':
          'Iske price ki jaankari mere paas nahi hai — provider ne abhi price set nahi kiya hai.',
      'hi':
          'इसकी कीमत की जानकारी मेरे पास नहीं है — प्रोवाइडर ने अभी कीमत तय नहीं की है।',
    },
    'bookRefusal': {
      'en':
          'Main chat se booking nahi kar sakta — galti ka risk hota hai. Neeche diye button se sahi screen kholo, wahan sab verified steps honge.',
      'hi':
          'मैं चैट से बुकिंग नहीं कर सकता — गलती का जोखिम होता है। नीचे दिए बटन से सही स्क्रीन खोलो, वहाँ सब सत्यापित स्टेप्स होंगे।',
    },
    'viewProviders': {'en': 'Providers dekho', 'hi': 'प्रोवाइडर देखो'},
    'viewProvider': {'en': 'Profile dekho', 'hi': 'प्रोफ़ाइल देखो'},
    'openBookings': {'en': 'My Bookings kholo', 'hi': 'मेरी बुकिंग खोलो'},
    'cancelHow': {
      'en':
          'Cancel karne ke liye: My Bookings kholo → booking select karo → Cancel dabao aur reason likho.\n\nRefund tumhare payment status par depend karta hai — paid booking ka refund process hota hai, cash-on-service me koi advance nahi hota. Provider ke jawab dene ka samay ~{timeout} min hai.',
      'hi':
          'कैंसिल करने के लिए: मेरी बुकिंग खोलो → बुकिंग चुनो → रद्द करें दबाओ और कारण लिखो।\n\nरिफंड तुम्हारे पेमेंट स्टेटस पर निर्भर करता है — पेड बुकिंग का रिफंड प्रोसेस होता है, कैश-ऑन-सर्विस में कोई एडवांस नहीं होता। प्रोवाइडर के जवाब देने का समय ~{timeout} मिनट है।',
    },
  };

  static String get(String key, bool hindi) =>
      _t[key]?[hindi ? 'hi' : 'en'] ?? _t[key]?['en'] ?? key;
}

// ---------------------------------------------------------------------------
// Intent matching (English + Hindi + Hinglish keywords)
// ---------------------------------------------------------------------------

enum _Intent {
  greeting,
  capabilities,
  bookAction,
  cancelAction,
  bookingStatus,
  priceExplain,
  providerSearch,
  unknown,
}

class _Hit {
  final _Intent intent;
  final String? categoryId;
  const _Hit(this.intent, [this.categoryId]);
}

bool _word(String text, String word) => RegExp(
      '(?<![\\p{L}])${RegExp.escape(word)}(?![\\p{L}])',
      unicode: true,
    ).hasMatch(text);

bool _anyWord(String text, List<String> words) =>
    words.any((w) => _word(text, w));

const _categoryKeywords = <String, List<String>>{
  'electrical': [
    'electr', 'bijli', 'बिजली', 'wire', 'switch', 'fan', 'bulb',
    'wiring', 'socket'
  ],
  'plumbing': [
    'plumb', 'nal', 'नल', 'pipe', 'leak', 'tap', 'पानी', 'paani',
    'bathroom', 'toilet'
  ],
  'cleaning': [
    'clean', 'safai', 'सफाई', 'dust', 'mop', 'jhadu', 'झाड़ू', 'sweep'
  ],
  'painting': ['paint', 'पेंट', 'rang', 'रंग', 'whitewash', 'distemper'],
  'carpentry': [
    'carpent', 'बढ़ई', 'badhai', 'wood', 'furniture', 'लकड़ी', 'lakdi'
  ],
  'appliance': [
    'appliance', 'ac', 'fridge', 'फ्रिज', 'washing', 'geyser', 'गीजर',
    'microwave', 'repair'
  ],
};

String? _detectCategory(String q) {
  for (final e in _categoryKeywords.entries) {
    if (_anyWord(q, e.value)) return e.key;
  }
  return null;
}

_Hit _detectIntent(String raw) {
  final q = ' ${raw.toLowerCase().trim()} ';
  if (q.trim().isEmpty) return const _Hit(_Intent.unknown);

  // Greeting (short messages only, so "hi, sasta electrician" still searches).
  if (q.trim().length <= 12 &&
      _anyWord(q, ['hi', 'hello', 'hey', 'namaste', 'नमस्ते', 'yo'])) {
    return const _Hit(_Intent.greeting);
  }
  if (_anyWord(q, [
    'kya kar sakte', 'what can you do', 'madad', 'help', 'सहायता',
    'features', 'kaam kya'
  ])) {
    return const _Hit(_Intent.capabilities);
  }
  // Booking via chat is refused → deep link instead.
  if (_anyWord(q, [
    'book karo', 'book karna', 'booking karo', 'book kar do', 'बुक करो',
    'book my', 'i want to book', 'book karna hai'
  ])) {
    return _Hit(_Intent.bookAction, _detectCategory(q));
  }
  if (_anyWord(q, ['cancel', 'रद्द', 'radd'])) {
    return const _Hit(_Intent.cancelAction);
  }
  if (_anyWord(q, [
    'booking status', 'meri booking', 'my booking', 'status',
    'kab aayega', 'kab ayega', 'provider kahan', 'booking kahan'
  ])) {
    return const _Hit(_Intent.bookingStatus);
  }
  if (_anyWord(q, [
    'kyun hai', 'kyu hai', 'kyun', 'price', 'daam', 'दाम', 'kimat',
    'कीमत', 'charge', 'cost', 'lagat', 'महंगा', 'mehnga', 'mehngaai'
  ])) {
    return _Hit(_Intent.priceExplain, _detectCategory(q));
  }
  final cat = _detectCategory(q);
  if (cat != null ||
      _anyWord(q, [
        'sasta', 'saste', 'cheap', 'best', 'achha', 'अच्छा', 'compare',
        'tulna', 'provider', 'प्रोवाइडर', 'mistri', 'मिस्त्री', 'dikhao',
        'dikha', 'batao', 'list'
      ])) {
    return _Hit(_Intent.providerSearch, cat);
  }
  return const _Hit(_Intent.unknown);
}

// ---------------------------------------------------------------------------
// Rule-based assistant — answers ONLY from real repository data
// ---------------------------------------------------------------------------

class RuleBasedAssistant implements AiAssistantService {
  const RuleBasedAssistant();

  @override
  AssistantMode get mode => AssistantMode.ruleBased;

  @override
  bool get isConfigured => true;

  @override
  Future<AssistantReply> ask(String question, AssistantContext ctx) async {
    final h = ctx.hindi;
    final hit = _detectIntent(question);
    try {
      switch (hit.intent) {
        case _Intent.greeting:
          return _reply(_S.get('greeting', h), ctx);
        case _Intent.capabilities:
          return _reply(_S.get('capabilities', h), ctx);
        case _Intent.bookAction:
          return _reply(
            _S.get('bookRefusal', h),
            ctx,
            actions: [
              AssistantAction(
                kind: AssistantActionKind.openSearch,
                label: _S.get('viewProviders', h),
              ),
            ],
          );
        case _Intent.cancelAction:
          return _reply(
            _S.get('cancelHow', h).replaceAll('{timeout}',
                '${ctx.platformSettings.providerResponseTimeoutMin}'),
            ctx,
            actions: [
              AssistantAction(
                kind: AssistantActionKind.openBookings,
                label: _S.get('openBookings', h),
              ),
            ],
          );
        case _Intent.bookingStatus:
          return await _bookingStatus(ctx);
        case _Intent.priceExplain:
          return await _priceExplain(ctx, hit.categoryId, question);
        case _Intent.providerSearch:
          return await _providerSearch(ctx, hit.categoryId, question);
        case _Intent.unknown:
          return _reply(_S.get('dontKnow', h), ctx);
      }
    } catch (_) {
      // Repository failures must never produce invented content.
      return _reply(_S.get('dontKnow', h), ctx);
    }
  }

  AssistantReply _reply(String text, AssistantContext ctx,
          {List<AssistantAction> actions = const []}) =>
      AssistantReply(
        text: text,
        actions: actions,
        fromDemoData: ctx.isDemo,
        mode: AssistantMode.ruleBased,
      );

  String _price(int paise) => formatInr(paise);

  String _ratingLine(ProviderProfile p, bool hindi) {
    if (p.ratingCount <= 0) {
      return hindi ? 'अभी कोई रिव्यू नहीं' : 'no reviews yet';
    }
    return '${p.ratingAvg.toStringAsFixed(1)}★ (${p.ratingCount})';
  }

  Future<AssistantReply> _providerSearch(
      AssistantContext ctx, String? categoryId, String question) async {
    final h = ctx.hindi;
    final q = question.toLowerCase();
    final cheapestFirst =
        _anyWord(' $q ', ['sasta', 'saste', 'cheap', 'सस्ता']);
    // NOTE: price sorting is done here from real service data, because the
    // repository `priceAsc` contract is not implemented by every backend.
    // Never claim "cheapest" without actually sorting by price.
    final providers = await ctx.catalog.searchProviders(
      categoryId: categoryId,
      query: categoryId == null ? question.trim() : null,
      sortBy: 'rating',
      limit: cheapestFirst ? 10 : 3,
      offset: 0,
    );
    if (providers.isEmpty) return _reply(_S.get('noProviders', h), ctx);

    final priced = await Future.wait(providers.map((p) async {
      final services =
          await ctx.catalog.providerServices(p.id, activeOnly: true);
      final priceFrom = services.isEmpty
          ? null
          : services
              .map((s) => s.pricePaise)
              .reduce((a, b) => a < b ? a : b);
      return (provider: p, priceFrom: priceFrom);
    }));
    if (cheapestFirst) {
      priced.sort((a, b) => (a.priceFrom ?? 1 << 60)
          .compareTo(b.priceFrom ?? 1 << 60));
    }
    final top = priced.take(3).toList();

    final buf = StringBuffer();
    buf.writeln(h
        ? (cheapestFirst
            ? 'Sabse saste providers (asli price ke saath):'
            : 'Top rated providers (asli rating ke saath):')
        : (cheapestFirst
            ? 'Cheapest providers (real prices):'
            : 'Top-rated providers (real ratings):'));
    final actions = <AssistantAction>[];
    for (var i = 0; i < top.length; i++) {
      final p = top[i].provider;
      final priceFrom = top[i].priceFrom;
      final verified =
          p.isVerified ? (h ? ', सत्यापित ✓' : ', verified ✓') : '';
      final price = priceFrom == null
          ? (h ? 'कीमत उपलब्ध नहीं' : 'price not listed')
          : '${_price(priceFrom)} ${h ? 'से शुरू' : 'onwards'}';
      buf.writeln(
          '${i + 1}. ${p.businessName} — $price, ${_ratingLine(p, h)}$verified');
      if (i == 0) {
        actions.add(AssistantAction(
          kind: AssistantActionKind.openProvider,
          label: '${_S.get('viewProvider', h)}: ${p.businessName}',
          providerId: p.id,
        ));
      }
    }
    return _reply(buf.toString().trimRight(), ctx, actions: actions);
  }

  Future<AssistantReply> _priceExplain(
      AssistantContext ctx, String? categoryId, String question) async {
    final h = ctx.hindi;
    final providers = await ctx.catalog.searchProviders(
      categoryId: categoryId,
      query: categoryId == null ? question.trim() : null,
      sortBy: 'rating',
      limit: 3,
      offset: 0,
    );
    if (providers.isEmpty) return _reply(_S.get('noPriceInfo', h), ctx);

    final buf = StringBuffer();
    buf.writeln(h
        ? 'Ye rahi asli price jaankari (provider ne khud set ki hai):'
        : 'Here is the real pricing info (set by the provider):');
    var found = false;
    for (final p in providers) {
      final services =
          await ctx.catalog.providerServices(p.id, activeOnly: true);
      for (final s in services.take(2)) {
        found = true;
        final basis = switch (s.priceBasis) {
          PriceBasis.fixed => h ? 'fixed price' : 'fixed price',
          PriceBasis.estimate => h ? 'anumaanit price' : 'estimated price',
          PriceBasis.quote => h ? 'quote par nirbhar' : 'on quotation',
        };
        buf.writeln(
            '• ${p.businessName}: ${s.name} — ${_price(s.pricePaise)} ($basis, per ${s.unit})');
      }
    }
    if (!found) return _reply(_S.get('noPriceInfo', h), ctx);
    return _reply(
      buf.toString().trimRight(),
      ctx,
      actions: [
        AssistantAction(
          kind: AssistantActionKind.openProvider,
          label:
              '${_S.get('viewProvider', h)}: ${providers.first.businessName}',
          providerId: providers.first.id,
        ),
      ],
    );
  }

  Future<AssistantReply> _bookingStatus(AssistantContext ctx) async {
    final h = ctx.hindi;
    final id = ctx.customerId;
    if (id == null || id.isEmpty) {
      return _reply(_S.get('signInNeeded', h), ctx);
    }
    final all = await ctx.bookings.myBookings(id);
    final active = all.where((b) => b.isActive).toList();
    if (active.isEmpty) return _reply(_S.get('noBookings', h), ctx);

    final buf = StringBuffer();
    buf.writeln(h ? 'Tumhari active bookings:' : 'Your active bookings:');
    for (final b in active.take(3)) {
      buf.writeln(
          '• ${b.providerName} — ${_statusWord(b.status, h)} (${_fmtDate(b.scheduledAt)})');
    }
    return _reply(
      buf.toString().trimRight(),
      ctx,
      actions: [
        AssistantAction(
          kind: AssistantActionKind.openBookings,
          label: _S.get('openBookings', h),
        ),
      ],
    );
  }

  String _statusWord(BookingStatus s, bool hindi) {
    const en = {
      BookingStatus.pending: 'pending — provider ke jawab ka intezaar',
      BookingStatus.accepted: 'accepted by provider',
      BookingStatus.rejected: 'rejected by provider',
      BookingStatus.confirmed: 'confirmed & scheduled',
      BookingStatus.enRoute: 'provider on the way',
      BookingStatus.arrived: 'provider arrived',
      BookingStatus.inProgress: 'service in progress',
      BookingStatus.completed: 'completed',
      BookingStatus.cancelled: 'cancelled',
      BookingStatus.disputed: 'under dispute review',
    };
    const hi = {
      BookingStatus.pending: 'पेंडिंग — प्रोवाइडर के जवाब का इंतज़ार',
      BookingStatus.accepted: 'प्रोवाइडर ने स्वीकार किया',
      BookingStatus.rejected: 'प्रोवाइडर ने मना किया',
      BookingStatus.confirmed: 'कन्फर्म और शेड्यूल्ड',
      BookingStatus.enRoute: 'प्रोवाइडर रास्ते में है',
      BookingStatus.arrived: 'प्रोवाइडर पहुँच गया',
      BookingStatus.inProgress: 'सेवा चल रही है',
      BookingStatus.completed: 'पूर्ण',
      BookingStatus.cancelled: 'रद्द',
      BookingStatus.disputed: 'विवाद समीक्षा में',
    };
    return (hindi ? hi : en)[s] ?? s.name;
  }

  String _fmtDate(DateTime d) {
    final l = d.toLocal();
    return '${l.day}/${l.month} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Gemini online mode — server key only, never in the client
// ---------------------------------------------------------------------------

/// Online assistant. The [remoteCall] invokes the `askAssistant` Cloud
/// Function, which holds the Gemini API key server-side.
///
/// When [remoteCall] is null (not configured), [ask] honestly delegates to
/// the rule-based engine and the reply carries [AssistantMode.ruleBased],
/// so the UI never shows "Powered by Gemini" for rule-based answers.
class GeminiAssistant implements AiAssistantService {
  final Future<AssistantReply> Function(String question, AssistantContext ctx)?
      remoteCall;
  final AiAssistantService _fallback;

  GeminiAssistant({this.remoteCall, AiAssistantService? fallback})
      : _fallback = fallback ?? const RuleBasedAssistant();

  @override
  AssistantMode get mode => AssistantMode.gemini;

  @override
  bool get isConfigured => remoteCall != null;

  @override
  Future<AssistantReply> ask(String question, AssistantContext ctx) {
    final rc = remoteCall;
    if (rc == null) return _fallback.ask(question, ctx);
    return rc(question, ctx);
  }
}
