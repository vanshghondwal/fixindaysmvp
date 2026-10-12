/// Root app state for the FixinDays customer app.
///
/// Holds the repository bundle (demo mode until Firebase is configured),
/// the signed-in user, the UI locale and the single-provider cart.
library;

import 'dart:collection';

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';

/// One line in the customer's cart.
class CartItem {
  final ProviderService service;
  int qty;

  CartItem(this.service, this.qty);

  BookingLineItem toLineItem() => BookingLineItem(
        serviceId: service.id,
        serviceName: service.name,
        quantity: qty,
        unitPricePaise: service.pricePaise,
        priceBasis: service.priceBasis,
      );
}

/// Cart is scoped to a single provider (marketplace rule enforced by [AppState.addToCart]).
class CartState extends ChangeNotifier {
  ProviderProfile? provider;
  final Map<String, CartItem> _items = {};

  UnmodifiableMapView<String, CartItem> get items =>
      UnmodifiableMapView(_items);

  bool get isEmpty => _items.isEmpty;
  int get totalQty => _items.values.fold(0, (s, i) => s + i.qty);

  List<BookingLineItem> get lineItems =>
      _items.values.map((e) => e.toLineItem()).toList();

  Totals totals({int commissionBps = 1000}) =>
      calcTotals(lineItems, commissionBps: commissionBps);

  void setProvider(ProviderProfile p) {
    provider = p;
  }

  void add(ProviderService service) {
    final existing = _items[service.id];
    if (existing == null) {
      _items[service.id] = CartItem(service, 1);
    } else {
      existing.qty++;
    }
    notifyListeners();
  }

  void setQty(String serviceId, int qty) {
    if (qty <= 0) {
      _items.remove(serviceId);
    } else {
      final item = _items[serviceId];
      if (item != null) item.qty = qty;
    }
    if (_items.isEmpty) provider = null;
    notifyListeners();
  }

  void remove(String serviceId) => setQty(serviceId, 0);

  void clear() {
    provider = null;
    _items.clear();
    notifyListeners();
  }
}

/// Data carried through the booking-flow screens (cart → address → schedule
/// → review → payment → confirmation).
class BookingDraft {
  final ProviderProfile provider;
  final List<BookingLineItem> items;
  final Totals totals;
  final Address address;
  final DateTime scheduledAt;
  final String notes;

  const BookingDraft({
    required this.provider,
    required this.items,
    required this.totals,
    required this.address,
    required this.scheduledAt,
    this.notes = '',
  });
}

/// Root app state: repositories, signed-in user, locale, cart, recent searches.
class AppState extends ChangeNotifier {
  final DemoRepositories repos = DemoRepositories();
  final CartState cart = CartState();

  AppUser? user;
  Locale locale = const Locale('en');
  bool languageChosen = false;
  bool onboardingSeen = false;

  /// Notification preference is in-memory only for now.
  /// TODO(firebase): persist per-user in Firestore once backend is live.
  bool notificationsEnabled = true;

  final List<String> _recentSearches = [];

  AppState() {
    // Rebuild consumers when the cart changes.
    cart.addListener(notifyListeners);
  }

  bool get isLoggedIn => user != null;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  void setUser(AppUser? u) {
    user = u;
    notifyListeners();
  }

  void setLocale(Locale l) {
    locale = l;
    notifyListeners();
  }

  void completeLanguage() {
    languageChosen = true;
    notifyListeners();
  }

  void completeOnboarding() {
    onboardingSeen = true;
    notifyListeners();
  }

  void setNotificationsEnabled(bool v) {
    notificationsEnabled = v;
    notifyListeners();
  }

  void addRecentSearch(String q) {
    final query = q.trim();
    if (query.isEmpty) return;
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 8) {
      _recentSearches.removeRange(8, _recentSearches.length);
    }
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  /// Adds a service to the cart, enforcing the single-provider rule.
  /// Returns true when the item was added.
  Future<bool> addToCart(
    BuildContext context,
    ProviderProfile provider,
    ProviderService service,
  ) async {
    if (!cart.isEmpty &&
        cart.provider != null &&
        cart.provider!.id != provider.id) {
      final clear = await fxConfirm(
        context,
        title: 'Start a new cart?',
        message: 'Your cart has services from ${cart.provider!.businessName}. '
            'Adding from ${provider.businessName} will clear the current cart.',
        confirmLabel: 'Clear & add',
      );
      if (!clear) return false;
      cart.clear();
    }
    cart.setProvider(provider);
    cart.add(service);
    return true;
  }

  Future<void> signOut() async {
    await repos.auth.signOut();
    user = null;
    cart.clear();
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await repos.auth.deleteAccount();
    user = null;
    cart.clear();
    notifyListeners();
  }
}
