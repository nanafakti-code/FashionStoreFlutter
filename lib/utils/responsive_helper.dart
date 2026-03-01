import 'package:flutter/material.dart';

/// Responsive breakpoints and layout helpers for FashionStore.
///
/// Breakpoints:
///   Mobile:  width < 600
///   Tablet:  600 ≤ width ≤ 1024
///   Desktop: width > 1024
class ResponsiveHelper {
  ResponsiveHelper._();

  // ─── Breakpoint thresholds ───
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double wideDesktopBreakpoint = 1440;
  static const double maxContentWidth = 1400;

  // ─── Screen-size queries ───

  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isMobile(BuildContext context) =>
      getWidth(context) < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = getWidth(context);
    return w >= mobileBreakpoint && w <= tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      getWidth(context) > tabletBreakpoint;

  // ─── Grid helpers ───

  /// Number of product-card columns.
  static int getGridCrossAxisCount(BuildContext context) {
    final width = getWidth(context);
    if (width < mobileBreakpoint) return 2;
    if (width <= tabletBreakpoint) return 3;
    if (width < wideDesktopBreakpoint) return 4;
    return 5;
  }

  /// Child aspect ratio for the product grid.
  /// Higher = wider/shorter cards. Lower = taller cards.
  ///
  /// With the compact card layout (flex 3:2), these values
  /// give visually balanced cards at each breakpoint:
  ///  - Mobile: 0.65 (comfortable readability)
  ///  - Tablet: 0.62
  ///  - Desktop: 0.70 (compact, Amazon-style)
  static double getChildAspectRatio(BuildContext context) {
    if (isMobile(context)) return 0.65;
    if (isTablet(context)) return 0.62;
    return 0.70;
  }

  // ─── Spacing helpers ───

  /// General padding around sections.
  static double getPadding(BuildContext context) {
    if (isMobile(context)) return 12;
    if (isTablet(context)) return 16;
    return 24;
  }

  /// Spacing between grid items.
  static double getGridSpacing(BuildContext context) {
    if (isMobile(context)) return 8;
    if (isTablet(context)) return 12;
    return 16;
  }

  // ─── Layout helpers ───

  static double getResponsiveWidth(BuildContext context, double pct) =>
      getWidth(context) * (pct / 100);

  static double getResponsiveHeight(BuildContext context, double pct) =>
      getHeight(context) * (pct / 100);

  /// Max body width for centering content on wide screens.
  static double getMaxWidth(BuildContext context) {
    final width = getWidth(context);
    if (width < mobileBreakpoint) return width;
    if (width <= tabletBreakpoint) return width * 0.95;
    return maxContentWidth;
  }

  /// Convenience: wrap a child in Center + ConstrainedBox(maxContentWidth).
  static Widget constrain({required Widget child}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );
  }
}
