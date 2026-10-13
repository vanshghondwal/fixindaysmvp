/// Provider profile: photo, verification, experience, service areas,
/// services with prices, availability note and review previews.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'cart_screen.dart';
import 'reviews_screen.dart';

typedef _ProfileData = ({
  ProviderProfile provider,
  List<ProviderService> services,
  List<Review> reviews,
});

class ProviderProfileScreen extends StatefulWidget {
  final String providerId;

  const ProviderProfileScreen({super.key, required this.providerId});

  @override
  State<ProviderProfileScreen> createState() =>
      _ProviderProfileScreenState();
}

class _ProviderProfileScreenState
    extends State<ProviderProfileScreen> {
  late Future<_ProfileData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProfileData> _load() async {
    final repos = context.read<AppState>().repos;
    final provider =
        await repos.catalog.provider(widget.providerId);
    if (provider == null) throw StateError('Provider not found');
    final services =
        await repos.catalog.providerServices(provider.id);
    final reviews =
        await repos.catalog.providerReviews(provider.id);
    return (
      provider: provider,
      services: services,
      reviews: reviews,
    );
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
    final t = FxLocalizations.of(context);
    final app = context.watch<AppState>();
    return VoiceScreenTag(
      screenKey: 'provider',
      child: Scaffold(
      appBar: AppBar(title: Text(t.t('provider'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: FutureBuilder<_ProfileData>(
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
                final d = snap.data!;
                final p = d.provider;
                return ListView(
                  padding: const EdgeInsets.all(FxSpacing.md),
                  children: [
                    FxCard(
                      child: Row(
                        children: [
                          FxAvatar(
                              name: p.businessName,
                              radius: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                          p.businessName,
                                          style:
                                              FxText.title),
                                    ),
                                    const SizedBox(width: 6),
                                    VerifiedBadge(
                                        verified:
                                            p.isVerified),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    RatingStars(
                                        rating: p.ratingAvg,
                                        size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      p.ratingCount > 0
                                          ? '${p.ratingAvg.toStringAsFixed(1)} (${p.ratingCount} reviews)'
                                          : 'No ratings yet',
                                      style: FxText.caption,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${p.experienceYears} yrs experience · ${p.ownerName}',
                                  style: FxText.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (p.description.isNotEmpty) ...[
                      FxSectionHeader(title: 'About'),
                      Text(p.description,
                          style: FxText.body),
                      const SizedBox(height: 12),
                    ],
                    if (p.serviceAreas.isNotEmpty) ...[
                      FxSectionHeader(title: 'Service areas'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: p.serviceAreas
                            .map((a) => Chip(label: Text(a)))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    FxSectionHeader(
                        title:
                            'Services (${d.services.length})'),
                    const SizedBox(height: 8),
                    if (d.services.isEmpty)
                      const Text(
                          'This provider hasn\'t listed services yet.'),
                    ...d.services.map((s) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: 12),
                          child: FxCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(s.name,
                                          style:
                                              FxText.subtitle),
                                      if (s.description
                                          .isNotEmpty) ...[
                                        const SizedBox(
                                            height: 2),
                                        Text(s.description,
                                            style:
                                                FxText.caption),
                                      ],
                                      const SizedBox(
                                          height: 4),
                                      Row(
                                        children: [
                                          Text(
                                              formatInr(s
                                                  .pricePaise),
                                              style: FxText
                                                  .price
                                                  .copyWith(
                                                      fontSize:
                                                          14)),
                                          Text(
                                              ' / ${s.unit}',
                                              style:
                                                  FxText
                                                      .caption),
                                          const SizedBox(
                                              width: 8),
                                          Text(
                                              '· ${_basisLabel(s.priceBasis)}',
                                              style: FxText
                                                  .caption),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                FxButton(
                                  label: 'Add',
                                  onPressed: () async {
                                    final added =
                                        await app.addToCart(
                                            context,
                                            p,
                                            s);
                                    if (added &&
                                        context.mounted) {
                                      ScaffoldMessenger.of(
                                              context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${s.name} added to cart'),
                                          action: SnackBarAction(
                                            label:
                                                'View cart',
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .push(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const CartScreen()),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 4),
                    Container(
                      padding:
                          const EdgeInsets.all(FxSpacing.md),
                      decoration: BoxDecoration(
                        color: FxColors.primary
                            .withOpacity(0.08),
                        borderRadius: BorderRadius.circular(
                            FxRadius.md),
                      ),
                      child: const Text(
                        'Slots are confirmed by the provider after you '
                        'book — there\'s no live calendar yet.',
                        style: TextStyle(
                            fontSize: 13,
                            color: FxColors.navy),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FxSectionHeader(
                      title:
                          'Reviews (${d.reviews.length})',
                      actionLabel:
                          d.reviews.isEmpty ? null : 'See all',
                      onAction: () =>
                          Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReviewsScreen(
                              providerId: p.id),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (d.reviews.isEmpty)
                      Text('No reviews yet.',
                          style: FxText.caption)
                    else
                      ...d.reviews
                          .take(2)
                          .map((r) => Padding(
                                padding:
                                    const EdgeInsets.only(
                                        bottom: 8),
                                child: ReviewCard(
                                    review: r),
                              )),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: app.cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(FxSpacing.md),
                child: FxButton(
                  label:
                      'View cart (${app.cart.totalQty}) · ${formatInr(app.cart.totals().totalPaise)}',
                  icon: Icons.shopping_cart_outlined,
                  onPressed: () =>
                      Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const CartScreen()),
                  ),
                ),
              ),
            ),
    ));
  }
}
