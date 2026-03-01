import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashion_store_flutter/app/providers/order_provider.dart';
import 'package:fashion_store_flutter/app/providers/return_provider.dart';
import 'package:fashion_store_flutter/app/providers/auth_provider.dart';
import 'package:fashion_store_flutter/config/theme/app_colors.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderNotifierProvider.notifier).loadOrderDetail(widget.orderId);
    });
  }

  String _getStatusLabel(String status) {
    if (status == 'Pendiente_Pago') return 'Pendiente';
    if (status == 'Entregado') return 'Completado';
    if (status == 'Solicitud Pendiente' || status == 'Devolución_Solicitada') {
      return 'Solicitud Pendiente';
    }
    return status;
  }

  String _monthName(int month) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }

  Widget _buildStepper(String status) {
    if (status == 'Cancelado') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _stepperItem('!', 'CANCELADO', true, isError: true),
          ],
        ),
      );
    }

    int currentStep = 0;
    if (status == 'Pendiente' || status == 'Pendiente_Pago') currentStep = 1;
    if (status == 'Pagado') currentStep = 2;
    if (status == 'En Proceso') currentStep = 3;
    if (status == 'Enviado') currentStep = 4;
    // Permitir ambos para retrocompatibilidad
    if (status == 'Completado' || status == 'Entregado') currentStep = 5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _stepperItem('1', 'PENDIENTE', currentStep >= 1),
          _stepperLine(currentStep >= 2),
          _stepperItem('2', 'PAGADO', currentStep >= 2),
          _stepperLine(currentStep >= 3),
          _stepperItem('3', 'EN PROCESO', currentStep >= 3),
          _stepperLine(currentStep >= 4),
          _stepperItem('4', 'ENVIADO', currentStep >= 4),
          _stepperLine(currentStep >= 5),
          _stepperItem('5', 'COMPLETADO', currentStep >= 5),
        ],
      ),
    );
  }

  Widget _stepperLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? AppColors.success : Colors.grey.shade300,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _stepperItem(String number, String label, bool active,
      {bool isError = false}) {
    final color = isError ? AppColors.error : AppColors.success;
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: active ? color : Colors.grey.shade200,
          child: Text(number,
              style: TextStyle(
                  color: active ? Colors.white : Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: active ? Colors.black87 : Colors.grey.shade400)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderNotifierProvider);
    final order = state.selectedOrder;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leadingWidth: 250,
        leading: TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: AppColors.success),
          label: const Text('Volver a mis pedidos',
              style: TextStyle(
                  color: AppColors.success,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Builder(builder: (context) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (order == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Pedido no encontrado',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Volver'),
                )
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del Pedido
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${order.numeroOrden}',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 6),
                              if (order.fechaCreacion != null)
                                Text(
                                  'Realizado el ${order.fechaCreacion!.day} ${_monthName(order.fechaCreacion!.month)} ${order.fechaCreacion!.year}',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14),
                                ),
                            ],
                          ),
                        ),
                        _statusChip(order.estado),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Colors.black12, thickness: 1),
              ),
              const SizedBox(height: 16),

              // Sección de Estado
              Text('Estado del pedido',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 16),
              _buildStepper(order.estado),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Colors.black12, thickness: 1),
              ),

              // Sección de Artículos
              Text('Productos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 16),

              ...order.items.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Imagen del producto
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.imagenUrl != null &&
                                    item.imagenUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: item.imagenUrl!,
                                    width: 60,
                                    height: 70,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Container(
                                      width: 60,
                                      height: 70,
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2)),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      width: 60,
                                      height: 70,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image,
                                          color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    width: 60,
                                    height: 70,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image,
                                        color: Colors.grey),
                                  ),
                          ),
                          const SizedBox(width: 16),

                          // Info del producto
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.nombreProducto ?? 'Producto',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cantidad: ${item.cantidad}'
                                  '${item.color != null && item.color!.isNotEmpty ? " | Color: ${item.color}" : ""}'
                                  '${item.talla != null && item.talla!.isNotEmpty ? " | Talla: ${item.talla}" : ""}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${(item.subtotalEnEuros).toStringAsFixed(2)} EUR',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 24),

              // Resumen Financiero
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _totalRow('Subtotal',
                        '${(order.subtotal / 100).toStringAsFixed(2)} EUR'),
                    if (order.descuento > 0)
                      _totalRow('Descuento',
                          '-${(order.descuento / 100).toStringAsFixed(2)} EUR'),
                    const SizedBox(height: 8),
                    _totalRow(
                        'Envio',
                        order.costeEnvio > 0
                            ? '${(order.costeEnvio / 100).toStringAsFixed(2)} EUR'
                            : 'Gratis'),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Colors.black12, thickness: 1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        Text(
                          '${(order.totalEnEuros).toStringAsFixed(2)} EUR',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.success),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Dirección de envío
              if (order.direccionEnvio != null &&
                  order.direccionEnvio!.isNotEmpty) ...[
                Text('Información de Envío',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_shipping,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Entregar a:',
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (order.nombreCliente != null)
                        Text(order.nombreCliente!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      if (order.direccionEnvio?['direccion'] != null)
                        Text(order.direccionEnvio!['direccion'],
                            style: TextStyle(
                                color: Colors.grey.shade800, height: 1.5)),
                      Text(
                        '${order.direccionEnvio?['cp'] ?? ''} ${order.direccionEnvio?['ciudad'] ?? ''}',
                        style:
                            TextStyle(color: Colors.grey.shade800, height: 1.5),
                      ),
                      if (order.direccionEnvio?['provincia'] != null)
                        Text(order.direccionEnvio!['provincia'],
                            style: TextStyle(
                                color: Colors.grey.shade800, height: 1.5)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Botón Cancelar
              if (order.isCancelable)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmCancel(context, order.id),
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                    label: const Text('Cancelar Pedido',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

              // Botón Solicitud Devolución
              if (order.estado == 'Completado' || order.estado == 'Entregado')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDevolucion(context, order.id),
                    icon: const Icon(Icons.assignment_return_outlined,
                        color: AppColors.primary),
                    label: const Text('Solicitar Devolución',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                )
              else if (order.estado == 'Solicitud Pendiente' ||
                  order.estado == 'Devolución_Solicitada')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.hourglass_empty, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Solicitud de Devolución Pendiente',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _statusChip(String status) {
    Color bg = Colors.purple.shade50;
    Color fg = Colors.purple.shade700;

    if (status == 'Pendiente_Pago' || status == 'Pendiente') {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade700;
    } else if (status == 'Pagado') {
      bg = Colors.blue.shade50;
      fg = Colors.blue.shade700;
    } else if (status == 'Enviado') {
      bg = Colors.teal.shade50;
      fg = Colors.teal.shade700;
    } else if (status == 'Completado' || status == 'Entregado') {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
    } else if (status == 'Solicitud Pendiente' ||
        status == 'Devolución_Solicitada') {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade700;
    } else if (status == 'Cancelado') {
      bg = Colors.red.shade50;
      fg = Colors.red.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(_getStatusLabel(status),
          style:
              TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }

  Widget _totalRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 16)),
          Text(val,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Pedido'),
        content:
            const Text('¿Estás seguro de que quieres cancelar este pedido?'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              context.pop();
              final success = await ref
                  .read(orderNotifierProvider.notifier)
                  .cancelOrder(orderId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pedido cancelado')));
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al cancelar')));
              }
            },
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _confirmDevolucion(BuildContext context, String orderId) {
    final TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Solicitar devolución',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Pedido: $orderId', // O usa número de orden si lo pasas por parámetro, pero orderId servirá para probar visualmente
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Motivo de la devolucion',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: motivoController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe el motivo de tu devolucion...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6), // Amarillo claro
                  border: Border.all(
                      color: const Color(0xFFFFD54F)), // Borde amarillo
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Importante: Una vez enviada la solicitud, recibiras un email con las instrucciones para devolver el producto. El reembolso se procesara en 5-10 dias habiles tras recibir el producto.',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFFB76E00), height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Cancelar',
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final motivo = motivoController.text.trim();
                        if (motivo.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Por favor, indica un motivo de devolución')));
                          return;
                        }

                        // Cerrar diálogo
                        context.pop();

                        // Mostrar loader o enviar asíncrono
                        final returnId = await ref
                            .read(returnsProvider.notifier)
                            .createReturn(orderId, motivo);

                        if (returnId != null && context.mounted) {
                          // Refrescar órdenes para que desaparezca de la lista
                          final user = ref.read(authNotifierProvider).user;
                          if (user != null) {
                            ref
                                .read(orderNotifierProvider.notifier)
                                .loadUserOrders(user.id);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Solicitud de devolución enviada correctamente.')));

                          // Redirigir inmediatamente a la página de la devolución creada
                          context.pushReplacement('/return/$returnId');
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Error al enviar solicitud de devolución.')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Enviar solicitud',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
