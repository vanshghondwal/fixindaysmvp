/// Splash screen: branding + demo session restore, then route via the gate.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import 'partner_gate.dart';

class PartnerSplash extends StatefulWidget {
  const PartnerSplash({super.key});

  @override
  State<PartnerSplash> createState() => _PartnerSplashState();
}

class _PartnerSplashState extends State<PartnerSplash> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final state = context.read<PartnerState>();
    await state.restore();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PartnerGate()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FxColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: FxColors.white,
                borderRadius: BorderRadius.circular(FxRadius.xl),
              ),
              child: const Icon(Icons.handyman,
                  size: 52, color: FxColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'FixinDays Partner',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: FxColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              FxLocalizations.of(context).t('tagline'),
              style: const TextStyle(fontSize: 14, color: FxColors.white),
            ),
            const SizedBox(height: 28),
            const CircularProgressIndicator(color: FxColors.white),
          ],
        ),
      ),
    );
  }
}
