/// Earnings — maximalism edition.
///
/// Gradient hero with the big net number, colorful breakdown cards for
/// gross / commission / refunds / jobs, and an honest demo-settlement note.
/// Figures are computed from completed demo bookings — no fake payouts.
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
    return MaxScaffold(
      appBar: AppBar(
        backgroundColor: MaxColors.cream,
        foregroundColor: MaxColors.ink,
        elevation: 0,
        title: Text(t.t('earnings'), style: MaxText.title),
      ),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: RefreshIndicator(
              color: MaxColors.orange,
              backgroundColor: MaxColors.cardWhite,
              onRefresh: () async => _refresh(),
              child: FutureBuilder<ProviderEarnings>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SingleChildScrollView(
                      padding: EdgeInsets.all(16),
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
                  final avgPaise = e.completedJobs > 0
                      ? e.netPaise ~/ e.completedJobs
                      : 0;
                  return SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MaxHeroCard(
                          gradient: MaxColors.mintGradient,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('NET EARNINGS',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 1.4)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.25),
                                      borderRadius:
                                          BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      '${e.completedJobs} jobs done',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(formatInr(e.netPaise),
                                  style: MaxText.onGradientBig
                                      .copyWith(fontSize: 40)),
                              const SizedBox(height: 4),
                              Text(
                                'Avg ${formatInr(avgPaise)} per completed job',
                                style: MaxText.onGradient,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _moneyCard(
                                'Gross',
                                formatInr(e.grossPaise),
                                Icons.trending_up,
                                MaxColors.skySoft,
                                MaxColors.sky,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _moneyCard(
                                'Commission (10%)',
                                formatInr(e.commissionPaise),
                                Icons.percent_outlined,
                                MaxColors.coralSoft,
                                MaxColors.coral,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _moneyCard(
                                'Refunds',
                                formatInr(e.refundsPaise),
                                Icons.replay_outlined,
                                MaxColors.purpleSoft,
                                MaxColors.purple,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _moneyCard(
                                'Completed jobs',
                                '${e.completedJobs}',
                                Icons.check_circle_outline,
                                MaxColors.sunSoft,
                                const Color(0xFFB8860B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: MaxColors.sunSoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  color: Color(0xFFB8860B)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Demo figures computed from your completed '
                                  'demo bookings. Settlements are pending — '
                                  'payouts need payment gateway configuration. '
                                  'No payouts have been settled.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: MaxColors.inkSoft),
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

  Widget _moneyCard(String label, String value, IconData icon,
      Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: maxShadow(fg, blur: 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 24),
          const SizedBox(height: 10),
          Text(value,
              style: MaxText.bigNumber
                  .copyWith(color: fg, fontSize: 20)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: MaxColors.inkSoft)),
        ],
      ),
    );
  }
}
