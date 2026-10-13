/// Bottom-sheet voice interaction: listening UI, live transcript, spoken
/// answers and visual result cards.
///
/// Flow: [VoiceOverlay] already spoke the prompt. This sheet starts
/// listening immediately, runs the transcript through the honest rule
/// engine ([RuleBasedAssistant]) — or the screen-aware EXPLAIN intent —
/// speaks the answer via TTS, and shows tappable result cards.
///
/// Error states: mic engine missing, no speech detected (retry), answer
/// failure (retry). Cancelling stops both STT and TTS.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../screens/bookings_screen.dart';
import '../screens/provider_profile_screen.dart';
import '../screens/search_screen.dart';
import '../state/app_state.dart';

enum _Phase { listening, thinking, result, error }

class _CardData {
  final ProviderProfile provider;
  final int? priceFromPaise;
  const _CardData(this.provider, this.priceFromPaise);
}

class VoiceSheet extends StatefulWidget {
  final FlutterTts tts;

  const VoiceSheet({super.key, required this.tts});

  @override
  State<VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends State<VoiceSheet> {
  final SpeechToText _stt = SpeechToText();
  _Phase _phase = _Phase.listening;
  String _transcript = '';
  String _answer = '';
  String? _errorKey;
  List<_CardData> _cards = [];
  List<AssistantAction> _actions = [];
  bool _isDemo = false;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _stt.cancel();
    widget.tts.stop();
    super.dispose();
  }

  bool get _hindi =>
      context.read<AppState>().locale.languageCode == 'hi';

