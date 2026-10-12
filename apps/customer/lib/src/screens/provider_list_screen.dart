/// Provider list with rating filter and rating/price sorting.
///
/// Price sorting is done client-side from each provider's service list —
/// the demo catalogue notes that server-side price filtering isn't wired.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'provider_profile_screen.dart';

typedef _Priced = ({ProviderProfile provider, int? priceFrom});

class ProviderListScreen extends StatefulWidget {
  final String? categoryId;
  final String? initialQuery;

  const ProviderListScreen({
    super.key,
    this.categoryId,
    this.initialQuery,
  });

  @override
  State<ProviderListScreen> createState() =>
      _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  double? _minRating;
  String _sort = 'rating'; // rating | priceAsc | priceDesc
  late Future<List<_Priced>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_Priced>> _load() async {
    final repos = context.read<AppState>().repos;
    final providers = await repos.catalog.searchProviders(
      categoryId: widget.categoryId,
      query: widget.initialQuery,
      minRating: _minRating,
      sortBy: 'rating',
      limit: 30,
      offset: 0,
    );
    final priced = await Future.wait(providers.map((p) async {
      final services = await repos.catalog.providerServices(p.id);
      final min = services.isEmpty
          ? null
          : services
              .map((s) => s.pricePaise)
              .reduce((a, b) => a < b ? a : b);
      return (provider: p, priceFrom: min);
    }));
    switch (_sort) {
      case 'priceAsc':
        priced.sort((a, b) =>
            (a.priceFrom ?? 1 << 60).compareTo(b.priceFrom ?? 1 << 60));
      case 'priceDesc':
        priced.sort((a, b) =>
            (b.priceFrom ?? -1).compareTo(a.priceFrom ?? -1));
      default:
        priced.sort((a, b) =>
            b.provider.ratingAvg.compareTo(a.provider.ratingAvg));
    }
    return priced;
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Providers')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                FxSpacing.md, FxSpacing.md, FxSpacing.md, 0),
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterChip(
                  label: const Text('Any rating'),
                  selected: _minRating == null,
                  onSelected: (_) {
                    _minRating = null;
                    _refresh();
                  },
                ),
                FilterChip(
                  label: const Text('4.0+'),
                  selected: _minRating == 4.0,
                  onSelected: (_) {
                    _minRating = 4.0;
                    _refresh();
                  },
                ),
                FilterChip(
                  label: const Text('4.5+'),
                  selected: _minRating == 4.5,
                  onSelected: (_) {
                    _minRating = 4.5;
                    _refresh();
                  },
                ),
                DropdownButton<String>(
                  value: _sort,
                  items: const [
                    DropdownMenuItem(
                        value: 'rating',
                        child: Text('Top rated')),
                    DropdownMenuItem(
                        value: 'priceAsc',
                        child: Text('Price: low to high')),
                    DropdownMenuItem(
                        value: 'priceDesc',
                        child: Text('Price: high to low')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      _sort = v;
                      _refresh();
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: FxSpacing.md, vertical: 8),
            child: Text(
              'Distances aren\'t shown — precise location needs a Maps API '
              'key (see FIREBASE_SETUP.md).',
              style: FxText.caption,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<_Priced>>(
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
                    onRetry: _refresh,
                  );
                }
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.person_search_outlined,
                    title: t.t('noResults'),
                    message: t.t('tryDifferentSearch'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(FxSpacing.md),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final e = list[i];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 12),
                      child: ProviderCard(
                        provider: e.provider,
                        priceFromPaise: e.priceFrom,
                        onTap: () =>
                            _openProvider(e.provider.id),
                        onBook: () =>
                            _openProvider(e.provider.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
