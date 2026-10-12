/// Shared post-auth routing for phone + email sign-in.
///
/// New users (empty name, or the demo placeholder name) go to profile setup;
/// users without a saved address go to the location screen; everyone else
/// lands on the home shell.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'location_screen.dart';
import 'profile_setup_screen.dart';
import 'root_shell.dart';

Future<void> completeSignIn(BuildContext context, AppUser user) async {
  final app = context.read<AppState>();
  app.setUser(user);
  // Demo auth creates a placeholder name; real phone auth leaves it empty.
  final needsProfile = user.name.trim().isEmpty ||
      (AppConfig.useDemoData && user.name == 'Demo Customer');
  final addresses = await app.repos.addresses.myAddresses(user.id);
  if (!context.mounted) return;
  final Widget next;
  if (needsProfile) {
    next = const ProfileSetupScreen();
  } else if (addresses.isEmpty) {
    next = const LocationScreen();
  } else {
    next = const RootShell();
  }
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => next),
    (_) => false,
  );
}
