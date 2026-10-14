/// Cart — MAXIMALISM edition: vibrant header, colorful item cards
/// with chunky steppers, bold gradient totals. Cart logic unchanged.
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
      child: MaxScaffold(
      body: cart.isEmpty
          ? Column(
              children: [
                Expanded(
                  child: EmptyState(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Your cart is empty',
                    message:
                        'Browse services and add what you need.',
                    actionLabel: 'Browse',
                    onAction: () =>
                        Navigator.of(context).pop(),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                // ---- Vibrant header ----
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: MaxColors.mintSoft,
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF1E9E50)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(t.t('yourCart'),
                          style: MaxText.headline),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: MaxColors.heroGradient,
                          borderRadius:
                              BorderRadius.circular(99),
                          boxShadow: maxShadow(
                              MaxColors.orange,
                              blur: 10),
                        ),
                        child: Text(
                          '${cart.totalQty} items',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                    children: [
                      // Provider banner
                      MaxCard(
                        shadowColor: MaxColors.purple,
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient:
                                    MaxColors.grapeGradient,
                                borderRadius:
                                    BorderRadius.circular(
                                        16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                cart.provider!.businessName
                                        .isEmpty
                                    ? '?'
                                    : cart.provider!
                                        .businessName[0]
                                        .toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight:
                                        FontWeight.w900,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      cart.provider!
                                          .businessName,
                                      style: MaxText.title
                                          .copyWith(
                                              fontSize:
                                                  15)),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'One provider per cart',
                                    style: MaxText.caption,
                                  ),
                                ],
                              ),
                            ),
                            if (cart
                                .provider!.isVerified)
                              const Icon(Icons.verified,
                                  color: MaxColors.sky,
                                  size: 22),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...cart.items.values.toList().asMap().entries.map(
                          (e) => _itemRow(
                              context, app, e.value,
                              e.key)),
                      const SizedBox(height: 4),
                      // Totals card
                      MaxCard(
                        shadowColor: MaxColors.sun,
                        child: Column(
                          children: [
                            _totalRow(t.t('subtotal'),
                                cart.totals().subtotalPaise),
                            _totalRow(t.t('platformFee'),
                                cart.totals().platformFeePaise),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6),
                              child: Divider(
                                  color: MaxColors.line),
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(t.t('total'),
                                    style: MaxText.title),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8),
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
                                  child: Text(
                                    formatInr(cart
                                        .totals()
                                        .totalPaise),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.w900,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Final amount is confirmed by the provider for '
                        'estimate/quote-based services.',
                        style: MaxText.caption,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: MaxButton(
                        label:
                            'Proceed · ${formatInr(cart.totals().totalPaise)}',
                        icon: Icons.arrow_forward_rounded,
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
      BuildContext context, AppState app, CartItem item, int index) {
    final s = item.service;
    final (bg, fg) = MaxColors.pairFor(index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MaxCard(
        shadowColor: fg,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(s.name,
                      style: MaxText.title
                          .copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius:
                          BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${formatInr(s.pricePaise)} / ${s.unit}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: fg),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _stepperBtn(Icons.remove, fg, bg,
                          () => app.cart.setQty(
                              s.id, item.qty - 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14),
                        child: Text('${item.qty}',
                            style: MaxText.headline
                                .copyWith(fontSize: 18)),
                      ),
                      _stepperBtn(Icons.add, Colors.white,
                          fg,
                          () => app.cart.setQty(
                              s.id, item.qty + 1)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    formatInr(
                        item.toLineItem().lineTotalPaise),
                    style: MaxText.title.copyWith(
                        fontSize: 16,
                        color: MaxColors.orangeDeep)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => app.cart.remove(s.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MaxColors.coralSoft,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Icon(
                        Icons.delete_outline,
                        color: MaxColors.coral,
                        size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepperBtn(
      IconData icon, Color iconColor, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: maxShadow(bg, blur: 8),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }

  Widget _totalRow(String label, int paise) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: MaxText.body),
          Text(formatInr(paise),
              style: MaxText.title.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
