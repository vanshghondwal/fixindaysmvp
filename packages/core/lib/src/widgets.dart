/// Reusable FixinDays design-system widgets shared by all apps.
///
/// Solid brand colours only — no gradients anywhere.
library;

import 'package:flutter/material.dart';

import 'logic.dart';
import 'models.dart';
import 'theme.dart';

// ---------------------------------------------------------------------------
// Buttons
// ---------------------------------------------------------------------------

enum FxButtonKind { primary, secondary, outlined, destructive }

class FxButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final FxButtonKind kind;
  final bool loading;
  final IconData? icon;

  const FxButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = FxButtonKind.primary,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: FxColors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );
    final onTap = loading ? null : onPressed;
    switch (kind) {
      case FxButtonKind.primary:
        return ElevatedButton(onPressed: onTap, child: child);
      case FxButtonKind.secondary:
        return ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: FxColors.navy,
            foregroundColor: FxColors.white,
          ),
          child: child,
        );
      case FxButtonKind.outlined:
        return OutlinedButton(onPressed: onTap, child: child);
      case FxButtonKind.destructive:
        return ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: FxColors.error,
            foregroundColor: FxColors.white,
          ),
          child: child,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------

class FxTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final bool obscure;
  final int maxLines;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const FxTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.maxLines = 1,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FxText.subtitle),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Cards & headers
// ---------------------------------------------------------------------------

class FxCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const FxCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(FxSpacing.md),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: EdgeInsets.zero,
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(FxRadius.lg),
      onTap: onTap,
      child: card,
    );
  }
}

class FxSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const FxSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: FxText.title),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.name,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(FxRadius.lg),
      onTap: onTap,
      child: FxCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: FxColors.primary),
            const SizedBox(height: 8),
            Text(name,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// Resolves the icon key stored in [ServiceCategory] to a Material icon.
IconData categoryIcon(String key) {
  switch (key) {
    case 'plumbing':
      return Icons.plumbing;
    case 'bolt':
      return Icons.bolt;
    case 'cleaning_services':
      return Icons.cleaning_services;
    case 'ac_unit':
      return Icons.ac_unit;
    case 'format_paint':
      return Icons.format_paint;
    case 'handyman':
      return Icons.handyman;
    default:
      return Icons.home_repair_service;
  }
}

// ---------------------------------------------------------------------------
// Provider card
// ---------------------------------------------------------------------------

class ProviderCard extends StatelessWidget {
  final ProviderProfile provider;
  final int? priceFromPaise;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  const ProviderCard({
    super.key,
    required this.provider,
    this.priceFromPaise,
    this.onTap,
    this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return FxCard(
      onTap: onTap,
      padding: const EdgeInsets.all(FxSpacing.md),
      child: Row(
        children: [
          FxAvatar(name: provider.businessName, radius: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(provider.businessName,
                          style: FxText.subtitle,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 4),
                    VerifiedBadge(verified: provider.isVerified),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RatingStars(rating: provider.ratingAvg, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      provider.ratingCount > 0
                          ? '${provider.ratingAvg.toStringAsFixed(1)} (${provider.ratingCount})'
                          : 'No ratings yet',
                      style: FxText.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  priceFromPaise != null
                      ? '${formatInr(priceFromPaise!)} onwards'
                      : 'Price on request',
                  style: FxText.price.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          if (onBook != null) ...[
            const SizedBox(width: 8),
            FxButton(label: 'Book', onPressed: onBook),
          ],
        ],
      ),
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  final bool verified;
  const VerifiedBadge({super.key, required this.verified});

  @override
  Widget build(BuildContext context) {
    if (!verified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: FxColors.warning.withOpacity(0.12),
          borderRadius: BorderRadius.circular(FxRadius.sm),
        ),
        child: const Text('Unverified',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: FxColors.warning)),
      );
    }
    return const Icon(Icons.verified, size: 16, color: FxColors.primary);
  }
}

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  const RatingStars({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 0.75;
        final half = !filled && rating >= i + 0.25;
        return Icon(
          filled ? Icons.star : (half ? Icons.star_half : Icons.star_border),
          size: size,
          color: FxColors.star,
        );
      }),
    );
  }
}

class FxAvatar extends StatelessWidget {
  final String name;
  final double radius;
  const FxAvatar({super.key, required this.name, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: FxColors.primary.withOpacity(0.15),
      child: Text(initial,
          style: TextStyle(
              color: FxColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: radius * 0.8)),
    );
  }
}

// ---------------------------------------------------------------------------
// Status chip
// ---------------------------------------------------------------------------

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const StatusChip({super.key, required this.label, required this.color});

  factory StatusChip.booking(BookingStatus s) {
    final map = {
      BookingStatus.pending: FxColors.warning,
      BookingStatus.accepted: FxColors.primary,
      BookingStatus.rejected: FxColors.error,
      BookingStatus.confirmed: FxColors.primary,
      BookingStatus.enRoute: FxColors.navy,
      BookingStatus.arrived: FxColors.navy,
      BookingStatus.inProgress: FxColors.navy,
      BookingStatus.completed: FxColors.darkGreen,
      BookingStatus.cancelled: FxColors.secondaryText,
      BookingStatus.disputed: FxColors.error,
    };
    return StatusChip(label: s.name.toUpperCase(), color: map[s]!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(FxRadius.xl),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ---------------------------------------------------------------------------
// States: loading / empty / error / demo banner
// ---------------------------------------------------------------------------

class FxSkeleton extends StatelessWidget {
  final double height;
  final double? width;
  const FxSkeleton({super.key, this.height = 16, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: FxColors.borders,
        borderRadius: BorderRadius.circular(FxRadius.sm),
      ),
    );
  }
}

class FxLoadingList extends StatelessWidget {
  final int count;
  const FxLoadingList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: FxSkeleton(height: 84),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FxSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: FxColors.borders),
            const SizedBox(height: 12),
            Text(title, style: FxText.title, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(message,
                style: FxText.caption, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FxButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorPanel({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FxSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: FxColors.error),
            const SizedBox(height: 12),
            const Text('Something went wrong', style: FxText.title),
            const SizedBox(height: 6),
            Text(message,
                style: FxText.caption, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FxButton(
                label: 'Retry', onPressed: onRetry, icon: Icons.refresh),
          ],
        ),
      ),
    );
  }
}

/// Banner shown at the top of every screen while demo data is in use.
class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: FxColors.warning.withOpacity(0.15),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: FxColors.warning),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo mode — sample data shown. Connect Firebase for live data.',
              style: TextStyle(fontSize: 12, color: FxColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dialogs & misc
// ---------------------------------------------------------------------------

Future<bool> fxConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FxButton(
          label: confirmLabel,
          kind: destructive ? FxButtonKind.destructive : FxButtonKind.primary,
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
    ),
  );
  return result ?? false;
}

class ReviewCard extends StatelessWidget {
  final Review review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FxAvatar(name: review.customerName, radius: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(review.customerName, style: FxText.subtitle),
              ),
              RatingStars(rating: review.rating.toDouble(), size: 14),
            ],
          ),
          if (review.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.text, style: FxText.body),
          ],
        ],
      ),
    );
  }
}

class LineItemRow extends StatelessWidget {
  final BookingLineItem item;
  final VoidCallback? onRemove;

  const LineItemRow({super.key, required this.item, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.serviceName, style: FxText.subtitle),
                Text(
                  'Qty ${item.quantity} × ${formatInr(item.unitPricePaise)}',
                  style: FxText.caption,
                ),
              ],
            ),
          ),
          Text(formatInr(item.lineTotalPaise), style: FxText.price),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: FxColors.error),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
