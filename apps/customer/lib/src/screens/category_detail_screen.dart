/// Category detail: services offered across providers + providers serving
/// this category.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'provider_list_screen.dart';
import 'provider_profile_screen.dart';

typedef _ServiceEntry = ({
  ProviderService service,
  ProviderProfile provider,
});

typedef _CategoryData = ({
  List<ProviderProfile> providers,
  List<_ServiceEntry> services,
});

class CategoryDetailScreen extends StatefulWidget {
  final ServiceCategory category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Future<_CategoryData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_CategoryData> _load() async {
    final repos = context.read<AppState>().repos;
    final providers = await repos.catalog.searchProviders(
      categoryId: widget.category.id,
      sortBy: 'rating',
      limit: 30,
      offset: 0,
    );
    final services = <_ServiceEntry>[];
    await Future.wait(providers.map((p) async {
      final list = await repos.catalog.providerServices(p.id);
      for (final s in list) {
        if (s.categoryId == widget.category.id) {
          services.add((service: s, provider: p));
        }
      }
    }));
    services.sort((a, b) =>
        a.service.pricePaise.compareTo(b.service.pricePaise));
    return (providers: providers, services: services);
  }

  String _basisLabel(PriceBasis b) {
    switch (b) {
      case PriceBasis.fixed:
        return 'Fixed price';
      case PriceBasis.estimate:
        return 'Estimate';
      case PriceBasis.quote:
        return 'Quote on visit';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().locale.languageCode;
    return VoiceScreenTag(
      screenKey: 'category',
      child: Scaffold(
      appBar: AppBar(title: Text(widget.category.name(lang))),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<_CategoryData>(
              future: _future,
              builder: (_, snap) {
                if (snap.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(FxSpacing.md),
                    child: FxLoadingList(),
                  );
                }
                if (snap.hasError) {
                  return ErrorPanel(
                    message: snap.error.toString(),
                    onRetry: () =>
                        setState(() => _future = _load()),
                  );
                }
                final data = snap.data!;
                if (data.providers.isEmpty) {
                  return EmptyState(
                    icon: Icons.handyman_outlined,
                    title: FxLocalizations.of(context)
                        .t('noResults'),
                    message:
                        'No providers serve this category yet.',
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(FxSpacing.md),
                  children: [
                    if (data.services.isNotEmpty) ...[
                      FxSectionHeader(
                        title: 'Services',
                        actionLabel: 'All providers',
                        onAction: () =>
                            Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProviderListScreen(
                              categoryId: widget.category.id,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...data.services.map(_serviceRow),
                      const SizedBox(height: 16),
                    ],
                    const FxSectionHeader(title: 'Providers'),
                    const SizedBox(height: 8),
                    ...data.providers.map((p) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: 12),
                          child: ProviderCard(
                            provider: p,
                            onTap: () =>
                                _openProvider(p.id),
                            onBook: () =>
                                _openProvider(p.id),
                          ),
                        )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ));
  }

  Widget _serviceRow(_ServiceEntry e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FxCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.service.name,
                      style: FxText.subtitle),
                  const SizedBox(height: 2),
                  Text(e.provider.businessName,
                      style: FxText.caption),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(formatInr(e.service.pricePaise),
                          style: FxText.price
                              .copyWith(fontSize: 14)),
                      Text(' / ${e.service.unit}',
                          style: FxText.caption),
                      const SizedBox(width: 8),
                      Text('· ${_basisLabel(e.service.priceBasis)}',
                          style: FxText.caption),
                    ],
                  ),
                ],
              ),
            ),
            FxButton(
              label: 'Add',
              onPressed: () async {
                final app = context.read<AppState>();
                final added = await app.addToCart(
                    context, e.provider, e.service);
                if (added && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${e.service.name} added to cart')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openProvider(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => ProviderProfileScreen(providerId: id)),
    );
  }
}
