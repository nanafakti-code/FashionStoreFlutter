import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../utils/responsive_helper.dart';
import 'promo_category_card.dart';

/// Data model for a promotional category entry.
class PromoCategory {
  final String title;
  final String imageUrl;
  final VoidCallback? onTap;

  const PromoCategory({
    required this.title,
    required this.imageUrl,
    this.onTap,
  });
}

/// A full promotional section — BackMarket "Compra los más buscados" style.
///
/// Responsive grid:
///   Mobile  (<600)  → 1 column
///   Tablet  (600–1024) → 2 columns
///   Desktop (>1024) → 3 columns
class PromoSection extends StatelessWidget {
  final String title;
  final List<PromoCategory> categories;
  final double cardHeight;

  const PromoSection({
    super.key,
    this.title = 'Compra los "más buscados"',
    required this.categories,
    this.cardHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    final columns = isMobile ? 2 : (isTablet ? 2 : 4);
    final spacing = isMobile ? 12.0 : 16.0;

    return ResponsiveHelper.constrain(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              title,
              style: (isMobile
                      ? AppTypography.headlineMedium
                      : AppTypography.displaySmall)
                  .copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Responsive grid of promo cards
            _buildGrid(columns, spacing),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(int columns, double spacing) {
    final rows = <Widget>[];

    for (var i = 0; i < categories.length; i += columns) {
      final rowItems = <Widget>[];
      for (var j = 0; j < columns; j++) {
        final idx = i + j;
        if (idx < categories.length) {
          rowItems.add(
            Expanded(
              child: PromoCategoryCard(
                title: categories[idx].title,
                imageUrl: categories[idx].imageUrl,
                onTap: categories[idx].onTap,
                height: cardHeight,
              ),
            ),
          );
        } else {
          // Empty spacer to fill the row evenly
          rowItems.add(const Expanded(child: SizedBox.shrink()));
        }
        // Add spacing between columns (not after the last)
        if (j < columns - 1) {
          rowItems.add(SizedBox(width: spacing));
        }
      }
      rows.add(Row(children: rowItems));
      // Add vertical spacing between rows (not after the last)
      if (i + columns < categories.length) {
        rows.add(SizedBox(height: spacing));
      }
    }

    return Column(children: rows);
  }
}
