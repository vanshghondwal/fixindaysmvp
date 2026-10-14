/// Persistent voice-assistant entry point for the customer app.
///
/// [VoiceOverlay] wraps the whole app (via MaterialApp.builder) so the mic
/// button is reachable from EVERY screen. Tapping it:
///   1. ensures microphone permission (honest rationale dialog, graceful
///      "mic unavailable" state with a link to system settings),
///   2. speaks a short prompt via TTS in the user's language,
///   3. opens [VoiceSheet] which listens, understands and answers.
///
/// TTS/STT need a real device (mic + speech engine) — the emulator and CI
/// cannot verify the voice path; the rule engine underneath is unit-tested.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'voice_sheet.dart';

/// Wraps the app so the mic button floats above every screen, just above
/// the bottom navigation bar.
class VoiceOverlay extends StatefulWidget {
  final Widget child;

  const VoiceOverlay({super.key, required this.child});

  @override
  State<VoiceOverlay> createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends State<VoiceOverlay> {
  late final FlutterTts _tts;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  /// Returns true when the mic may be used. Shows an honest rationale
  /// dialog when denied, and a settings shortcut when permanently denied.
  Future<bool> _ensureMic() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    if (status.isGranted) return true;
    if (!mounted) return false;

    final t = FxLocalizations.of(context);
    final permanentlyDenied = status.isPermanentlyDenied;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('voiceMicTitle')),
        content: Text(t.t('voiceMicBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.t('cancel')),
          ),
          FxButton(
            label: permanentlyDenied
                ? t.t('voiceOpenSettings')
                : t.t('retry'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (proceed != true) return false;
    if (permanentlyDenied) {
      await openAppSettings();
      return false;
    }
    // One more attempt after the rationale; otherwise the user taps again.
    final retry = await Permission.microphone.request();
    return retry.isGranted;
  }

  Future<void> _speakPrompt(bool hindi, String prompt) async {
    await _tts.setLanguage(hindi ? 'hi-IN' : 'en-IN');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    final result = await _tts.speak(prompt);
    if (result != 1) throw StateError('TTS speak failed');
  }

  Future<void> _onMicTap() async {
    final app = context.read<AppState>();
    final t = FxLocalizations.of(context);
    final ok = await _ensureMic();
    if (!ok || !mounted) return;

    final hindi = app.locale.languageCode == 'hi';
    try {
      await _speakPrompt(hindi, t.t('voicePrompt'));
    } catch (_) {
      // TTS engine missing: be honest, but the visual result cards in the
      // sheet still work, so continue into listening.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('voiceTtsMissing'))),
      );
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => VoiceSheet(tts: _tts),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Stack(
      children: [
        widget.child,
        Positioned(
          right: 16,
          bottom: 100, // floats just above the bottom navigation bar
          child: Semantics(
            label: t.t('voiceTitle'),
            button: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: MaxColors.orange,
                  shape: const CircleBorder(),
                  elevation: 8,
                  shadowColor: MaxColors.orange.withValues(alpha: 0.4),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _onMicTap,
                    child: Tooltip(
                      message: t.t('voiceTapMic'),
                      child: const SizedBox(
                        width: 60,
                        height: 60,
                        child: Icon(Icons.mic,
                            color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: MaxColors.ink.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
