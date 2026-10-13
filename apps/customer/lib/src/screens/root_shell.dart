/// Root shell after auth — MAXIMALISM edition: colorful bottom
/// navigation with vibrant selected pill. Tab logic unchanged.
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
      backgroundColor: MaxColors.cream,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: MaxColors.cardWhite,
          boxShadow: [
            BoxShadow(
              color: MaxColors.orange.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _navItem(0, Icons.home_outlined, Icons.home,
                    t.t('home')),
                _navItem(
                    1,
                    Icons.calendar_month_outlined,
                    Icons.calendar_month_rounded,
                    t.t('bookings')),
                _navItem(2, Icons.person_outline,
                    Icons.person_rounded, t.t('profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      int i, IconData icon, IconData activeIcon, String label) {
    final selected = _index == i;
    final gradients = [
      MaxColors.heroGradient,
      MaxColors.oceanGradient,
      MaxColors.grapeGradient,
    ];
    return Expanded(
      child: GestureDetector(
        onTap: () {
          VoiceScreenTracker.setBase(_voiceKeys[i]);
          setState(() => _index = i);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? gradients[i] : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? maxShadow(
                    [MaxColors.orange, MaxColors.sky, MaxColors.purple][i],
                    blur: 12)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? activeIcon : icon,
                  color: selected
                      ? Colors.white
                      : MaxColors.inkFaint,
                  size: 24),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : MaxColors.inkFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
