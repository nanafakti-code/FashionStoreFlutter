import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../../config/theme/app_colors.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    // Load wishlist on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref.read(wishlistNotifierProvider.notifier).loadWishlist(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlistState = ref.watch(wishlistNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: Builder(
        builder: (context) {
          if (wishlistState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // Empty state
          if (wishlistState.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: AppColors.grey400),
                  const SizedBox(height: 16),
                  Text('No tienes favoritos aún',
                      style: TextStyle(fontSize: 18, color: AppColors.grey600)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.goNamed(AppRoutes.products),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: const Text('Explorar Productos',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              if (user != null) {
                await ref
                    .read(wishlistNotifierProvider.notifier)
                    .loadWishlist(user.id);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wishlistState.items.length,
              itemBuilder: (_, i) {
                final prod = wishlistState.items[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => context.pushNamed(
                      AppRoutes.productDetail,
                      pathParameters: {'id': prod.id},
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: prod.imagenPrincipal != null
                                  ? CachedNetworkImage(
                                      imageUrl: prod.imagenPrincipal!,
                                      fit: BoxFit.cover)
                                  : Container(
                                      color: AppColors.greyLight,
                                      child: const Icon(Icons.image)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(prod.nombre,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text(
                                    '${prod.precioEnEuros.toStringAsFixed(2)}€',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.shopping_cart,
                                    color: AppColors.primary),
                                onPressed: () {
                                  ref
                                      .read(cartNotifierProvider.notifier)
                                      .addItem(
                                        productId: prod.id,
                                        productName: prod.nombre,
                                        price:
                                            (prod.precioEnEuros * 100).round(),
                                        image: prod.imagenPrincipal,
                                        maxStock: prod.stockTotal,
                                        quantity: 1,
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${prod.nombre} añadido al carrito'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () {
                                  if (user != null) {
                                    ref
                                        .read(wishlistNotifierProvider.notifier)
                                        .removeItem(user.id, prod.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
