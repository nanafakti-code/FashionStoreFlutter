import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/product_detail_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../../config/theme/app_colors.dart';
import '../../data/models/producto_model.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).user;
      ref
          .read(productDetailNotifierProvider.notifier)
          .loadProduct(widget.productId, userId: user?.id);
    });
  }

  @override
  void didUpdateWidget(covariant ProductDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final user = ref.read(authNotifierProvider).user;
        ref
            .read(productDetailNotifierProvider.notifier)
            .loadProduct(widget.productId, userId: user?.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailNotifierProvider);

    return Scaffold(
      appBar: const CustomFashionAppBar(
        title: 'Detalle del Producto',
        showBackButton: true,
      ),
      body: Builder(builder: (context) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        }
        if (state.product == null) {
          return const Center(child: Text('Producto no encontrado'));
        }
        return _buildContent(context, state);
      }),
      bottomNavigationBar: Builder(builder: (context) {
        if (state.product == null) return const SizedBox.shrink();
        return _buildBottomBar(context, state);
      }),
    );
  }

  Widget _buildContent(BuildContext context, ProductDetailState state) {
    final isWide = MediaQuery.of(context).size.width > 800;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildImageGallery(context, state)),
          Expanded(
              child: SingleChildScrollView(child: _buildInfo(context, state))),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(context, state),
          _buildInfo(context, state),
          if (state.reviews.isNotEmpty) _buildReviewsSection(context, state),
          if (state.relatedProducts.isNotEmpty)
            _buildRelatedSection(context, state),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context, ProductDetailState state) {
    // Images are either from selecting variant (if variant has image) or product images
    // The previous logic showed variant image if selected.
    List<String> images = state.product?.imagenes ?? [];
    if (state.selectedVariant?.imagenUrl != null) {
      images = [state.selectedVariant!.imagenUrl!];
    }
    if (images.isEmpty && state.product?.imagenPrincipal != null) {
      images = [state.product!.imagenPrincipal!];
    }

    if (images.isEmpty) {
      return Container(
        height: 400,
        color: AppColors.greyLight,
        child: const Center(
            child: Icon(Icons.image, size: 80, color: Colors.grey)),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) =>
                ref.read(productDetailNotifierProvider.notifier).selectImage(i),
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: images[i],
              fit: BoxFit.contain,
              placeholder: (_, __) => Container(color: AppColors.greyLight),
              errorWidget: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image)),
            ),
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: state.selectedImageIndex == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: state.selectedImageIndex == i
                        ? AppColors.primary
                        : AppColors.greyLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context, ProductDetailState state) {
    final p = state.product!;
    final notifier = ref.read(productDetailNotifierProvider.notifier);

    // Calculate rating
    double averageRating = 0;
    if (state.reviews.isNotEmpty) {
      averageRating =
          state.reviews.map((r) => r.calificacion).reduce((a, b) => a + b) /
              state.reviews.length;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categoría
          if (p.categoria != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(p.categoria!.nombre,
                  style: const TextStyle(fontSize: 12, color: AppColors.navy)),
            ),
          const SizedBox(height: 8),
          // Nombre
          Text(p.nombre,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  )),
          const SizedBox(height: 8),
          // Rating
          Row(
            children: [
              ...List.generate(
                  5,
                  (i) => Icon(
                        i < averageRating.round()
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.gold,
                        size: 20,
                      )),
              const SizedBox(width: 8),
              Text(
                  '${averageRating.toStringAsFixed(1)} (${state.reviews.length} reseñas)',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          // Precio
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text('${state.precioMostrado.toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    )),
              ),
              if (state.precioOriginalMostrado != null &&
                  state.precioOriginalMostrado! > state.precioMostrado) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                      '${state.precioOriginalMostrado!.toStringAsFixed(2)}€',
                      style: const TextStyle(
                        fontSize: 18,
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textSecondary,
                      )),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('-${state.descuentoMostrado}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ]
            ],
          ),
          const SizedBox(height: 16),
          // Stock
          Row(
            children: [
              Builder(builder: (context) {
                final stock = state.stockMostrado;
                final hasStock = stock > 0;
                return Row(
                  children: [
                    Icon(
                      hasStock ? Icons.check_circle : Icons.cancel,
                      color: hasStock ? AppColors.success : AppColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(hasStock ? 'En stock ($stock)' : 'Agotado',
                        style: TextStyle(
                          color: hasStock ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          // Descripción
          Text('Descripción',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(p.descripcionLarga ?? p.descripcion ?? 'Sin descripción',
              style:
                  const TextStyle(color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 20),
          // Variantes disponibles
          if (state.tallajesDisponibles.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Talla',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: state.tallajesDisponibles
                      .map((talla) => FilterChip(
                            label: Text(talla),
                            selected: state.selectedTalla == talla,
                            onSelected: (_) => notifier.selectTalla(talla),
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: state.selectedTalla == talla
                                  ? Colors.white
                                  : AppColors.charcoal,
                              fontWeight: FontWeight.w500,
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          if (state.coloresDisponibles.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Color',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: state.coloresDisponibles
                      .map((color) => FilterChip(
                            label: Text(color),
                            selected: state.selectedColor == color,
                            onSelected: (_) => notifier.selectColor(color),
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: state.selectedColor == color
                                  ? Colors.white
                                  : AppColors.charcoal,
                              fontWeight: FontWeight.w500,
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),

          if (state.capacidadesDisponibles.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Almacenamiento',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: state.capacidadesDisponibles
                      .map((cap) => FilterChip(
                            label: Text(cap),
                            selected: state.selectedCapacidad == cap,
                            onSelected: (_) => notifier.selectCapacidad(cap),
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: state.selectedCapacidad == cap
                                  ? Colors.white
                                  : AppColors.charcoal,
                              fontWeight: FontWeight.w500,
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          // Cantidad
          Row(
            children: [
              const Text('Cantidad:',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: notifier.decrementQuantity,
              ),
              Text('${state.quantity}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: notifier.incrementQuantity,
              ),
            ],
          ),
          // Detalles
          const SizedBox(height: 16),
          if (p.material != null || p.color != null || p.genero != null)
            _buildDetails(p),
        ],
      ),
    );
  }

  Widget _buildDetails(ProductoModel p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('Detalles',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (p.material != null) _detailRow('Material', p.material!),
        if (p.color != null) _detailRow('Color', p.color!),
        if (p.genero != null) _detailRow('Género', p.genero!),
        if (p.sku != null) _detailRow('SKU', p.sku!),
        if (p.marca != null) _detailRow('Marca', p.marca!.nombre),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(color: AppColors.textSecondary))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, ProductDetailState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text('Reseñas (${state.reviews.length})',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...state.reviews.take(5).map((r) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ...List.generate(
                              5,
                              (i) => Icon(
                                    i < r.calificacion
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: AppColors.gold,
                                  )),
                          const Spacer(),
                          if (r.verificadaCompra)
                            const Row(
                              children: [
                                Icon(Icons.verified,
                                    size: 14, color: AppColors.success),
                                SizedBox(width: 4),
                                Text('Compra verificada',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.success)),
                              ],
                            ),
                        ],
                      ),
                      if (r.titulo != null) ...[
                        const SizedBox(height: 4),
                        Text(r.titulo!,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                      const SizedBox(height: 4),
                      Text(r.comentario ?? '',
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRelatedSection(BuildContext context, ProductDetailState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text('Productos Relacionados',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.relatedProducts.length,
              itemBuilder: (_, i) {
                final p = state.relatedProducts[i];
                return GestureDetector(
                  onTap: () {
                    // Navigate to same route with new ID
                    context.push('/product/${p.id}');
                  },
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            color: AppColors.greyLight.withOpacity(0.5),
                            padding: const EdgeInsets.all(8),
                            child: p.imagenPrincipal != null
                                ? CachedNetworkImage(
                                    imageUrl: p.imagenPrincipal!,
                                    fit: BoxFit.contain,
                                    placeholder: (_, __) => const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
                                    errorWidget: (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                                  )
                                : const Icon(Icons.image, color: Colors.grey),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.nombre,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12)),
                                Text('${p.precioEnEuros.toStringAsFixed(2)}€',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ProductDetailState state) {
    final p = state.product!;
    final totalPrice = state.precioMostrado * state.quantity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  Text(
                    '${totalPrice.toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: state.stockMostrado > 0
                    ? () async {
                        await ref.read(cartNotifierProvider.notifier).addItem(
                              productId: p.id,
                              productName: p.nombre,
                              price: (state.precioMostrado * 100).round(),
                              quantity: state.quantity,
                              image: state.selectedVariant?.imagenUrl ??
                                  p.imagenPrincipal,
                              talla: state.selectedTalla,
                              color: state.selectedColor,
                              capacidad: state.selectedCapacidad,
                              variantId: state.selectedVariant?.id,
                              maxStock: state.stockMostrado,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Añadido al carrito')),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Añadir al Carrito',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
