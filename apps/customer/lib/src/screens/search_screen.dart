/// Service / provider search — MAXIMALISM edition: vibrant search bar,
/// colorful recent-search chips, rich provider cards. Logic unchanged.
library;

import 'dart:async';

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/max_provider_card.dart';
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
    return VoiceScreenTag(
      screenKey: 'search',
      child: MaxScaffold(
        body: Column(
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
                        color: MaxColors.orangeSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: MaxColors.orangeDeep),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Search pros 🔍',
                      style: MaxText.headline),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ---- Chunky colorful search bar ----
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: MaxColors.cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow:
                      maxShadow(MaxColors.orange, blur: 14),
                ),
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: t.t('searchServices'),
                    hintStyle: MaxText.body
                        .copyWith(color: MaxColors.inkFaint),
                    prefixIcon: const Icon(Icons.search,
                        color: MaxColors.orange),
                    suffixIcon: _query.isEmpty
                        ? Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient:
                                  MaxColors.heroGradient,
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.mic,
                                color: Colors.white, size: 20),
                          )
                        : IconButton(
                            icon: const Icon(Icons.clear,
                                color: MaxColors.inkFaint),
                            onPressed: () {
                              _ctrl.clear();
                              setState(() => _query = '');
                            },
                          ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: _onChanged,
                  onSubmitted: (_) => _submit(),
                  textInputAction: TextInputAction.search,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _query.isEmpty
                  ? _recentSearches(app)
                  : FutureBuilder<List<_Priced>>(
                      future: _search(_query),
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
                          padding: const EdgeInsets.all(16),
                          itemCount: results.length,
                          itemBuilder: (_, i) {
                            final e = results[i];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 12),
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
      ),
    );
  }

  Widget _recentSearches(AppState app) {
    final recent = app.recentSearches;
    if (recent.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MaxSectionHeader(title: 'Popular right now 🔥'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Plumber',
              'Electrician',
              'Deep cleaning',
              'AC repair',
              'Painter',
              'Carpenter',
            ].asMap().entries.map((e) {
              final (bg, fg) = MaxColors.pairFor(e.key);
              return GestureDetector(
                onTap: () {
                  _ctrl.text = e.value;
                  setState(() => _query = e.value);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: maxShadow(fg, blur: 8),
                  ),
                  child: Text(
                    e.value,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: fg,
                        fontSize: 13),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const EmptyState(
            icon: Icons.history,
            title: 'Search FixinDays',
            message:
                'Find plumbers, electricians, cleaners and more.',
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent searches',
                style: MaxText.headline.copyWith(fontSize: 18)),
            TextButton(
              onPressed: app.clearRecentSearches,
              style: TextButton.styleFrom(
                  foregroundColor: MaxColors.coral),
              child: const Text('Clear',
                  style:
                      TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recent.asMap().entries.map((e) {
            final (bg, fg) = MaxColors.pairFor(e.key);
            return GestureDetector(
              onTap: () {
                _ctrl.text = e.value;
                setState(() => _query = e.value);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 14, color: fg),
                    const SizedBox(width: 6),
                    Text(e.value,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: fg,
                            fontSize: 13)),
                  ],
                ),
              ),
            );
          }).toList(),
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
