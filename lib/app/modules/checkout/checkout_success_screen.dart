import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/checkout_success_provider.dart';
import '../../data/models/pedido_model.dart';
import '../../routes/app_router.dart';

class CheckoutSuccessScreen extends ConsumerStatefulWidget {
  const CheckoutSuccessScreen({super.key});

  @override
  ConsumerState<CheckoutSuccessScreen> createState() =>
      _CheckoutSuccessScreenState();
}

class _CheckoutSuccessScreenState extends ConsumerState<CheckoutSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verify();
    });
  }

  void _verify() {
    final state = GoRouterState.of(context);
    final sessionId = state.uri.queryParameters['session_id'];
    final orderId = state.uri.queryParameters['order_id'];

    if (sessionId != null && orderId != null) {
      ref
          .read(checkoutSuccessNotifierProvider.notifier)
          .verifyPayment(sessionId, orderId);
    } // If null, the provider will stay in default state or we could set error
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutSuccessNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Confirmación de Pedido'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Verificando tu pago...',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : state.isSuccess
              ? _buildSuccessView(context, state)
              : _buildErrorView(context, state),
    );
  }

  Widget _buildSuccessView(BuildContext context, CheckoutSuccessState state) {
    final order = state.order;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
          const SizedBox(height: 16),
          const Text('¡Pedido Confirmado!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Hemos recibido tu pedido y estamos trabajando en ello.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 32),
          if (order != null) ...[
            _buildOrderDetailsCard(order),
            const SizedBox(height: 24),
            _buildShippingInfoCard(order),
            const SizedBox(height: 24),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Seguir Comprando',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go(AppRoutes.orders),
            child: const Text('Ver Mis Pedidos',
                style: TextStyle(
                    color: Colors.black, decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(PedidoModel order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pedido #${order.numeroOrden}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('PAGADO',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 32),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text('${item.cantidad}x ',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Expanded(
                        child: Text(item.nombreProducto ?? 'Producto',
                            style: const TextStyle(fontSize: 14))),
                    Text('${item.subtotalEnEuros.toStringAsFixed(2)}€',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              )),
          const Divider(height: 32),
          _priceRow('Subtotal', order.subtotalEnEuros),
          if (order.descuento > 0)
            _priceRow('Descuento', -order.descuentoEnEuros, isDiscount: true),
          _priceRow('Envío', order.envioEnEuros),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${order.totalEnEuros.toStringAsFixed(2)}€',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfoCard(PedidoModel order) {
    final dir = order.direccionEnvio;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dirección de Envío',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(order.nombreCliente ?? '', style: const TextStyle(fontSize: 15)),
          if (dir != null) ...[
            Text(dir['direccion'] ?? '',
                style: TextStyle(color: Colors.grey[600])),
            Text('${dir['cp'] ?? ''} ${dir['ciudad'] ?? ''}',
                style: TextStyle(color: Colors.grey[600])),
            Text(dir['provincia'] ?? '',
                style: TextStyle(color: Colors.grey[600])),
          ],
          if (order.telefonoCliente != null) ...[
            const SizedBox(height: 8),
            Text(order.telefonoCliente!,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            '${amount > 0 && !isDiscount ? "+" : ""}${amount.toStringAsFixed(2)}€',
            style: TextStyle(
                color: isDiscount ? Colors.green : Colors.black,
                fontWeight: isDiscount ? FontWeight.w600 : null),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, CheckoutSuccessState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 80),
            const SizedBox(height: 24),
            const Text('Ocurrió un Problema',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(200, 50),
              ),
              child: const Text('Volver al Inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
