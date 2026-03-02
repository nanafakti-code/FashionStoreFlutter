import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../routes/app_router.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_typography.dart';
import '../../utils/responsive_helper.dart';

class CustomFashionAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  final bool showCart;
  final bool showBackButton;
  final String? title;
  final VoidCallback? onBack;

  const CustomFashionAppBar({
    super.key,
    this.showCart = true,
    this.showBackButton = false,
    this.title,
    this.onBack,
  });

  @override
  Size get preferredSize =>
      const Size.fromHeight(115); // Base height, SafeArea will add top padding

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SafeArea(bottom: false, child: _buildTopBar(context)),
        _buildHeader(context, ref),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.charcoal,
      child: Text(
        'Envío gratis en pedidos mayores a 50€',
        textAlign: TextAlign.center,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);
    final isMobile = ResponsiveHelper.isMobile(context);

    // Calculate total items from cart state
    // Calculate total items from cart state
    final totalItems = cartState.items.fold<int>(
        0, (previousValue, element) => previousValue + element.quantity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.white,
      child: ResponsiveHelper.constrain(
        child: Row(
          children: [
            if (showBackButton)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: onBack ??
                    () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
              ),

            // Logo - smaller on mobile or if back button is present
            if (!isMobile || !showBackButton)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Image.asset(
                  'assets/images/logo1.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.shopping_bag, color: AppColors.primary),
                ),
              ),

            Expanded(
              child: Text(
                title ?? 'FashionStore',
                style: AppTypography.displaySmall.copyWith(
                  fontSize: isMobile ? 20 : 24,
                  fontStyle:
                      title == null ? FontStyle.italic : FontStyle.normal,
                  color: AppColors.charcoal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (showCart)
              Stack(
                children: [
                  IconButton(
                    onPressed: () => context.push(AppRoutes.cart),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    color: AppColors.charcoal,
                  ),
                  if (totalItems > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          totalItems.toString(),
                          textAlign: TextAlign.center,
                          style: AppTypography.badge.copyWith(fontSize: 9),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
