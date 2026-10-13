/// Welcome screen with provider value props + sign in / register entry points.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';

import 'auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const props = [
      (Icons.inbox_outlined, 'Booking requests',
          'Get job requests from nearby customers in real time.'),
      (Icons.verified_outlined, 'Verified badge',
          'Verified partners get more bookings and better visibility.'),
      (Icons.payments_outlined, 'Transparent earnings',
          'See gross, commission and net payout for every job.'),
      (Icons.schedule_outlined, 'Your schedule',
          'Set working days and hours — you control availability.'),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (AppConfig.useDemoData) const DemoBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(FxSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: FxColors.primary,
                        borderRadius:
                            BorderRadius.circular(FxRadius.lg),
                      ),
                      child: const Icon(Icons.handyman,
                          size: 38, color: FxColors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text('FixinDays Partner', style: FxText.headline),
                    const SizedBox(height: 6),
                    Text(
                      FxLocalizations.of(context).t('tagline'),
                      style: FxText.body.copyWith(
                          color: FxColors.secondaryText),
                    ),
                    const SizedBox(height: 24),
                    ...props.map((p) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: FxSpacing.md),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: FxColors.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                      FxRadius.md),
                                ),
                                child: Icon(p.$1,
                                    color: FxColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(p.$2, style: FxText.subtitle),
                                    const SizedBox(height: 2),
                                    Text(p.$3,
                                        style: FxText.caption),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(FxSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FxButton(
                    label: 'Sign in',
                    onPressed: () => _openAuth(context, false),
                  ),
                  const SizedBox(height: 12),
                  FxButton(
                    label: 'Register as a partner',
                    kind: FxButtonKind.outlined,
                    onPressed: () => _openAuth(context, true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAuth(BuildContext context, bool register) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AuthScreen(startOnRegister: register),
      ),
    );
  }
}
