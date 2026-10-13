/// Root shell after auth: bottom navigation (Home, Bookings, Profile).
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';

import 'bookings_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  static const _voiceKeys = ['home', 'bookings', 'profile'];

  @override
  void initState() {
    super.initState();
    // IndexedStack builds all tabs at once, so the stack-based tag tracker
    // cannot know which tab is visible — set it explicitly here and on
    // every tab switch.
    VoiceScreenTracker.setBase(_voiceKeys[_index]);
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          VoiceScreenTracker.setBase(_voiceKeys[i]);
          setState(() => _index = i);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: t.t('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: t.t('bookings'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: t.t('profile'),
          ),
        ],
      ),
    );
  }
}
