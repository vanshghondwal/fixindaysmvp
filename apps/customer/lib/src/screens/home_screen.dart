/// Customer home: greeting, address, search, categories, trust badges,
/// top-rated providers and recent bookings.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'booking_detail_screen.dart';
import 'bookings_screen.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'category_detail_screen.dart';
import 'notifications_screen.dart';
import 'provider_profile_screen.dart';
import 'search_screen.dart';

typedef _HomeData = ({
  List<ServiceCategory> categories,
  List<({ProviderProfile provider, int? priceFrom})> top,
  Address? address,
  List<Booking> recent,
});

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final app = context.read<AppState>();
    final repos = app.repos;
    final categories = await repos.catalog.categories();
    final providers = await repos.catalog
        .searchProviders(sortBy: 'rating', limit: 3, offset: 0);
    final top = await Future.wait(providers.map((p) async {
      final services = await repos.catalog.providerServices(p.id);
      final min = services.isEmpty
          ? null
          : services
              .map((s) => s.pricePaise)
              .reduce((a, b) => a < b ? a : b);
      return (provider: p, priceFrom: min);
    }));
    final user = app.user!;
    final addresses = await repos.addresses.myAddresses(user.id);
    Address? def;
    if (addresses.isNotEmpty) {
      try {
        def = addresses.firstWhere((a) => a.isDefault);
      } catch (_) {
        def = addresses.first;
      }
    }
    final bookings = await repos.bookings.myBookings(user.id);
    final recent = bookings.where((b) => b.isActive).take(3).toList();
    return (
      categories: categories,
      top: top,
      address: def,
      recent: recent,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.user!;
    final firstName = user.name.trim().isEmpty
        ? 'there'
        : user.name.trim().split(' ').first;
    final t = FxLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_greeting()}, $firstName'),
            FutureBuilder<Address?>(
              future: _future.then((d) => d.address),
              builder: (_, snap) {
                final a = snap.data;
                return Text(
                  a == null ? 'Add your address' : a.short,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ],
        ),
        actions: [
          StreamBuilder<List<NotificationItem>>(
            stream: app.repos.notifications.watch(user.id),
            builder: (_, snap) {
              final unread =
                  (snap.data ?? []).where((n) => !n.read).length;
              return IconButton(
                icon: _badge(Icons.notifications_outlined, unread),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) =>
                          const NotificationsScreen()),
                ),
              );
            },
          ),
          IconButton(
            icon: _badge(
                Icons.shopping_cart_outlined, app.cart.totalQty),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_HomeData>(
          future: _future,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SingleChildScrollView(
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
            final data = snap.data!;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (AppConfig.useDemoData) const DemoBanner(),
                  Padding(
                    padding: const EdgeInsets.all(FxSpacing.md),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SearchScreen()),
                      ),
                      child: AbsorbPointer(
                        child: TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: t.t('searchServices'),
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: FxSpacing.md),
                    child: FxSectionHeader(
                      title: 'Categories',
                      actionLabel: 'See all',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                const CategoriesScreen()),
                      ),
                    ),
                  ),
                  _categoryGrid(data.categories),
                  const SizedBox(height: 8),
                  _trustBadges(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: FxSpacing.md),
                    child: FxSectionHeader(
                        title: 'Top rated near you'),
                  ),
                  ...data.top.map((e) => Padding(
                        padding: const EdgeInsets.fromLTRB(
                            FxSpacing.md, 0, FxSpacing.md, 12),
                        child: ProviderCard(
                          provider: e.provider,
                          priceFromPaise: e.priceFrom,
                          onTap: () => _openProvider(e.provider.id),
                          onBook: () => _openProvider(e.provider.id),
                        ),
                      )),
                  if (data.recent.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: FxSpacing.md),
                      child: FxSectionHeader(
                        title: 'Recent bookings',
                        actionLabel: 'View all',
                        onAction: () =>
                            Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  const BookingsScreen()),
                        ),
                      ),
                    ),
                    ...data.recent.map((b) => Padding(
                          padding: const EdgeInsets.fromLTRB(
                              FxSpacing.md, 0, FxSpacing.md, 12),
                          child: FxCard(
                            onTap: () =>
                                Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    BookingDetailScreen(
                                        bookingId: b.id),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(b.providerName,
                                          style: FxText.subtitle),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat(
                                                'EEE, d MMM · h:mm a')
                                            .format(b.scheduledAt),
                                        style: FxText.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                StatusChip.booking(b.status),
                              ],
                            ),
                          ),
                        )),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
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

  Widget _badge(IconData icon, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(FxSpacing.xs),
              decoration: const BoxDecoration(
                color: FxColors.error,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                    color: FxColors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  Widget _categoryGrid(List<ServiceCategory> categories) {
    final lang = context.watch<AppState>().locale.languageCode;
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(FxSpacing.md),
        child: Text('No categories available right now.'),
      );
    }
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(FxSpacing.md),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: categories
          .map((c) => CategoryTile(
                name: c.name(lang),
                icon: categoryIcon(c.iconName),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        CategoryDetailScreen(category: c),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _trustBadges() {
    const badges = [
      (Icons.verified_outlined, 'Verified pros'),
      (Icons.payments_outlined, 'Transparent pricing'),
      (Icons.support_agent_outlined, 'Easy support'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.md, vertical: 8),
      child: Row(
        children: badges
            .map((b) => Expanded(
                  child: FxCard(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 4),
                    child: Column(
                      children: [
                        Icon(b.$1,
                            color: FxColors.primary, size: 26),
                        const SizedBox(height: 6),
                        Text(
                          b.$2,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
