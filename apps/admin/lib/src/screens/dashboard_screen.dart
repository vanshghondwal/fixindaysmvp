/// Platform overview: key metric cards from [AdminRepository.dashboard].
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/admin_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<AdminDashboard> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AdminState>().repo.dashboard();
  }

  void _reload() {
    setState(() {
      _future = context.read<AdminState>().repo.dashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminDashboard>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const FxLoadingList(count: 6);
        }
        if (snap.hasError) {
          return ErrorPanel(
              message: '${snap.error}', onRetry: _reload);
        }
        final d = snap.data!;
        final metrics = [
          _Metric('Customers', d.totalCustomers, Icons.people_outline,
              FxColors.primary),
          _Metric('Providers', d.totalProviders, Icons.handyman_outlined,
              FxColors.navy),
          _Metric('Pending applications', d.pendingApplications,
              Icons.verified_outlined, FxColors.warning),
          _Metric('Active bookings', d.activeBookings,
              Icons.receipt_long_outlined, FxColors.darkGreen),
          _Metric('Open tickets', d.openTickets,
              Icons.support_agent_outlined, FxColors.error),
          _Metric("Today's bookings", d.bookingsToday,
              Icons.today_outlined, FxColors.deepGreen),
        ];
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: const EdgeInsets.all(FxSpacing.lg),
            children: [
              const FxSectionHeader(title: 'Platform overview'),
              const SizedBox(height: FxSpacing.md),
              LayoutBuilder(builder: (context, c) {
                final cols = c.maxWidth > 900 ? 3 : (c.maxWidth > 560 ? 2 : 1);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: FxSpacing.md,
                    crossAxisSpacing: FxSpacing.md,
                    mainAxisExtent: 132,
                  ),
                  itemCount: metrics.length,
                  itemBuilder: (context, i) => _metricCard(metrics[i]),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _metricCard(_Metric m) {
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: m.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(FxRadius.md),
                ),
                child: Icon(m.icon, color: m.color, size: 22),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: _reload,
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
          Text('${m.value}',
              style: FxText.headline.copyWith(fontSize: 28)),
          Text(m.label, style: FxText.caption),
        ],
      ),
    );
  }
}

class _Metric {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _Metric(this.label, this.value, this.icon, this.color);
}
