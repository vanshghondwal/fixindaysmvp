/// Review moderation: hide/unhide customer reviews.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/admin_state.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late Future<List<Review>> _future;

  @override
  void initState() {
    super.initState();
    _reload(initial: true);
  }

  Future<List<Review>> _fetch() {
    final state = context.read<AdminState>();
    final demo = state.demoRepo;
    if (demo != null) return demo.allReviews();
    return state.firestoreRepo!.recentReviews();
  }

  void _reload({bool initial = false}) {
    final f = _fetch();
    if (initial) {
      _future = f;
    } else {
      setState(() => _future = f);
    }
  }

  Future<void> _toggleHidden(BuildContext context, Review r) async {
    final confirm = await fxConfirm(
      context,
      title: r.hidden ? 'Unhide review?' : 'Hide review?',
      message: r.hidden
          ? 'This review will become visible to customers again.'
          : 'This review will be hidden from customers. The action is logged.',
      confirmLabel: r.hidden ? 'Unhide' : 'Hide',
      destructive: !r.hidden,
    );
    if (!confirm || !mounted) return;
    final state = context.read<AdminState>();
    try {
      await state.repo.moderateReview(r.id, !r.hidden, state.adminId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Review ${r.hidden ? 'unhidden' : 'hidden'}.')));
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const FxLoadingList(count: 4);
        }
        if (snap.hasError) {
          return ErrorPanel(
              message: '${snap.error}', onRetry: () => _reload());
        }
        final reviews = snap.data!;
        if (reviews.isEmpty) {
          return const EmptyState(
            icon: Icons.star_outline,
            title: 'No reviews yet',
            message: 'Customer reviews appear here for moderation.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView.separated(
            padding: const EdgeInsets.all(FxSpacing.lg),
            itemCount: reviews.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: FxSpacing.md),
            itemBuilder: (context, i) {
              final r = reviews[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReviewCard(review: r),
                  Padding(
                    padding: const EdgeInsets.only(top: FxSpacing.sm),
                    child: Row(
                      children: [
                        if (r.hidden)
                          const StatusChip(
                              label: 'HIDDEN', color: FxColors.error),
                        const Spacer(),
                        FxButton(
                          label: r.hidden ? 'Unhide' : 'Hide',
                          kind: r.hidden
                              ? FxButtonKind.primary
                              : FxButtonKind.destructive,
                          icon: r.hidden
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          onPressed: () => _toggleHidden(context, r),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
