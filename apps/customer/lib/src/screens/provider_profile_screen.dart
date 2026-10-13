/// Provider profile — MAXIMALISM edition: gradient hero header,
/// colorful service cards with bold prices, vibrant CTAs.
/// Data loading and cart logic unchanged.
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
    final app = context.watch<AppState>();
    return VoiceScreenTag(
      screenKey: 'provider',
      child: MaxScaffold(
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
                    padding: EdgeInsets.all(16),
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
                final initial = p.businessName.isEmpty
                    ? '?'
                    : p.businessName.trim()[0].toUpperCase();
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ---- Gradient hero header ----
                    MaxHeroCard(
                      gradient: MaxColors.sunsetGradient,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(
                                        context)
                                    .pop(),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(
                                            alpha: 0.22),
                                    borderRadius:
                                        BorderRadius.circular(
                                            13),
                                  ),
                                  child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white),
                                ),
                              ),
                              const Spacer(),
                              if (p.isVerified)
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(
                                            alpha: 0.22),
                                    borderRadius:
                                        BorderRadius.circular(
                                            99),
                                  ),
                                  child: const Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified,
                                          color: Colors.white,
                                          size: 14),
                                      SizedBox(width: 4),
                                      Text('Verified',
                                          style: TextStyle(
                                              color:
                                                  Colors.white,
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight
                                                      .w800)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(
                                          22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(
                                              alpha: 0.15),
                                      blurRadius: 12,
                                      offset:
                                          const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight:
                                        FontWeight.w900,
                                    color:
                                        MaxColors.orangeDeep,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(p.businessName,
                                        style: MaxText
                                            .onGradientBig
                                            .copyWith(
                                                fontSize:
                                                    22),
                                        maxLines: 2,
                                        overflow: TextOverflow
                                            .ellipsis),
                                    const SizedBox(
                                        height: 6),
                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                              horizontal:
                                                  10,
                                              vertical: 5),
                                      decoration:
                                          BoxDecoration(
                                        color: Colors.white
                                            .withValues(
                                                alpha:
                                                    0.22),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    99),
                                      ),
                                      child: Row(
                                        mainAxisSize:
                                            MainAxisSize
                                                .min,
                                        children: [
                                          const Icon(
                                              Icons.star,
                                              color: Colors
                                                  .white,
                                              size: 14),
                                          const SizedBox(
                                              width: 4),
                                          Text(
                                            p.ratingCount >
                                                    0
                                                ? '${p.ratingAvg.toStringAsFixed(1)} · ${p.ratingCount} reviews'
                                                : 'New on FixinDays',
                                            style: const TextStyle(
                                                color: Colors
                                                    .white,
                                                fontSize:
                                                    12,
                                                fontWeight:
                                                    FontWeight
                                                        .w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${p.experienceYears} yrs experience · ${p.ownerName}',
                            style: MaxText.onGradient.copyWith(
                                fontSize: 13,
                                color: Colors.white.withValues(
                                    alpha: 0.92)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (p.description.isNotEmpty) ...[
                      const MaxSectionHeader(title: 'About 💬'),
                      MaxCard(
                        shadowColor: MaxColors.sky,
                        child: Text(p.description,
                            style: MaxText.body),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (p.serviceAreas.isNotEmpty) ...[
                      const MaxSectionHeader(
                          title: 'Service areas 📍'),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: p.serviceAreas
                            .asMap()
                            .entries
                            .map((e) {
                          final (bg, fg) =
                              MaxColors.pairFor(e.key);
                          return Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius:
                                  BorderRadius.circular(
                                      99),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: fg),
                                const SizedBox(width: 4),
                                Text(e.value,
                                    style: TextStyle(
                                        fontWeight:
                                            FontWeight.w700,
                                        color: fg,
                                        fontSize: 12)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    MaxSectionHeader(
                        title:
                            'Services (${d.services.length}) 🛠️'),
                    const SizedBox(height: 4),
                    if (d.services.isEmpty)
                      const MaxCard(
                        child: Text(
                            'This provider hasn\'t listed services yet.',
                            style: MaxText.body),
                      ),
                    ...d.services.asMap().entries.map((e) {
                      final s = e.value;
                      final (bg, fg) =
                          MaxColors.pairFor(e.key);
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: MaxCard(
                          shadowColor: fg,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(s.name,
                                        style: MaxText.title
                                            .copyWith(
                                                fontSize:
                                                    15)),
                                    if (s.description
                                        .isNotEmpty) ...[
                                      const SizedBox(
                                          height: 2),
                                      Text(s.description,
                                          style:
                                              MaxText.caption,
                                          maxLines: 2,
                                          overflow: TextOverflow
                                              .ellipsis),
                                    ],
                                    const SizedBox(
                                        height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                      10,
                                                  vertical:
                                                      5),
                                          decoration:
                                              BoxDecoration(
                                            color: bg,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        99),
                                          ),
                                          child: Text(
                                            formatInr(s
                                                .pricePaise),
                                            style:
                                                TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight
                                                      .w900,
                                              color: fg,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                            width: 6),
                                        Text(
                                            ' / ${s.unit} · ${_basisLabel(s.priceBasis)}',
                                            style:
                                                MaxText.caption),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  final added =
                                      await app.addToCart(
                                          context, p, s);
                                  if (added &&
                                      context.mounted) {
                                    ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${s.name} added to cart'),
                                        backgroundColor:
                                            MaxColors.ink,
                                        behavior:
                                            SnackBarBehavior
                                                .floating,
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      14),
                                        ),
                                        action:
                                            SnackBarAction(
                                          label: 'View cart',
                                          textColor:
                                              MaxColors.sun,
                                          onPressed: () =>
                                              Navigator.of(
                                                      context)
                                                  .push(
                                            MaterialPageRoute(
                                                builder:
                                                    (_) =>
                                                        const CartScreen()),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: MaxColors
                                        .heroGradient,
                                    borderRadius:
                                        BorderRadius.circular(
                                            14),
                                    boxShadow: maxShadow(
                                        MaxColors.orange,
                                        blur: 10),
                                  ),
                                  child: const Text('Add',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight
                                                  .w800)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            MaxColors.sunSoft,
                            MaxColors.orangeSoft,
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.event_available,
                              color: MaxColors.orangeDeep),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Slots are confirmed by the provider after you '
                              'book — there\'s no live calendar yet.',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: MaxColors.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    MaxSectionHeader(
                      title:
                          'Reviews (${d.reviews.length}) ⭐',
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
                    const SizedBox(height: 4),
                    if (d.reviews.isEmpty)
                      const Text('No reviews yet.',
                          style: MaxText.caption)
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
                padding: const EdgeInsets.all(16),
                child: MaxButton(
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
