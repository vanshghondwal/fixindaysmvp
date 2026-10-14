/// Customer favorites — saved providers with heart toggles.
///
/// Mock data only; in production this would sync with the user's
/// Firestore document.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Mock saved providers.
  final List<_FavProvider> _favorites = [
    const _FavProvider(
        name: 'Rajesh Electricals',
        category: 'Electrician',
        rating: 4.8,
        jobs: 240,
        priceFrom: 29900,
        colorIndex: 3),
    const _FavProvider(
        name: 'Sparkle Home Cleaning',
        category: 'Cleaning',
        rating: 4.9,
        jobs: 512,
        priceFrom: 49900,
        colorIndex: 2),
    const _FavProvider(
        name: 'AquaFix Plumbing',
        category: 'Plumber',
        rating: 4.7,
        jobs: 188,
        priceFrom: 19900,
        colorIndex: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return MaxScaffold(
      appBar: AppBar(
        backgroundColor: MaxColors.cream,
        foregroundColor: MaxColors.ink,
        elevation: 0,
        title: const Text('Favorites', style: MaxText.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: _favorites.isEmpty
                ? const EmptyState(
                    icon: Icons.favorite_outline,
                    title: 'No favorites yet',
                    message:
                        'Tap the heart on any provider to save them here for quick booking.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favorites.length,
                    itemBuilder: (_, i) {
                      final f = _favorites[i];
                      final (bg, fg) = MaxColors.pairFor(f.colorIndex);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MaxCard(
                          shadowColor: fg,
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  f.name[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: fg,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(f.name,
                                        style: MaxText.title
                                            .copyWith(fontSize: 15)),
                                    const SizedBox(height: 2),
                                    Text(f.category,
                                        style: MaxText.caption),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        MaxPill(
                                          label:
                                              '★ ${f.rating.toStringAsFixed(1)}',
                                          bg: MaxColors.sunSoft,
                                          fg: const Color(0xFFB8860B),
                                        ),
                                        const SizedBox(width: 6),
                                        MaxPill(
                                          label:
                                              'from ${formatInr(f.priceFrom)}',
                                          bg: MaxColors.mintSoft,
                                          fg: const Color(0xFF1E9E50),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.favorite,
                                    color: MaxColors.coral),
                                onPressed: () {
                                  setState(() {
                                    _favorites.removeAt(i);
                                  });
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${f.name} removed from favorites'),
                                      behavior:
                                          SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FavProvider {
  final String name;
  final String category;
  final double rating;
  final int jobs;
  final int priceFrom;
  final int colorIndex;

  const _FavProvider({
    required this.name,
    required this.category,
    required this.rating,
    required this.jobs,
    required this.priceFrom,
    required this.colorIndex,
  });
}
