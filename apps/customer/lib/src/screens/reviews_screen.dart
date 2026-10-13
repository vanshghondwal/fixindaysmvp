/// Full review list for a provider, plus a write-a-review form when the
/// given booking is eligible (completed, owned, not yet reviewed).
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class ReviewsScreen extends StatefulWidget {
  final String providerId;
  final Booking? booking;

  const ReviewsScreen({
    super.key,
    required this.providerId,
    this.booking,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late Future<List<Review>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Review>> _load() => context
      .read<AppState>()
      .repos
      .catalog
      .providerReviews(widget.providerId);

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('reviews'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          if (widget.booking != null)
            _ReviewForm(booking: widget.booking!),
          Expanded(
            child: FutureBuilder<List<Review>>(
              future: _future,
              builder: (_, snap) {
                if (snap.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
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
                final reviews = snap.data ?? [];
                if (reviews.isEmpty) {
                  return const EmptyState(
                    icon: Icons.rate_review_outlined,
                    title: 'No reviews yet',
                    message:
                        'Be the first to review after a completed service.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(FxSpacing.md),
                  itemCount: reviews.length,
                  itemBuilder: (_, i) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: 8),
                    child: ReviewCard(review: reviews[i]),
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

class _ReviewForm extends StatefulWidget {
  final Booking booking;

  const _ReviewForm({required this.booking});

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  late Future<bool> _eligibleFuture;
  int _rating = 5;
  final _textCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _eligibleFuture = _checkEligible();
  }

  Future<bool> _checkEligible() async {
    final app = context.read<AppState>();
    final already =
        await app.repos.bookings.hasReviewed(widget.booking.id);
    return isReviewEligible(
      booking: widget.booking,
      customerId: app.user!.id,
      alreadyReviewed: already,
    );
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ratingError = validateRating(_rating);
    if (ratingError != null) {
      setState(() => _error = ratingError);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final app = context.read<AppState>();
      await app.repos.bookings.submitReview(
        bookingId: widget.booking.id,
        customerId: app.user!.id,
        rating: _rating,
        text: _textCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks for your review!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return FutureBuilder<bool>(
      future: _eligibleFuture,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(FxSpacing.md),
            child: FxSkeleton(height: 120),
          );
        }
        if (snap.hasError || snap.data != true) {
          return Container(
            margin: const EdgeInsets.all(FxSpacing.md),
            padding: const EdgeInsets.all(FxSpacing.md),
            decoration: BoxDecoration(
              color: FxColors.background,
              border: Border.all(color: FxColors.borders),
              borderRadius:
                  const BorderRadius.circular(FxRadius.md),
            ),
            child: const Text(
              'Only completed bookings that you haven\'t reviewed yet '
              'can be reviewed.',
              style: FxText.caption,
            ),
          );
        }
        return FxCard(
          padding: const EdgeInsets.all(FxSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.t('writeReview'), style: FxText.title),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return IconButton(
                    icon: Icon(
                      star <= _rating
                          ? Icons.star
                          : Icons.star_border,
                      color: FxColors.star,
                      size: 32,
                    ),
                    onPressed: () =>
                        setState(() => _rating = star),
                  );
                }),
              ),
              FxTextField(
                controller: _textCtrl,
                label: 'Your review (optional)',
                hint: 'How was the service?',
                maxLines: 3,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style:
                        const TextStyle(color: FxColors.error)),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FxButton(
                  label: t.t('submit'),
                  loading: _submitting,
                  onPressed:
                      _submitting ? null : _submit,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
