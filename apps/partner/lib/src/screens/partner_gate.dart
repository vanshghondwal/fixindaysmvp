/// Auth gate: picks the right first screen from the partner's state.
///
/// * no user        -> [WelcomeScreen]
/// * no profile     -> [ProfileSetupScreen]
/// * no application -> [VerificationApplyScreen]
/// * not approved   -> [VerificationStatusScreen] (blocks the dashboard)
/// * approved       -> [HomeShell]
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import 'home_shell.dart';
import 'profile_setup_screen.dart';
import 'verification_apply_screen.dart';
import 'verification_status_screen.dart';
import 'welcome_screen.dart';

class PartnerGate extends StatelessWidget {
  const PartnerGate({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<PartnerState>();
    if (s.restoring) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (s.user == null) return const WelcomeScreen();
    if (s.profile == null) return const ProfileSetupScreen();
    final app = s.application;
    if (app == null) return const VerificationApplyScreen();
    if (app.status != VerificationStatus.approved) {
      return const VerificationStatusScreen();
    }
    return const HomeShell();
  }
}
