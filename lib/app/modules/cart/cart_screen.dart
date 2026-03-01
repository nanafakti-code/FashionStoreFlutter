import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/cart_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/custom_app_bar.dart';
import '../../../config/theme/app_colors.dart';
import '../../../utils/responsive_helper.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartNotifierProvider);
    final notifier = ref.read(cartNotifierProvider.notifier);

    return Scaffold(
      appBar: CustomFashionAppBar(
        title: 'Carrito',
        showBackButton: true,
        showCart: false, // Don't show cart icon in cart screen
        onBack: () => context.pop(),
      ),
      body: Builder(builder: (context) {
        if (state.items.isEmpty) {
          return _buildEmptyCart(context);
        }

        return Column(
          children: [
            Expanded(
              child: _buildCartList(context, state, notifier),
            ),
            _buildCheckoutSection(context, state),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Tu carrito está vacío',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega productos para comenzar tu compra',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push(AppRoutes.products),
            child: const Text('Ir a Productos'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(
      BuildContext context, CartState state, CartNotifier notifier) {
    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Imagen
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.white,
                    child: item.productImage != null
                        ? CachedNetworkImage(
                            imageUrl: item.productImage!,
                            fit: BoxFit.contain,
                            placeholder: (_, __) =>
                                Container(color: Colors.white),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : const Icon(
                            Icons.image,
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(item.precioUnitario / 100).toStringAsFixed(2)}€',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if ((item.talla != null && item.talla!.isNotEmpty) ||
                          (item.color != null && item.color!.isNotEmpty))
                        Text(
                          [item.talla, item.color]
                              .where((e) => e != null && e.isNotEmpty)
                              .join(' - '),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      if (item.expireAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: CartItemTimer(expireAt: item.expireAt!),
                        ),
                      const SizedBox(height: 8),
                      // Cantidad
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (item.quantity > 1) {
                                notifier.updateQuantity(
                                  item.id,
                                  item.quantity - 1,
                                );
                              } else {
                                notifier.removeItem(item.id);
                              }
                            },
                            icon: const Icon(Icons.remove),
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          Text(
                            item.quantity.toString(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          IconButton(
                            onPressed: item.quantity >= item.maxStock
                                ? null
                                : () {
                                    notifier.updateQuantity(
                                      item.id,
                                      item.quantity + 1,
                                    );
                                  },
                            icon: Icon(
                              Icons.add,
                              color: item.quantity >= item.maxStock
                                  ? Colors.grey
                                  : null, // Use default color
                            ),
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Subtotal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.precioTotalEuros.toStringAsFixed(2)}€',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      onPressed: () {
                        notifier.removeItem(item.id);
                      },
                      icon: const Icon(Icons.delete),
                      color: AppColors.error,
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartState state) {
    return Card(
      margin: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${state.totalEuros.toStringAsFixed(2)}€',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${state.totalEuros.toStringAsFixed(2)}€',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.checkout),
                child: const Text('Proceder a Pagar'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push(AppRoutes.products),
                child: const Text('Continuar Comprando'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemTimer extends StatefulWidget {
  final DateTime expireAt;

  const CartItemTimer({super.key, required this.expireAt});

  @override
  State<CartItemTimer> createState() => _CartItemTimerState();
}

class _CartItemTimerState extends State<CartItemTimer> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _remaining = widget.expireAt.isAfter(now)
          ? widget.expireAt.difference(now)
          : Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return Text(
        'Expirado',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
      );
    }
    final minutes = _remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return Text(
      '$minutes:$seconds restantes',
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: AppColors.error),
    );
  }
}
