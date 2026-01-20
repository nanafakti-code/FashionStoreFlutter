import 'package:flutter/material.dart';
import '../models/carrito.dart';
import '../services/cart_service.dart';
import '../widgets/widgets.dart';
import '../config/app_theme.dart';

/// Pantalla del carrito
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  List<CarritoItem> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _cartService.getCart();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando carrito: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mi Carrito',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: _clearCart,
              child: const Text(
                'Vaciar',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _items.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Cargando carrito...');
    }

    if (_error != null) {
      return AppErrorWidget(
        message: _error!,
        details: 'Por favor, intenta de nuevo',
        onRetry: _loadCart,
      );
    }

    if (_items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.shopping_cart_outlined,
        title: 'Tu carrito está vacío',
        subtitle: 'Añade productos para comenzar tu compra',
        actionLabel: 'Ver productos',
        onAction: () {
          Navigator.pushNamed(context, '/products');
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return RefreshIndicator(
          onRefresh: _loadCart,
          child: isMobile
              ? ListView.builder(
                  padding: EdgeInsets.all(
                      ResponsiveHelper.getPadding(context)),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CartItemWidget(
                        item: item,
                        onQuantityChanged: (quantity) {
                          _updateQuantity(item.id, quantity);
                        },
                        onRemove: () {
                          _removeItem(item.id);
                        },
                        onTap: () {
                          // Navegar al producto
                        },
                      ),
                    );
                  },
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(
                      ResponsiveHelper.getPadding(context)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CartItemWidget(
                                item: item,
                                onQuantityChanged: (quantity) {
                                  _updateQuantity(item.id, quantity);
                                },
                                onRemove: () {
                                  _removeItem(item.id);
                                },
                                onTap: () {},
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 400,
                          child: SingleChildScrollView(
                            child: _buildSummaryCard(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    final resumen = CarritoResumen.fromItems(_items);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Subtotal',
            '${resumen.subtotal.toStringAsFixed(2)}€',
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            'Envío',
            '${resumen.envio.toStringAsFixed(2)}€',
          ),
          if (resumen.descuento > 0) ...[
            const SizedBox(height: 10),
            _buildSummaryRow(
              'Descuento',
              '-${resumen.descuento.toStringAsFixed(2)}€',
              isPositive: true,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Total',
            '${resumen.total.toStringAsFixed(2)}€',
            isBold: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/checkout');
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Proceder al pago'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, bool isPositive = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppColors.text : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isPositive ? AppColors.success : AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final resumen = CarritoResumen.fromItems(_items);
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow(
              'Total',
              '${resumen.total.toStringAsFixed(2)}€',
              isBold: true,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/checkout');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Proceder al pago'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      _removeItem(itemId);
      return;
    }

    final success = await _cartService.updateCartItem(itemId, quantity);
    if (success) {
      _loadCart();
    } else {
      showSnackBar(context, 'Error actualizando cantidad', isError: true);
    }
  }

  Future<void> _removeItem(String itemId) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Eliminar producto',
      message: '¿Deseas eliminar este producto del carrito?',
      confirmLabel: 'Eliminar',
      isDangerous: true,
    );

    if (!confirm) return;

    final success = await _cartService.removeFromCart(itemId);
    if (success) {
      _loadCart();
      showSnackBar(context, 'Producto eliminado');
    } else {
      showSnackBar(context, 'Error eliminando producto', isError: true);
    }
  }

  Future<void> _clearCart() async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Vaciar carrito',
      message: '¿Deseas eliminar todos los productos del carrito?',
      confirmLabel: 'Vaciar',
      isDangerous: true,
    );

    if (!confirm) return;

    final success = await _cartService.clearCart();
    if (success) {
      _loadCart();
      showSnackBar(context, 'Carrito vaciado');
    } else {
      showSnackBar(context, 'Error vaciando carrito', isError: true);
    }
  }
}
