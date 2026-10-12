import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import 'booking_screen.dart';

/// Provider listing — the deck's "CHOOSE & BOOK" screen:
/// name, rating stars, ₹(onwards), verified tick, Book button.
class ProvidersScreen extends StatelessWidget {
  final String categoryId;
  const ProvidersScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final category = MockData.categories
        .firstWhere((c) => c.id == categoryId,
            orElse: () => MockData.categories.first);
    final providers = MockData.providersFor(categoryId);

    return Scaffold(
      appBar: AppBar(title: Text('${category.name} near you')),
      body: providers.isEmpty
          ? const Center(child: Text('No providers yet for this category.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: providers.length,
              itemBuilder: (context, i) {
                final p = providers[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor:
                                  FixTheme.primary.withOpacity(0.15),
                              child: const Icon(Icons.person,
                                  color: FixTheme.primary, size: 30),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(p.name,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      if (p.verified)
                                        const Padding(
                                          padding:
                                              EdgeInsets.only(left: 4),
                                          child: Icon(Icons.verified,
                                              size: 16,
                                              color: FixTheme.accent),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 16, color: FixTheme.star),
                                      Text(
                                          ' ${p.rating} (${p.reviewsCount} reviews)',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      Text('  ·  ${p.distance}',
                                          style: const TextStyle(
                                              color: Colors.black54)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('₹${p.priceOnwards} (onwards)',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BookingScreen(provider: p),
                                ),
                              ),
                              child: const Text('Book'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: p.services
                              .map((s) => Chip(
                                    label: Text(s,
                                        style: const TextStyle(
                                            fontSize: 11)),
                                    visualDensity:
                                        VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
