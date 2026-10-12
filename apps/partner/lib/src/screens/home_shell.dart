/// Home shell: bottom navigation with 5 tabs (max per spec).
///
/// Tabs: Dashboard, Requests (badge), Services, Earnings, Profile.
/// Other screens (upcoming, active service, history, availability, areas,
/// reviews, notifications, support, settings) are pushed from dashboard /
/// profile quick actions.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import 'catalogue_screen.dart';
import 'dashboard_screen.dart';
import 'earnings_screen.dart';
import 'profile_screen.dart';
import 'requests_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    DashboardScreen(),
    RequestsScreen(),
    CatalogueScreen(),
    EarningsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: FxColors.primary,
        unselectedItemColor: FxColors.secondaryText,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: t.t('dashboard'),
          ),
          BottomNavigationBarItem(
            icon: const _RequestsBadge(),
            label: t.t('requests'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            activeIcon: const Icon(Icons.inventory_2),
            label: t.t('services'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.payments_outlined),
            activeIcon: const Icon(Icons.payments),
            label: t.t('earnings'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: t.t('profile'),
          ),
        ],
      ),
    );
  }
}

/// Badge with the live count of pending requests (demo data).
class _RequestsBadge extends StatelessWidget {
  const _RequestsBadge();

  @override
  Widget build(BuildContext context) {
    final state = context.read<PartnerState>();
    final user = state.user;
    if (user == null) return const Icon(Icons.inbox_outlined);
    return FutureBuilder<List<Booking>>(
      future: state.ops.incomingRequests(user.id),
      builder: (context, snap) {
        final count = snap.data?.length ?? 0;
        return Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          child: const Icon(Icons.inbox_outlined),
        );
      },
    );
  }
}
