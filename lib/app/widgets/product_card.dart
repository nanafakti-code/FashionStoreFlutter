import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/models/producto_model.dart';
import '../providers/cart_provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_typography.dart';
import '../../utils/responsive_helper.dart';

/// Compact, professional product card — Amazon / Apple style.
///
/// Uses [LayoutBuilder] to adapt content based on available space.
/// Image background is pure white, images use [BoxFit.contain].
class ProductCard extends ConsumerStatefulWidget {
  final ProductoModel producto;
  final bool showAddToCart;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.producto,
    this.showAddToCart = true,
    this.onTap,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap ??
            () => context.push('/product/${widget.producto.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform:
              _hovered ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: _hovered ? 4 : 0.5,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              side: BorderSide(
                color: _hovered
                    ? AppColors.primary.withOpacity(0.25)
                    : AppColors.border,
                width: _hovered ? 1.0 : 0.5,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Dynamically split between image and info based on available height
                final totalH = constraints.maxHeight;
                final imageH = totalH *
                    0.62; // Increased from 0.58 to reduce info whitespace
                final infoH = totalH - imageH; // 38% for info

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: imageH,
                      child: _buildImage(),
                    ),
                    SizedBox(
                      height: infoH,
                      child: _buildInfo(context, infoH),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Pure white background + contained image
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.all(2), // Reduced from 6 to 2
          child: widget.producto.imagenPrincipal != null
              ? CachedNetworkImage(
                  imageUrl: widget.producto.imagenPrincipal!,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.grey400,
                    size: 24,
                  ),
                )
              : const Icon(
                  Icons.image_outlined,
                  size: 24,
                  color: AppColors.grey400,
                ),
        ),

        // Discount badge
        if (widget.producto.enOferta)
          Positioned(
            top: 4, // Reduced from 5
            left: 4, // Reduced from 5
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 4, vertical: 2), // Slightly tighter
              decoration: BoxDecoration(
                color: AppColors.badgeSale,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-${widget.producto.descuento}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

        // Out of stock overlay
        if (!widget.producto.tieneStock)
          Positioned.fill(
            child: Container(
              color: Colors.black38,
              child: const Center(
                child: Text(
                  'AGOTADO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context, double availableH) {
    final isMobile = ResponsiveHelper.isMobile(context);
    // Scale font sizes based on available height
    final scale = (availableH / 120).clamp(0.7, 1.0);
    final catFs = (isMobile ? 8.0 : 7.5) * scale;
    final nameFs = (isMobile ? 11.0 : 10.0) * scale;
    final priceFs = (isMobile ? 13.0 : 11.0) * scale;
    final btnH = ((isMobile ? 24.0 : 22.0) * scale).clamp(18.0, 26.0);
    final btnFs = (isMobile ? 10.0 : 9.0) * scale;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 6, // Reduced from 8
        vertical: (2 * scale).clamp(1, 4), // Reduced from 4->2
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top: category + name
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category
                if (widget.producto.categoria != null)
                  Text(
                    widget.producto.categoria!.nombre.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: catFs,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                      letterSpacing: 0.5,
                    ),
                  ),
                SizedBox(height: 0.5 * scale), // Reduced from 1
                // Product name
                Flexible(
                  child: Text(
                    widget.producto.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: nameFs,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                      height: 1.1, // Tighter line height
                    ),
                  ),
                ),
                SizedBox(height: 1 * scale), // Reduced from 2
                // Stock display
                Text(
                  'Stock: ${widget.producto.stockTotal}',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: (catFs * 0.9),
                    fontWeight: FontWeight.w500,
                    color: widget.producto.stockTotal > 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),

          // Bottom: price + button (fixed, never flexible)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price row
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '${widget.producto.precioEnEuros.toStringAsFixed(2)}€',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: priceFs,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (widget.producto.enOferta &&
                      widget.producto.precioOriginalEnEuros != null) ...[
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        '${widget.producto.precioOriginalEnEuros!.toStringAsFixed(2)}€',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: priceFs * 0.75,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Button
              if (widget.showAddToCart) ...[
                SizedBox(height: 1.5 * scale), // Reduced from 3
                SizedBox(
                  width: double.infinity,
                  height: btnH,
                  child: ElevatedButton(
                    onPressed: widget.producto.tieneStock
                        ? () async {
                            // Pick the first available variant (if any)
                            final variant =
                                widget.producto.variantes?.firstOrNull;
                            final success = await ref
                                .read(cartNotifierProvider.notifier)
                                .addItem(
                                  productId: widget.producto.id,
                                  productName: widget.producto.nombre,
                                  price: widget.producto.precioVenta,
                                  quantity: 1,
                                  image: widget.producto.imagenPrincipal,
                                  talla: variant?.talla,
                                  color: variant?.color,
                                  capacidad: variant?.capacidad,
                                  variantId: variant?.id,
                                  maxStock: variant?.stock ?? widget.producto.stockTotal,
                                );

                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${widget.producto.nombre} añadido al carrito',
                                  ),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: AppColors.charcoal,
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.grey300,
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                size: btnFs + 1, color: AppColors.white),
                            const SizedBox(width: 2),
                            Text(
                              'Añadir',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: btnFs,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
