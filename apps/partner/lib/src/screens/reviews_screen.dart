/// Reviews: rating summary + customer review cards.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    final state = context.watch<PartnerState>();
    final profile = state.profile;
    final reviews = state.ops.demoReviews;

    return Scaffold(
      appBar: AppBar(title: Text(t.t('reviews'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: reviews.isEmpty
                ? const EmptyState(
                    icon: Icons.star_outline,
                    title: 'No reviews yet',
                    message:
                        'Customer reviews for your completed jobs will appear here.',
                  )
                : ListView(
                    padding: const EdgeInsets.all(FxSpacing.lg),
                    children: [
                      FxCard(
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  (profile?.ratingAvg ?? 0)
                                      .toStringAsFixed(1),
                                  style: FxText.headline.copyWith(
                                      fontSize: 36),
                                ),
                                RatingStars(
                                    rating:
                                        profile?.ratingAvg ?? 0,
                                    size: 18),
                                const SizedBox(height: 4),
                                Text(
                                  '${profile?.ratingCount ?? 0} reviews (demo)',
                                  style: FxText.caption,
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Ratings come from customers after completed '
                                'jobs. The summary above is demo data.',
                                style: FxText.caption,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...reviews.map((r) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: FxSpacing.sm),
                            child: ReviewCard(review: r),
                          )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
