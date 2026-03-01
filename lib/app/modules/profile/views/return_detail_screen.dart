import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/return_provider.dart';
import '../../../../config/theme/app_colors.dart';

class ReturnDetailScreen extends ConsumerStatefulWidget {
  final String returnId;

  const ReturnDetailScreen({super.key, required this.returnId});

  @override
  ConsumerState<ReturnDetailScreen> createState() => _ReturnDetailScreenState();
}

class _ReturnDetailScreenState extends ConsumerState<ReturnDetailScreen> {
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
    if (status == 'Rechazada') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _stepperItem('!', 'RECHAZADA', true, isError: true),
          ],
        ),
      );
    }

    int currentStep = 0;
    if (status == 'Pendiente') currentStep = 1;
    if (status == 'Aprobada') currentStep = 2;
    if (status == 'Recibida') currentStep = 3;
    if (status == 'Reembolsada') currentStep = 4;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _stepperItem('1', 'PENDIENTE DE REVISIÓN', currentStep >= 1),
          _stepperLine(currentStep >= 2),
          _stepperItem('2', 'APROBADA', currentStep >= 2),
          _stepperLine(currentStep >= 3),
          _stepperItem('3', 'RECIBIDA', currentStep >= 3),
          _stepperLine(currentStep >= 4),
          _stepperItem('4', 'REEMBOLSADA', currentStep >= 4),
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

  Widget _statusChip(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Pendiente':
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade800;
        break;
      case 'Aprobada':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
        break;
      case 'Recibida':
        bg = Colors.teal.shade50;
        fg = Colors.teal.shade800;
        break;
      case 'Reembolsada':
        bg = Colors.grey.shade100;
        fg = Colors.black87;
        break;
      case 'Rechazada':
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        break;
      default:
        bg = Colors.grey.shade200;
        fg = Colors.black54;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _totalRow(String label, String amount,
      {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 16 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color: Colors.grey.shade600)),
          Text(amount,
              style: TextStyle(
                  fontSize: isTotal ? 16 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color:
                      isDiscount ? AppColors.success : Colors.grey.shade800)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(returnsProvider);
    final dev = state.value?.firstWhere((r) => r.id == widget.returnId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leadingWidth: 250,
        leading: TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: AppColors.success),
          label: const Text('Volver a mis devoluciones',
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
        if (dev == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Devolución no encontrada',
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

        final order = dev.pedido;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de la Devolución
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dev.numeroDevolucion,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 6),
                        if (dev.fechaSolicitud != null)
                          Text(
                            'Realizado el ${dev.fechaSolicitud!.day} ${_monthName(dev.fechaSolicitud!.month)} ${dev.fechaSolicitud!.year}',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                  _statusChip(dev.estado),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Colors.black12, thickness: 1),
              ),
              const SizedBox(height: 16),

              // Sección de Estado
              Text('Estado de la devolución',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              _buildStepper(dev.estado),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Colors.black12, thickness: 1),
              ),

              // Sección de Productos de la Orden original
              if (order != null) ...[
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
                            // Imagen
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
                            // Info
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
                                    '${item.talla != null && item.talla!.isNotEmpty ? " | Talla: ${item.talla}" : ""}'
                                    '${item.color != null && item.color!.isNotEmpty ? " | Color: ${item.color}" : ""}',
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
                            '-${(order.descuento / 100).toStringAsFixed(2)} EUR',
                            isDiscount: true),
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
              ],
            ],
          ),
        );
      }),
    );
  }
}
