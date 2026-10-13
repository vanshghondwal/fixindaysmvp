/// Service catalogue: my services with active toggles, edit and add.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import 'service_edit_screen.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  late Future<List<ProviderService>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ProviderService>> _load() {
    final state = context.read<PartnerState>();
    return state.ops.myServices(state.user!.id);
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _toggle(ProviderService s, bool active) async {
    try {
      await context.read<PartnerState>().ops.setServiceActive(s.id, active);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update: $e')));
    }
  }

  void _edit(ProviderService? s) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => ServiceEditScreen(service: s),
        ))
        .then((saved) {
      if (saved == true) _refresh();
    });
  }

  String _priceLabel(ProviderService s) {
    final basis = switch (s.priceBasis) {
      PriceBasis.fixed => 'Fixed',
      PriceBasis.estimate => 'Starting',
      PriceBasis.quote => 'On quote',
    };
    if (s.priceBasis == PriceBasis.quote) return 'Price on quote';
    return '$basis ${formatInr(s.pricePaise)} / ${s.unit}';
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('services'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(null),
        icon: const Icon(Icons.add),
        label: const Text('Add service'),
      ),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: FutureBuilder<List<ProviderService>>(
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
                  final items = snap.data!;
                  if (items.isEmpty) {
                    return SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      child: EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'No services yet',
                        message:
                            'Add the services you offer so customers can book them.',
                        actionLabel: 'Add service',
                        onAction: () => _edit(null),
                      ),
                    );
                  }
                  return ListView.separated(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(FxSpacing.lg),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final s = items[i];
                      return FxCard(
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: FxColors.primary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                    FxRadius.md),
                              ),
                              child: Icon(
                                categoryIcon(_iconKey(s.categoryId)),
                                color: FxColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(s.name,
                                      style: FxText.subtitle),
                                  Text(_priceLabel(s),
                                      style: FxText.caption),
                                  if (s.durationMin != null)
                                    Text(
                                        '~${s.durationMin} min per ${s.unit}',
                                        style: FxText.caption),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Edit',
                              onPressed: () => _edit(s),
                            ),
                            Switch(
                              value: s.active,
                              onChanged: (v) => _toggle(s, v),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _iconKey(String categoryId) {
    // Maps the demo category ids to the icon keys core understands.
    return switch (categoryId) {
      'plumbing' => 'plumbing',
      'electrical' => 'bolt',
      'cleaning' => 'cleaning_services',
      'appliance' => 'ac_unit',
      'painting' => 'format_paint',
      'carpentry' => 'handyman',
      _ => 'handyman',
    };
  }
}
