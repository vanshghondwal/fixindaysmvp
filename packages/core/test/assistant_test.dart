import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter_test/flutter_test.dart';

AssistantContext _ctx({String? customerId, String locale = 'en'}) {
  final repos = DemoRepositories();
  return AssistantContext(
    catalog: repos.catalog,
    bookings: repos.bookings,
    customerId: customerId,
    locale: locale,
    isDemo: true,
  );
}

void main() {
  group('RuleBasedAssistant', () {
    const assistant = RuleBasedAssistant();

    test('greets the user', () async {
      final r = await assistant.ask('namaste', _ctx());
      expect(r.text, contains('Namaste'));
      expect(r.mode, AssistantMode.ruleBased);
      expect(r.fromDemoData, isTrue);
    });

    test('finds cheapest electricians from real repo data', () async {
      final r =
          await assistant.ask('sasta electrician dikhao', _ctx());
      // LocalFix Riders has the cheapest demo service (₹199).
      expect(r.text, contains('LocalFix Riders'));
      expect(r.text, contains('₹199'));
      expect(r.actions, hasLength(1));
      expect(r.actions.first.kind, AssistantActionKind.openProvider);
      expect(r.actions.first.providerId, 'demo-p3');
    });

    test('explains prices from real service data', () async {
      final r = await assistant.ask(
          'bijli ka kaam itna mehnga kyun hai', _ctx());
      expect(r.text, contains('Rajesh Electricals'));
      expect(r.text, contains('₹299'));
    });

    test('admits ignorance honestly instead of inventing', () async {
      final r =
          await assistant.ask('tum khana khate ho?', _ctx());
      expect(r.text, contains('jaankari nahi hai'));
      expect(r.actions, isEmpty);
    });

    test('booking status needs a signed-in customer', () async {
      final r = await assistant.ask(
          'meri booking ka status batao', _ctx(customerId: null));
      expect(r.text, contains('sign in'));
    });

    test('refuses to book via chat and deep-links instead', () async {
      final r =
          await assistant.ask('ek electrician book karo', _ctx());
      expect(r.actions.first.kind, AssistantActionKind.openSearch);
    });

    test('Hindi locale answers in Hindi', () async {
      final r = await assistant.ask('namaste', _ctx(locale: 'hi'));
      expect(r.text, contains('नमस्ते'));
    });
  });

  group('GeminiAssistant', () {
    test('is not configured without a remote call', () {
      final g = GeminiAssistant();
      expect(g.isConfigured, isFalse);
      expect(g.mode, AssistantMode.gemini);
    });

    test('delegates honestly to rule-based mode when unconfigured',
        () async {
      final g = GeminiAssistant();
      final r = await g.ask('namaste', _ctx());
      // The reply must NOT claim to be Gemini-powered.
      expect(r.mode, AssistantMode.ruleBased);
      expect(r.text, contains('Namaste'));
    });
  });

  group('voice NLU', () {
    test('detects EXPLAIN intent', () {
      expect(detectVoiceIntent('yeh screen samjhao'),
          VoiceIntent.explain);
      expect(detectVoiceIntent('what is this'), VoiceIntent.explain);
    });

    test('does not hijack provider search as EXPLAIN', () {
      // "batao" is generic — provider search must win.
      expect(detectVoiceIntent('sasta electrician dikhao'),
          VoiceIntent.delegate);
      expect(detectVoiceIntent('meri booking ka status'),
          VoiceIntent.delegate);
    });

    test('screen registry describes known screens', () {
      expect(VoiceScreenRegistry.describe('home', false),
          contains('home screen'));
      expect(VoiceScreenRegistry.describe('home', true),
          contains('होम'));
      expect(VoiceScreenRegistry.describe('nope', false), isNull);
    });

    test('tracker stack is push/pop correct', () {
      VoiceScreenTracker.setBase('home');
      expect(VoiceScreenTracker.currentKey, 'home');
      VoiceScreenTracker.push('search');
      expect(VoiceScreenTracker.currentKey, 'search');
      VoiceScreenTracker.pop('search');
      expect(VoiceScreenTracker.currentKey, 'home');
      VoiceScreenTracker.setBase('generic');
    });
  });
}
