import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data/mock_data.dart';
import '../services/app_state.dart';
import 'providers_screen.dart';

/// Home tab — matches the deck mockup:
/// search bar, 6-tile category grid, trust badges, top providers.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AppState>().userName;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Namaste, $userName 👋',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Text('Same Services. Brighter Days.',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            TextField(
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search uses mock data in demo build')),
              ),
            ),
            const SizedBox(height: 20),
            const Text('What do you need help with?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Category grid (6 tiles like the deck)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemCount: MockData.categories.length,
              itemBuilder: (context, i) {
                final c = MockData.categories[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    if (c.id == 'more') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('More services coming soon!')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProvidersScreen(categoryId: c.id),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(c.icon, size: 32, color: FixTheme.primary),
                        const SizedBox(height: 8),
                        Text(c.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Trust badges (deck: Verified Providers / Transparent Pricing / Real Reviews)
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Badge(icon: Icons.verified, label: 'Verified\nProviders'),
                _Badge(
                    icon: Icons.currency_rupee,
                    label: 'Transparent\nPricing'),
                _Badge(icon: Icons.star, label: 'Real\nReviews'),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Top rated near you',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...MockData.providers.take(3).map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: FixTheme.primary.withOpacity(0.15),
                      child: const Icon(Icons.handyman,
                          color: FixTheme.primary),
                    ),
                    title: Row(
                      children: [
                        Flexible(child: Text(p.name)),
                        if (p.verified)
                          const Icon(Icons.verified,
                              size: 16, color: FixTheme.accent),
                      ],
                    ),
                    subtitle: Text(
                        '⭐ ${p.rating}  ·  ₹${p.priceOnwards} onwards  ·  ${p.distance}'),
                    trailing: ElevatedButton(
                      child: const Text('Book'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProvidersScreen(categoryId: p.categoryId),
                        ),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Badge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: FixTheme.primary.withOpacity(0.12),
          child: Icon(icon, color: FixTheme.primary),
        ),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}
