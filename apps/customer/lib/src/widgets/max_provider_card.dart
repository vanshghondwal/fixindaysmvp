/// Shared maximalist provider card used across home, search and lists.
///
/// Bold, colorful, dense — avatar on tinted bg, rating pill, price pill.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';

class MaxProviderCard extends StatelessWidget {
  final ProviderProfile provider;
  final int? priceFromPaise;
  final VoidCallback? onTap;
  final int colorIndex;

  const MaxProviderCard({
    super.key,
    required this.provider,
    this.priceFromPaise,
    this.onTap,
    this.colorIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    final (bg, fg) = MaxColors.pairFor(colorIndex);
    final initial = provider.businessName.isEmpty
        ? '?'
        : provider.businessName.trim()[0].toUpperCase();

    return MaxCard(
      onTap: onTap,
      shadowColor: fg,
      child: Row(
        children: [
          // Colorful avatar chip
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: fg,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        provider.businessName,
                        style: MaxText.title.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (provider.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified,
                          color: MaxColors.sky, size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Rating pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: MaxColors.sunSoft,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFB8860B), size: 12),
                          const SizedBox(width: 3),
                          Text(
                            provider.ratingCount > 0
                                ? '${provider.ratingAvg.toStringAsFixed(1)} (${provider.ratingCount})'
                                : 'New',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB8860B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Price pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: MaxColors.mintSoft,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        priceFromPaise != null
                            ? '${formatInr(priceFromPaise!)} ${t.t('onwards')}'
                            : t.t('priceOnRequest'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E9E50),
                        ),
                      ),
                    ),
                  ],
                ),
                if (provider.serviceAreas.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: MaxColors.inkFaint),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          provider.serviceAreas.take(2).join(' · '),
                          style: MaxText.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: MaxColors.heroGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: maxShadow(MaxColors.orange, blur: 10),
            ),
            child: const Icon(Icons.arrow_forward,
                color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
