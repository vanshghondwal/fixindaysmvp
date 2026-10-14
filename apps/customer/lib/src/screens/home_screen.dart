/// Customer home — MAXIMALISM edition: vibrant greeting header, gradient
/// hero with search + live stats, colorful category grid, top-rated pros
/// and recent bookings. All data logic unchanged.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/max_bits.dart';
import '../widgets/max_provider_card.dart';
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

    return MaxScaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: MaxColors.orange,
        child: FutureBuilder<_HomeData>(
          future: _future,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: FxLoadingList(),
              );
            }
            if (snap.hasError) {
              return ErrorPanel(
                message: snap.error.toString(),
                onRetry: () => setState(() => _future = _load()),
              );
            }
            final data = snap.data!;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---- Vibrant header ----
                  _header(context, app, user, firstName, data.address),
                  const SizedBox(height: 12),
                  // ---- Gradient hero with search + stats ----
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: MaxHeroCard(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Home services,\n Sorted. ✨',
                            style: MaxText.onGradientBig,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Verified pros at your doorstep',
                            style: MaxText.onGradient.copyWith(
                                color: Colors.white
                                    .withValues(alpha: 0.92)),
                          ),
                          const SizedBox(height: 14),
                          // Search bar
                          GestureDetector(
                            onTap: () =>
                                Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const SearchScreen()),
                            ),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search,
                                      color: MaxColors.orange),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      t.t('searchServices'),
                                      style: MaxText.body.copyWith(
                                          color: MaxColors
                                              .inkFaint),
                                    ),
                                  ),
                                  const Icon(
                                      Icons.mic_none_outlined,
                                      color: MaxColors.inkFaint),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Live stats row
                          Row(
                            children: [
                              _heroStat(
                                  '${data.categories.length}',
                                  'Services'),
                              _heroStat('${data.top.length}+',
                                  'Top pros'),
                              _heroStat(
                                  '${data.recent.length}',
                                  'Active'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ---- Categories ----
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: MaxSectionHeader(
                      title: 'What do you need? 🛠️',
                      actionLabel: 'See all',
                      onAction: () =>
                          Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                const CategoriesScreen()),
                      ),
                    ),
                  ),
                  _categoryGrid(data.categories),
                  const SizedBox(height: 8),
                  // ---- Trust badges ----
                  _trustBadges(),
                  const SizedBox(height: 8),
                  // ---- Top rated ----
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child:
                        MaxSectionHeader(title: 'Top rated near you ⭐'),
                  ),
                  ...data.top.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.fromLTRB(
                            16, 0, 16, 12),
                        child: MaxProviderCard(
                          provider: e.value.provider,
                          priceFromPaise: e.value.priceFrom,
                          colorIndex: e.key,
                          onTap: () =>
                              _openProvider(e.value.provider.id),
                        ),
                      )),
                  // ---- Recent bookings ----
                  if (data.recent.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: MaxSectionHeader(
                        title: 'Happening now 🔥',
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
                              16, 0, 16, 12),
                          child: MaxCard(
                            shadowColor: MaxColors.purple,
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
                                          style: MaxText.title
                                              .copyWith(
                                                  fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat(
                                                'EEE, d MMM · h:mm a')
                                            .format(b.scheduledAt),
                                        style: MaxText.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                MaxStatusPill.booking(b.status),
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

  /// Vibrant custom header — greeting, address, colorful action badges.
  Widget _header(BuildContext context, AppState app,
      dynamic user, String firstName, Address? address) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: MaxColors.grapeGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: maxShadow(MaxColors.purple, blur: 12),
            ),
            alignment: Alignment.center,
            child: Text(
              firstName.isEmpty
                  ? '?'
                  : firstName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_greeting()}, $firstName 👋',
                    style: MaxText.title),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 13, color: MaxColors.coral),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        address == null
                            ? 'Add your address'
                            : address.short,
                        style: MaxText.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          StreamBuilder<List<NotificationItem>>(
            stream: app.repos.notifications.watch(user.id),
            builder: (_, snap) {
              final unread =
                  (snap.data ?? []).where((n) => !n.read).length;
              return _headerBtn(
                context,
                Icons.notifications_outlined,
                MaxColors.sunSoft,
                const Color(0xFFB8860B),
                unread,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) =>
                          const NotificationsScreen()),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _headerBtn(
            context,
            Icons.shopping_cart_outlined,
            MaxColors.mintSoft,
            const Color(0xFF1E9E50),
            app.cart.totalQty,
            () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const CartScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBtn(
    BuildContext context,
    IconData icon,
    Color bg,
    Color fg,
    int count,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: fg, size: 22),
          ),
          if (count > 0)
            Positioned(
              right: -5,
              top: -5,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: MaxColors.coral,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: MaxText.onGradientBig.copyWith(fontSize: 22)),
          Text(label,
              style: MaxText.onGradient.copyWith(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.85))),
        ],
      ),
    );
  }

  Widget _categoryGrid(List<ServiceCategory> categories) {
    final lang = context.watch<AppState>().locale.languageCode;
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No categories available right now.',
            style: MaxText.body),
      );
    }
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 8,
      childAspectRatio: 0.82,
      children: categories.asMap().entries.map((e) {
        final c = e.value;
        return MaxCategoryTile(
          icon: categoryIcon(c.iconName),
          label: c.name(lang),
          colorIndex: e.key,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CategoryDetailScreen(category: c),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _trustBadges() {
    const badges = [
      (Icons.verified, 'Verified pros', MaxColors.mintSoft,
          Color(0xFF1E9E50)),
      (Icons.payments, 'Clear pricing', MaxColors.sunSoft,
          Color(0xFFB8860B)),
      (Icons.support_agent, 'Easy support', MaxColors.skySoft,
          Color(0xFF1B7FC1)),
    ];
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: badges.asMap().entries.map((e) {
          final b = e.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  left: e.key == 0 ? 0 : 6,
                  right: e.key == badges.length - 1 ? 0 : 6),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: b.$3,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Icon(b.$1, color: b.$4, size: 26),
                    const SizedBox(height: 6),
                    Text(
                      b.$2,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: b.$4),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
