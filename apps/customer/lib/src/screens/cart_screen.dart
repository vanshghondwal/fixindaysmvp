/// Cart: single-provider services with quantity steppers and totals.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'address_select_screen.dart';
import 'welcome_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final cart = app.cart;
    final t = FxLocalizations.of(context);

    return VoiceScreenTag(
      screenKey: 'cart',
      child: Scaffold(
      appBar: AppBar(title: Text(t.t('yourCart'))),
      body: cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message:
                  'Browse services and add what you need.',
              actionLabel: 'Browse',
              onAction: () => Navigator.of(context).pop(),
            )
          : Column(
              children: [
                if (AppConfig.useDemoData) const DemoBanner(),
                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsets.all(FxSpacing.md),
                    children: [
                      FxCard(
                        child: Row(
                          children: [
                            FxAvatar(
                                name: cart.provider!
                                    .businessName,
                                radius: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      cart.provider!
                                          .businessName,
                                      style: FxText.subtitle),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'One provider per cart',
                                    style: FxText.caption,
                                  ),
                                ],
                              ),
                            ),
                            VerifiedBadge(
                                verified: cart.provider!
                                    .isVerified),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...cart.items.values
                          .map((i) => _itemRow(context, app, i)),
                      const SizedBox(height: 12),
                      FxCard(
                        child: Column(
                          children: [
                            _totalRow(t.t('subtotal'),
                                cart.totals().subtotalPaise),
                            _totalRow(t.t('platformFee'),
                                cart.totals().platformFeePaise),
                            const Divider(),
                            _totalRow(
                                t.t('total'),
                                cart.totals().totalPaise,
                                bold: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Final amount is confirmed by the provider for '
                        'estimate/quote-based services.',
                        style: FxText.caption,
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(FxSpacing.md),
                    child: SizedBox(
                      width: double.infinity,
                      child: FxButton(
                        label:
                            'Proceed · ${formatInr(cart.totals().totalPaise)}',
                        onPressed: () {
                          if (!app.isLoggedIn) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const WelcomeScreen()),
                            );
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddressSelectScreen(
                                provider: cart.provider!,
                                items: cart.lineItems,
                                totals: cart.totals(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
    ));
  }

  Widget _itemRow(
      BuildContext context, AppState app, CartItem item) {
    final s = item.service;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FxCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(s.name, style: FxText.subtitle),
                  const SizedBox(height: 2),
                  Text(
                    '${formatInr(s.pricePaise)} / ${s.unit}',
                    style: FxText.caption,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _stepperBtn(
                        Icons.remove,
                        () => app.cart
                            .setQty(s.id, item.qty - 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        child: Text('${item.qty}',
                            style: FxText.title),
                      ),
                      _stepperBtn(
                        Icons.add,
                        () => app.cart
                            .setQty(s.id, item.qty + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatInr(item.toLineItem().lineTotalPaise),
                    style: FxText.price),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: FxColors.error),
                  onPressed: () =>
                      app.cart.remove(s.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepperBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FxRadius.sm),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: FxColors.borders),
          borderRadius: BorderRadius.circular(FxRadius.sm),
        ),
        child: Icon(icon, size: 18, color: FxColors.primary),
      ),
    );
  }

  Widget _totalRow(String label, int paise, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: bold ? FxText.title : FxText.body),
          Text(formatInr(paise),
              style: bold
                  ? FxText.price.copyWith(fontSize: 18)
                  : FxText.body),
        ],
      ),
    );
  }
}
