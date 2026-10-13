/// Provider list — MAXIMALISM edition: vibrant header, colorful filter
/// chips and sort pill, rich provider cards. Filter/sort logic unchanged.
///
/// Price sorting is done client-side from each provider's service list —
/// the demo catalogue notes that server-side price filtering isn't wired.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/max_provider_card.dart';
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
    return VoiceScreenTag(
      screenKey: 'providers',
      child: MaxScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          // ---- Vibrant header ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: MaxColors.purpleSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.arrow_back,
                        color: MaxColors.purple),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(t.t('providers'),
                      style: MaxText.headline),
                ),
                // Sort pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: MaxColors.cardWhite,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow:
                        maxShadow(MaxColors.orange, blur: 8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sort,
                      icon: const Icon(
                          Icons.sort_rounded,
                          color: MaxColors.orange,
                          size: 18),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: MaxColors.ink),
                      items: const [
                        DropdownMenuItem(
                            value: 'rating',
                            child: Text('Top rated')),
                        DropdownMenuItem(
                            value: 'priceAsc',
                            child: Text('Price ↑')),
                        DropdownMenuItem(
                            value: 'priceDesc',
                            child: Text('Price ↓')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          _sort = v;
                          _refresh();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ---- Colorful rating filter chips ----
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _filterChip('Any rating', null, 0),
                const SizedBox(width: 8),
                _filterChip('4.0+ ⭐', 4.0, 1),
                const SizedBox(width: 8),
                _filterChip('4.5+ 🌟', 4.5, 2),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<_Priced>>(
              future: _future,
              builder: (_, snap) {
                if (snap.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
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
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.person_search_outlined,
                    title: t.t('noResults'),
                    message: t.t('tryDifferentSearch'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final e = list[i];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 12),
                      child: MaxProviderCard(
                        provider: e.provider,
                        priceFromPaise: e.priceFrom,
                        colorIndex: i,
                        onTap: () =>
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
    ));
  }

  Widget _filterChip(String label, double? value, int colorIndex) {
    final selected = _minRating == value;
    final (bg, fg) = MaxColors.pairFor(colorIndex);
    return GestureDetector(
      onTap: () {
        _minRating = value;
        _refresh();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? MaxColors.heroGradient : null,
          color: selected ? null : bg,
          borderRadius: BorderRadius.circular(99),
          boxShadow: selected
              ? maxShadow(MaxColors.orange, blur: 10)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : fg,
          ),
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
