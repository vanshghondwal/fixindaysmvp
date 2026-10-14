/// Customer offers — coupons and promotional offers.
///
/// Mock data only; in production these come from Firestore/remote config.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const offers = [
      _Offer(
        code: 'FIX50',
        title: 'Flat ₹50 off',
        description: 'On your first booking above ₹299',
        gradient: MaxColors.heroGradient,
        colorIndex: 0,
      ),
      _Offer(
        code: 'CLEAN20',
        title: '20% off cleaning',
        description: 'Deep home cleaning, up to ₹400 off',
        gradient: MaxColors.oceanGradient,
        colorIndex: 3,
      ),
      _Offer(
        code: 'SPARK15',
        title: '15% off electrical',
        description: 'All electrical services, up to ₹250 off',
        gradient: MaxColors.sunsetGradient,
        colorIndex: 4,
      ),
      _Offer(
        code: 'REFER100',
        title: '₹100 referral bonus',
        description: 'Invite a friend, both get ₹100 credit',
        gradient: MaxColors.mintGradient,
        colorIndex: 2,
      ),
    ];

    return MaxScaffold(
      appBar: AppBar(
        backgroundColor: MaxColors.cream,
        foregroundColor: MaxColors.ink,
        elevation: 0,
        title: const Text('Offers', style: MaxText.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: offers.length,
              itemBuilder: (_, i) {
                final o = offers[i];
                final (bg, fg) = MaxColors.pairFor(o.colorIndex);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: o.gradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: maxShadow(fg),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(o.title,
                                        style: MaxText.onGradientBig
                                            .copyWith(fontSize: 20)),
                                    const SizedBox(height: 4),
                                    Text(o.description,
                                        style: MaxText.onGradient
                                            .copyWith(fontSize: 13)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.25),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  o.code,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Code ${o.code} copied! Apply it at checkout.'),
                                        behavior:
                                            SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                        color: Colors.white, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: const Text('Copy code',
                                      style: TextStyle(
                                          fontWeight:
                                              FontWeight.w800)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${o.code} will be applied to your next booking'),
                                        behavior:
                                            SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: bg == MaxColors.orangeSoft
                                        ? MaxColors.orangeDeep
                                        : fg,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: const Text('Apply',
                                      style: TextStyle(
                                          fontWeight:
                                              FontWeight.w800)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

class _Offer {
  final String code;
  final String title;
  final String description;
  final Gradient gradient;
  final int colorIndex;

  const _Offer({
    required this.code,
    required this.title,
    required this.description,
    required this.gradient,
    required this.colorIndex,
  });
}
