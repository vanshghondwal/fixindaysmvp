/// Provider management: search providers, activate/suspend accounts.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/admin_state.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  final _search = TextEditingController();
  late Future<List<ProviderProfile>> _future;

  @override
  void initState() {
    super.initState();
    _reload(initial: true);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<List<ProviderProfile>> _fetch(String q) {
    final state = context.read<AdminState>();
    final demo = state.demoRepo;
    if (demo != null) return demo.allProviders(query: q);
    return state.firestoreRepo!.searchProviders(q);
  }

  void _reload({bool initial = false}) {
    final f = _fetch(_search.text);
    if (initial) {
      _future = f;
    } else {
      setState(() => _future = f);
    }
  }

  Future<void> _toggleActive(
      BuildContext context, ProviderProfile p) async {
    final confirm = await fxConfirm(
      context,
      title: p.active ? 'Suspend provider?' : 'Activate provider?',
      message:
          '${p.businessName} will be ${p.active ? 'hidden from discovery and blocked from new bookings' : 'visible again for new bookings'}. This is written to the audit log.',
      confirmLabel: p.active ? 'Suspend' : 'Activate',
      destructive: p.active,
    );
    if (!confirm || !mounted) return;
    final state = context.read<AdminState>();
    try {
      await state.repo.setProviderActive(p.id, !p.active, state.adminId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('${p.businessName} ${p.active ? 'suspended' : 'activated'}.')));
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg, FxSpacing.lg, FxSpacing.lg, 0),
          child: FxTextField(
            controller: _search,
            label: 'Search providers',
            hint: 'Name, business or phone…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _search.clear();
                _reload();
              },
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ProviderProfile>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const FxLoadingList(count: 5);
              }
              if (snap.hasError) {
                return ErrorPanel(
                    message: '${snap.error}', onRetry: () => _reload());
              }
              final list = snap.data!;
              if (list.isEmpty) {
                return EmptyState(
                  icon: Icons.handyman_outlined,
                  title: 'No providers found',
                  message: 'Try a different search term.',
                  actionLabel: 'Search',
                  onAction: () => _reload(),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(FxSpacing.lg),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: FxSpacing.md),
                  itemBuilder: (context, i) =>
                      _providerCard(context, list[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _providerCard(BuildContext context, ProviderProfile p) {
    return FxCard(
      child: Row(
        children: [
          FxAvatar(name: p.businessName, radius: 22),
          const SizedBox(width: FxSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(p.businessName,
                            style: FxText.subtitle)),
                    if (p.isVerified) const VerifiedBadge(verified: true),
                  ],
                ),
                Text('${p.ownerName} · ${p.phone}', style: FxText.caption),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RatingStars(
                        rating: p.ratingAvg, size: 14),
                    const SizedBox(width: 6),
                    Text(
                        '${p.ratingAvg.toStringAsFixed(1)} (${p.ratingCount}) · ${p.verificationStatus.name}',
                        style: FxText.caption),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: FxSpacing.sm),
          Column(
            children: [
              StatusChip(
                label: p.active ? 'ACTIVE' : 'SUSPENDED',
                color:
                    p.active ? FxColors.primary : FxColors.error,
              ),
              const SizedBox(height: FxSpacing.sm),
              FxButton(
                label: p.active ? 'Suspend' : 'Activate',
                kind: p.active
                    ? FxButtonKind.destructive
                    : FxButtonKind.primary,
                onPressed: () => _toggleActive(context, p),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
