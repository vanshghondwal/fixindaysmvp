/// Welcome screen: customer identity, sign-in options, Terms & Privacy.
///
/// The Terms/Privacy dialogs carry honest placeholder copy — the real legal
/// text is pending review before production launch.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'auth/email_auth_screen.dart';
import 'auth/phone_auth_screen.dart';

const _termsPlaceholder =
    'Placeholder — the full Terms of Service are being drafted and will be '
    'reviewed by legal before the production launch. Nothing here is the '
    'final agreement.';

const _privacyPlaceholder =
    'Placeholder — the full Privacy Policy is being drafted and will be '
    'reviewed by legal before the production launch. In demo mode no real '
    'personal data leaves your device.';

Future<void> showLegalDialog(
  BuildContext context, {
  required String title,
  required String body,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        FxButton(
          label: 'Close',
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FxSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.handyman,
                  size: 72, color: FxColors.primary),
              const SizedBox(height: 16),
              Text(t.t('appName'),
                  style: FxText.headline, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                t.t('tagline'),
                style:
                    FxText.body.copyWith(color: FxColors.secondaryText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Book verified local pros for home services.',
                style:
                    FxText.body.copyWith(color: FxColors.secondaryText),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FxButton(
                label: 'Continue with phone',
                icon: Icons.phone,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const PhoneAuthScreen()),
                ),
              ),
              const SizedBox(height: 12),
              FxButton(
                label: 'Continue with email',
                kind: FxButtonKind.outlined,
                icon: Icons.email_outlined,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const EmailAuthScreen()),
                ),
              ),
              const SizedBox(height: 24),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: FxText.caption,
                  children: [
                    const TextSpan(
                        text: 'By continuing you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: const TextStyle(
                          color: FxColors.primary,
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => showLegalDialog(
                              context,
                              title: 'Terms of Service',
                              body: _termsPlaceholder,
                            ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                          color: FxColors.primary,
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => showLegalDialog(
                              context,
                              title: 'Privacy Policy',
                              body: _privacyPlaceholder,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
