/// Service / provider search with debounced input and recent searches.
library;

import 'dart:async';

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'provider_profile_screen.dart';

typedef _Priced = ({ProviderProfile provider, int? priceFrom});

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _query = v.trim());
    });
  }

  Future<List<_Priced>> _search(String q) async {
    final repos = context.read<AppState>().repos;
    final providers = await repos.catalog.searchProviders(
      query: q,
      sortBy: 'rating',
      limit: 20,
      offset: 0,
    );
    return Future.wait(providers.map((p) async {
      final services = await repos.catalog.providerServices(p.id);
      final min = services.isEmpty
          ? null
          : services
              .map((s) => s.pricePaise)
              .reduce((a, b) => a < b ? a : b);
      return (provider: p, priceFrom: min);
    }));
  }

  void _submit() {
    final q = _ctrl.text.trim();
    setState(() => _query = q);
    context.read<AppState>().addRecentSearch(q);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(t.t('searchServices'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Padding(
            padding: const EdgeInsets.all(FxSpacing.md),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: t.t('searchServices'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _ctrl.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: _onChanged,
              onSubmitted: (_) => _submit(),
              textInputAction: TextInputAction.search,
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? _recentSearches(app)
                : FutureBuilder<List<_Priced>>(
                    future: _search(_query),
                    builder: (_, snap) {
                      if (snap.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding:
                              EdgeInsets.all(FxSpacing.md),
                          child: FxLoadingList(),
                        );
                      }
                      if (snap.hasError) {
                        return ErrorPanel(
                          message: snap.error.toString(),
                          onRetry: () => setState(() {}),
                        );
                      }
                      final results = snap.data ?? [];
                      if (results.isEmpty) {
                        return EmptyState(
                          icon: Icons.search_off,
                          title: t.t('noResults'),
                          message: t.t('tryDifferentSearch'),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(FxSpacing.md),
                        itemCount: results.length,
                        itemBuilder: (_, i) {
                          final e = results[i];
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 12),
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

  Widget _recentSearches(AppState app) {
    final recent = app.recentSearches;
    if (recent.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        title: 'Search FixinDays',
        message:
            'Find plumbers, electricians, cleaners and more.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(FxSpacing.md),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent searches', style: FxText.title),
            TextButton(
              onPressed: app.clearRecentSearches,
              child: const Text('Clear'),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: recent
              .map((q) => ActionChip(
                    label: Text(q),
                    avatar: const Icon(Icons.history, size: 16),
                    onPressed: () {
                      _ctrl.text = q;
                      setState(() => _query = q);
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _openProvider(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => ProviderProfileScreen(providerId: id)),
    );
  }
}
