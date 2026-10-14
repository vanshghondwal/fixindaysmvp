import 'package:flutter/material.dart';

/// FixinDays PREMIUM "Trust" design system.
///
/// Professional, trustworthy, refined — built for a home-services business
/// presentation: deep navy primary, warm amber accent, clean off-white
/// backgrounds, muted sophisticated category tones, subtle shadows.
/// Calm confidence instead of playful noise.
class MaxColors {
  MaxColors._();

  // ---- Backgrounds ----
  static const cream = Color(0xFFFAFAF8);
  static const creamDeep = Color(0xFFF0F2F5);
  static const cardWhite = Color(0xFFFFFFFF);

  // ---- Primary (warm amber, the brand accent) ----
  static const orange = Color(0xFFF59E0B);
  static const orangeDeep = Color(0xFFD97706);
  static const orangeSoft = Color(0xFFFEF3E2);

  // ---- Muted professional accents ----
  static const sun = Color(0xFFC9A227);
  static const sunSoft = Color(0xFFFBF3DC);
  static const coral = Color(0xFFC4705A);
  static const coralSoft = Color(0xFFF7E8E2);
  static const mint = Color(0xFF6B8F71);
  static const mintSoft = Color(0xFFE6EFE8);
  static const sky = Color(0xFF5B7FA6);
  static const skySoft = Color(0xFFE5ECF3);
  static const purple = Color(0xFF7E7390);
  static const purpleSoft = Color(0xFFECE8F1);
  static const pink = Color(0xFFB76E79);
  static const pinkSoft = Color(0xFFF5E8EA);
  static const teal = Color(0xFF2F6F6B);
  static const tealSoft = Color(0xFFE0EEED);

  // ---- Ink (deep navy text scale) ----
  static const ink = Color(0xFF1A2B4A);
  static const inkSoft = Color(0xFF4A5A75);
  static const inkFaint = Color(0xFF8A94A8);
  static const line = Color(0xFFE8EAF0);

  // ---- Category color rotation (bg, fg) — muted professional tones ----
  static const categoryPairs = <(Color bg, Color fg)>[
    (orangeSoft, orangeDeep),
    (skySoft, sky),
    (mintSoft, mint),
    (coralSoft, coral),
    (purpleSoft, purple),
    (tealSoft, teal),
    (pinkSoft, pink),
    (sunSoft, Color(0xFF9A7B1A)),
  ];

  // ---- Signature gradients — subtle, sophisticated ----
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2B4A), Color(0xFF2F6F6B)],
  );
  static const sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );
  static const oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2B4A), Color(0xFF5B7FA6)],
  );
  static const mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6B8F71), Color(0xFF2F6F6B)],
  );
  static const grapeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7E7390), Color(0xFFB76E79)],
  );
  static const inkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2B4A), Color(0xFF0F1D33)],
  );

  /// Pick a (bg, fg) pair for index i, rotating through the palette.
  static (Color bg, Color fg) pairFor(int i) =>
      categoryPairs[i % categoryPairs.length];
}

/// Premium text styles — bold but refined, comfortable letter spacing.
class MaxText {
  MaxText._();

  static const display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: MaxColors.ink,
    letterSpacing: 0,
  );
  static const headline = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: MaxColors.ink,
    letterSpacing: 0,
  );
  static const title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: MaxColors.ink,
  );
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: MaxColors.inkSoft,
  );
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: MaxColors.inkFaint,
  );
  static const bigNumber = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: MaxColors.ink,
    letterSpacing: -0.3,
  );
  static const onGradient = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static const onGradientBig = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: -0.2,
  );
}

/// A soft, subtle shadow for premium cards.
List<BoxShadow> maxShadow(Color color, {double blur = 12}) => [
      BoxShadow(
        color: color.withValues(alpha: 0.08),
        blurRadius: blur,
        offset: const Offset(0, 4),
      ),
    ];

/// The signature premium card — white, 16px radius, subtle shadow.
class MaxCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? shadowColor;
  final VoidCallback? onTap;

  const MaxCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.shadowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: MaxColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: maxShadow(shadowColor ?? MaxColors.ink),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: card,
    );
  }
}

/// Gradient hero card — the refined statement piece on every screen.
class MaxHeroCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry padding;

  const MaxHeroCard({
    super.key,
    required this.child,
    this.gradient = MaxColors.heroGradient,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: maxShadow(MaxColors.ink, blur: 16),
      ),
      child: child,
    );
  }
}

/// Professional category tile — icon chip on tinted bg + label.
class MaxCategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int colorIndex;
  final VoidCallback? onTap;

  const MaxCategoryTile({
    super.key,
    required this.icon,
    required this.label,
    required this.colorIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = MaxColors.pairFor(colorIndex);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: maxShadow(fg, blur: 8),
            ),
            child: Icon(icon, color: fg, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MaxColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Refined section header with optional action link.
class MaxSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const MaxSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: MaxText.headline),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: MaxColors.orangeDeep,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

/// A stat block — big number + label, used in rows of 2-3.
class MaxStat extends StatelessWidget {
  final String value;
  final String label;
  final Color accent;

  const MaxStat({
    super.key,
    required this.value,
    required this.label,
    this.accent = MaxColors.orangeDeep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: MaxText.bigNumber.copyWith(color: accent, fontSize: 22)),
        const SizedBox(height: 2),
        Text(label, style: MaxText.caption),
      ],
    );
  }
}

/// Pill badge — tiny refined label.
class MaxPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const MaxPill({super.key, required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

/// Premium primary button — deep amber, refined radius.
class MaxButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient gradient;

  const MaxButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.gradient = MaxColors.sunsetGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: maxShadow(MaxColors.orangeDeep),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Premium scaffold — clean off-white background, ready for content.
class MaxScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color backgroundColor;

  const MaxScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor = MaxColors.cream,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: SafeArea(child: body),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
