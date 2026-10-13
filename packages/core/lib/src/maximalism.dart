import 'package:flutter/material.dart';

/// FixinDays MAXIMALISM design system.
///
/// Bold, vibrant, dense, playful — inspired by modern fintech maximalism:
/// warm cream backgrounds, gradient hero cards, colorful category chips,
/// big bold numbers, soft colored shadows. Every screen should feel alive.
class MaxColors {
  MaxColors._();

  // ---- Backgrounds ----
  static const cream = Color(0xFFFFF9F0);
  static const creamDeep = Color(0xFFFFF1DC);
  static const cardWhite = Color(0xFFFFFFFF);

  // ---- Primary (warm orange, the brand pop) ----
  static const orange = Color(0xFFFF6B35);
  static const orangeDeep = Color(0xFFE85D2A);
  static const orangeSoft = Color(0xFFFFE9DC);

  // ---- Accent rainbow ----
  static const sun = Color(0xFFFFC93C);
  static const sunSoft = Color(0xFFFFF4D6);
  static const coral = Color(0xFFFF4757);
  static const coralSoft = Color(0xFFFFE2E5);
  static const mint = Color(0xFF2ED573);
  static const mintSoft = Color(0xFFDCF7E5);
  static const sky = Color(0xFF45AAF2);
  static const skySoft = Color(0xFFDFF1FD);
  static const purple = Color(0xFFA55EEA);
  static const purpleSoft = Color(0xFFF0E2FD);
  static const pink = Color(0xFFFD79A8);
  static const pinkSoft = Color(0xFFFFE3EF);
  static const teal = Color(0xFF00CEC9);
  static const tealSoft = Color(0xFFD8F8F7);

  // ---- Ink ----
  static const ink = Color(0xFF2D3142);
  static const inkSoft = Color(0xFF6B7086);
  static const inkFaint = Color(0xFFA7ACBE);
  static const line = Color(0xFFF0E6D6);

  // ---- Category color rotation (bg, fg) ----
  static const categoryPairs = <(Color bg, Color fg)>[
    (orangeSoft, orange),
    (sunSoft, Color(0xFFB8860B)),
    (mintSoft, Color(0xFF1E9E50)),
    (skySoft, Color(0xFF1B7FC1)),
    (purpleSoft, purple),
    (pinkSoft, pink),
    (coralSoft, coral),
    (tealSoft, Color(0xFF00968F)),
  ];

  // ---- Signature gradients ----
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8A3D), Color(0xFFFFC93C)],
  );
  static const sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B81), Color(0xFFFFA26B)],
  );
  static const oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF45AAF2), Color(0xFF7B7BF5)],
  );
  static const mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2ED573), Color(0xFF00CEC9)],
  );
  static const grapeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA55EEA), Color(0xFFFD79A8)],
  );
  static const inkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A3F5C), Color(0xFF23263A)],
  );

  /// Pick a (bg, fg) pair for index i, rotating through the palette.
  static (Color bg, Color fg) pairFor(int i) =>
      categoryPairs[i % categoryPairs.length];
}

/// Maximalism text styles — big, bold, confident.
class MaxText {
  MaxText._();

  static const display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: MaxColors.ink,
    letterSpacing: -0.5,
  );
  static const headline = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: MaxColors.ink,
    letterSpacing: -0.3,
  );
  static const title = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: MaxColors.ink,
  );
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: MaxColors.inkSoft,
  );
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: MaxColors.inkFaint,
  );
  static const bigNumber = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: MaxColors.ink,
    letterSpacing: -0.8,
  );
  static const onGradient = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static const onGradientBig = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: -0.5,
  );
}

/// A soft, colorful shadow for maximalist cards.
List<BoxShadow> maxShadow(Color color, {double blur = 18}) => [
      BoxShadow(
        color: color.withValues(alpha: 0.14),
        blurRadius: blur,
        offset: const Offset(0, 8),
      ),
    ];

/// The signature maximalist card — white, 24px radius, soft tinted shadow.
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: maxShadow(shadowColor ?? MaxColors.orange),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: card,
    );
  }
}

/// Gradient hero card — the bold statement piece on every screen.
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: maxShadow(MaxColors.orangeDeep, blur: 24),
      ),
      child: child,
    );
  }
}

/// Colorful category tile — icon chip on tinted bg + label.
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
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: maxShadow(fg, blur: 12),
            ),
            child: Icon(icon, color: fg, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: MaxColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bold section header with optional action link.
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
                foregroundColor: MaxColors.orange,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
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
    this.accent = MaxColors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: MaxText.bigNumber.copyWith(color: accent, fontSize: 24)),
        const SizedBox(height: 2),
        Text(label, style: MaxText.caption),
      ],
    );
  }
}

/// Pill badge — tiny colorful label.
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
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

/// Maximalist primary button — bold orange, chunky radius.
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
    this.gradient = MaxColors.heroGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
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
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
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

/// Maximalist scaffold — cream background, ready for dense content.
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
