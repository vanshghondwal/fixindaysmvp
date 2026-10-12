/// Earnings: gross / commission / refunds / net cards + completed jobs.
///
/// Figures are computed from completed demo bookings and honestly labelled.
/// No fake settled payouts are shown — settlements are pending until a
/// payment gateway is configured.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  late Future<ProviderEarnings> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<ProviderEarnings> _load() {
    final state = context.read<PartnerState>();
    return state.ops.earnings(state.user!.id);
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('earnings'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: FutureBuilder<ProviderEarnings>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SingleChildScrollView(
                      padding: EdgeInsets.all(FxSpacing.lg),
                      child: FxLoadingList(),
                    );
                  }
                  if (snap.hasError) {
                    return ErrorPanel(
                      message: snap.error.toString(),
                      onRetry: _refresh,
                    );
                  }
                  final e = snap.data!;
                  return SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(FxSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FxCard(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text('Net earnings',
                                  style: FxText.subtitle),
                              const SizedBox(height: 4),
                              Text(formatInr(e.netPaise),
                                  style: FxText.headline.copyWith(
                                      fontSize: 28)),
                              const SizedBox(height: 4),
                              Text(
                                '${e.completedJobs} completed jobs',
                                style: FxText.caption,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _moneyCard(
                                  'Gross', e.grossPaise),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _moneyCard('Commission (10%)',
                                  e.commissionPaise),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _moneyCard(
                                  'Refunds', e.refundsPaise),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _moneyCard('Completed jobs',
                                  null,
                                  value:
                                      '${e.completedJobs}'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FxCard(
                          child: const Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  color: FxColors.warning),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Demo figures computed from your completed '
                                  'demo bookings. Settlements are pending — '
                                  'payouts need payment gateway configuration. '
                                  'No payouts have been settled.',
                                  style: FxText.caption,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moneyCard(String label, int? paise, {String? value}) {
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: FxText.caption),
          const SizedBox(height: 4),
          Text(value ?? formatInr(paise ?? 0), style: FxText.price),
        ],
      ),
    );
  }
}