  Future<void> _speak(String text) async {
    try {
      await widget.tts.setLanguage(_hindi ? 'hi-IN' : 'en-IN');
      await widget.tts.setSpeechRate(0.5);
      await widget.tts.awaitSpeakCompletion(true);
      await widget.tts.speak(text);
    } catch (_) {
      // TTS missing: the visual answer below still works — stay honest
      // via the snackbar instead of crashing the flow.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(FxLocalizations.of(context).t('voiceTtsMissing'))));
      }
    }
  }

  Future<void> _startListening() async {
    final hindi = _hindi; // capture before any async gap
    setState(() {
      _phase = _Phase.listening;
      _transcript = '';
      _errorKey = null;
    });
    final ready = await _stt.initialize(
      onError: (_) {
        if (mounted) {
          setState(() {
            _phase = _Phase.error;
            _errorKey = 'aiError';
          });
        }
      },
    );
    if (!ready) {
      if (mounted) {
        setState(() {
          _phase = _Phase.error;
          _errorKey = 'aiError';
        });
      }
      return;
    }
    await _stt.listen(
      onResult: _onResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        localeId: hindi ? 'hi-IN' : 'en-IN',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
      ),
    );
    if (mounted) setState(() {});
  }

  void _onResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() => _transcript = result.recognizedWords);
    if (result.finalResult) {
      _process(result.recognizedWords);
    }
  }

  Future<void> _process(String transcript) async {
    await _stt.stop();
    if (!mounted) return;
    final t = FxLocalizations.of(context);
    final said = transcript.trim();
    if (said.isEmpty) {
      // Honest: nothing was heard — say so and offer a retry.
      await _speak(t.t('voiceNoSpeech'));
      if (!mounted) return;
      setState(() {
        _phase = _Phase.error;
        _errorKey = 'voiceNoSpeech';
      });
      return;
    }

    setState(() => _phase = _Phase.thinking);
    try {
      final app = context.read<AppState>();
      final hindi = app.locale.languageCode == 'hi';
      final String spoken;
      AssistantReply? reply;

      if (detectVoiceIntent(said) == VoiceIntent.explain) {
        spoken = VoiceScreenRegistry.describe(
                VoiceScreenTracker.currentKey, hindi) ??
            t.t('voiceExplainFallback');
      } else {
        final ctx = AssistantContext(
          catalog: app.repos.catalog,
          bookings: app.repos.bookings,
          customerId: app.user?.id,
          locale: app.locale.languageCode,
          isDemo: AppConfig.useDemoData,
        );
        reply = await app.assistant.ask(said, ctx);
        spoken = reply.text;
      }

      await _speak(spoken);

      // Visual cards for provider deep-links (real repo data only).
      final cards = <_CardData>[];
      final actions = <AssistantAction>[];
      if (reply != null) {
        for (final a in reply.actions) {
          if (a.kind == AssistantActionKind.openProvider &&
              a.providerId != null) {
            final p =
                await app.repos.catalog.provider(a.providerId!);
            if (p != null) {
              final services = await app.repos.catalog
                  .providerServices(p.id, activeOnly: true);
              final min = services.isEmpty
                  ? null
                  : services
                      .map((s) => s.pricePaise)
                      .reduce((x, y) => x < y ? x : y);
              cards.add(_CardData(p, min));
            }
          } else {
            actions.add(a);
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _phase = _Phase.result;
        _answer = spoken;
        _cards = cards;
        _actions = actions;
        _isDemo = reply?.fromDemoData ?? AppConfig.useDemoData;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.error;
        _errorKey = 'aiError';
      });
    }
  }

  Future<void> _cancel() async {
    await _stt.cancel();
    await widget.tts.stop();
    if (mounted) Navigator.of(context).pop();
  }

  void _openAction(AssistantAction a) {
    switch (a.kind) {
      case AssistantActionKind.openProvider:
        if (a.providerId == null) return;
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                ProviderProfileScreen(providerId: a.providerId!)));
      case AssistantActionKind.openBookings:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BookingsScreen()));
      case AssistantActionKind.openSearch:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    final app = context.watch<AppState>();
    final onlineReady = app.geminiConfirmed;
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.72,
        padding: const EdgeInsets.all(FxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy_outlined,
                    color: FxColors.primary),
                const SizedBox(width: FxSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.t('voiceTitle'),
                          style: FxText.subtitle),
                      Text(
                        onlineReady
                            ? t.t('aiModeOnline')
                            : t.t('aiModeOffline'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: FxColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: t.t('voiceDone'),
                  icon: const Icon(Icons.close),
                  onPressed: _cancel,
                ),
              ],
            ),
            const Divider(),
            Expanded(child: _body(t)),
            const SizedBox(height: FxSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: FxButton(
                    label: t.t('cancel'),
                    kind: FxButtonKind.outlined,
                    onPressed: _cancel,
                  ),
                ),
                if (_phase == _Phase.error) ...[
                  const SizedBox(width: FxSpacing.sm),
                  Expanded(
                    child: FxButton(
                      label: t.t('retry'),
                      onPressed: _startListening,
                    ),
                  ),
                ],
                if (_phase == _Phase.result) ...[
                  const SizedBox(width: FxSpacing.sm),
                  Expanded(
                    child: FxButton(
                      label: t.t('voiceDone'),
                      onPressed: _cancel,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(FxLocalizations t) {
    switch (_phase) {
      case _Phase.listening:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _PulseMic(),
            const SizedBox(height: FxSpacing.lg),
            Text(t.t('voiceListening'),
                style: FxText.subtitle),
            const SizedBox(height: FxSpacing.sm),
            if (_transcript.isNotEmpty)
              Text(
                '“$_transcript”',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: FxColors.secondaryText),
              ),
          ],
        );
      case _Phase.thinking:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: FxSpacing.md),
            if (_transcript.isNotEmpty)
              Text('“$_transcript”',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: FxColors.secondaryText)),
          ],
        );
      case _Phase.error:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: FxColors.error),
            const SizedBox(height: FxSpacing.md),
            Text(
              t.t(_errorKey ?? 'aiError'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: FxColors.navy),
            ),
          ],
        );
      case _Phase.result:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_transcript.isNotEmpty)
                Text(
                  '“$_transcript”',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: FxColors.secondaryText,
                  ),
                ),
              const SizedBox(height: FxSpacing.sm),
              Container(
                padding: const EdgeInsets.all(FxSpacing.md),
                decoration: BoxDecoration(
                  color: FxColors.white,
                  borderRadius:
                      BorderRadius.circular(FxRadius.lg),
                  border: Border.all(color: FxColors.borders),
                ),
                child: Text(_answer,
                    style:
                        const TextStyle(color: FxColors.navy)),
              ),
              if (_cards.isNotEmpty) ...[
                const SizedBox(height: FxSpacing.md),
                for (final c in _cards)
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: FxSpacing.sm),
                    child: ProviderCard(
                      provider: c.provider,
                      priceFromPaise: c.priceFromPaise,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => ProviderProfileScreen(
                                providerId: c.provider.id))),
                    ),
                  ),
              ],
              if (_actions.isNotEmpty) ...[
                const SizedBox(height: FxSpacing.sm),
                Wrap(
                  spacing: FxSpacing.sm,
                  runSpacing: FxSpacing.sm,
                  children: _actions
                      .map((a) => FxButton(
                            label: a.label,
                            kind: FxButtonKind.outlined,
                            icon: Icons.arrow_forward,
                            onPressed: () => _openAction(a),
                          ))
                      .toList(),
                ),
              ],
              if (_isDemo) ...[
                const SizedBox(height: FxSpacing.xs),
                Text(
                  t.t('aiDemoData'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: FxColors.secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
    }
  }
}

/// Pulsing microphone shown while listening.
class _PulseMic extends StatefulWidget {
  const _PulseMic();

  @override
  State<_PulseMic> createState() => _PulseMicState();
}

class _PulseMicState extends State<_PulseMic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.18).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 76,
        height: 76,
        decoration: const BoxDecoration(
          color: FxColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.mic,
            color: FxColors.white, size: 36),
      ),
    );
  }
}
