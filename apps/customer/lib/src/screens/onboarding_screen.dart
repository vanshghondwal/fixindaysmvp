/// First-run onboarding: 3 swipeable pages with Skip + Get Started.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'root_shell.dart';
import 'welcome_screen.dart';

class _Page {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Page(this.icon, this.title, this.subtitle);
}

const _pages = [
  _Page(
    Icons.search,
    'Discover trusted pros',
    'Plumbers, electricians, cleaners and more — local professionals near you.',
  ),
  _Page(
    Icons.compare_arrows,
    'Compare & choose',
    'Check ratings, reviews and transparent upfront pricing before you book.',
  ),
  _Page(
    Icons.calendar_month,
    'Book in seconds',
    'Pick a slot, track your booking live, and pay cash after the service.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    final app = context.read<AppState>();
    app.completeOnboarding();
    final next =
        app.user == null ? const WelcomeScreen() : const RootShell();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(FxSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: FxColors.primary.withValues(alpha: 0.12),
                            borderRadius:
                                const BorderRadius.circular(FxRadius.xl),
                          ),
                          child: Icon(p.icon,
                              size: 56, color: FxColors.primary),
                        ),
                        const SizedBox(height: FxSpacing.xl),
                        Text(p.title,
                            style: FxText.headline,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(
                          p.subtitle,
                          style: FxText.body.copyWith(
                              color: FxColors.secondaryText),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? FxColors.primary
                        : FxColors.borders,
                    borderRadius: const BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(FxSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: FxButton(
                  label: last ? 'Get Started' : 'Next',
                  onPressed: () {
                    if (last) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
