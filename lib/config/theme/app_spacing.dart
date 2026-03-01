import 'package:flutter/material.dart';

/// Centralized spacing constants — matches the Astro layout spacing.
class AppSpacing {
  AppSpacing._();

  // ─── Base unit ───
  static const double unit = 4.0;

  // ─── Fixed spacers ───
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // ─── Radii (border-radius) ───
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;

  // ─── Content constraints ───
  static const double maxContentWidth = 1400.0;

  // ─── Card / component sizes ───
  static const double cardPadding = 10.0;
  static const double sectionPaddingH = 16.0;
  static const double sectionPaddingV = 24.0;
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 32.0;
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 36.0;

  // ─── Convenience EdgeInsets ───
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingAllXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingH24 = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets paddingCard = EdgeInsets.all(cardPadding);
}
