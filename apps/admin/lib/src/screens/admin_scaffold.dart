/// Shared admin chrome: [NavigationRail] on the left, a max-width content
/// column for desktop, [DemoBanner] on top when in demo mode, and a top bar
/// with the signed-in admin + sign-out.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/admin_state.dart';
import 'applications_screen.dart';
import 'audit_screen.dart';
import 'announcements_screen.dart';
import 'bookings_screen.dart';
import 'dashboard_screen.dart';
import 'providers_screen.dart';
import 'reviews_screen.dart';
import 'settings_screen.dart';
import 'tickets_screen.dart';
import 'users_screen.dart';

class AdminDestination {
  final String label;
  final IconData icon;
  final Widget Function() builder;
  const AdminDestination(this.label, this.icon, this.builder);
}

final List<AdminDestination> adminDestinations = [
  AdminDestination('Dashboard', Icons.dashboard_outlined, () => const DashboardScreen()),
  AdminDestination('Applications', Icons.verified_outlined, () => const ApplicationsScreen()),
  AdminDestination('Providers', Icons.handyman_outlined, () => const ProvidersScreen()),
  AdminDestination('Bookings', Icons.receipt_long_outlined, () => const BookingsScreen()),
  AdminDestination('Tickets', Icons.support_agent_outlined, () => const TicketsScreen()),
  AdminDestination('Reviews', Icons.star_outline, () => const ReviewsScreen()),
  AdminDestination('Users', Icons.people_outline, () => const UsersScreen()),
  AdminDestination('Announcements', Icons.campaign_outlined, () => const AnnouncementsScreen()),
  AdminDestination('Settings', Icons.settings_outlined, () => const SettingsScreen()),
  AdminDestination('Audit log', Icons.history_outlined, () => const AuditScreen()),
];

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();
    final dest = adminDestinations[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text(dest.label),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                '${state.email ?? ''} · ${state.repoLabel}',
                style: const TextStyle(fontSize: 12, color: FxColors.white),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => state.signOut(),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            backgroundColor: FxColors.white,
            destinations: [
              for (final d in adminDestinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.icon, color: FxColors.primary),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1, color: FxColors.borders),
          Expanded(
            child: Column(
              children: [
                if (state.demoMode) const DemoBanner(),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: dest.builder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
