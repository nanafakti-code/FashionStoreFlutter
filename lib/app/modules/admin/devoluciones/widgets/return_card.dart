import 'package:flutter/material.dart';
import '../../../../../config/theme/app_colors.dart';
import '../../../../data/models/devolucion_model.dart';
import '../../../../data/models/pedido_model.dart';
import 'package:intl/intl.dart';

class ReturnCard extends StatelessWidget {
  final DevolucionModel devolucion;
  final VoidCallback onTap;
  final VoidCallback onStatusChange;

  const ReturnCard({
    super.key,
    required this.devolucion,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final items = devolucion.pedido?.items ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Numero + Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      devolucion.numeroDevolucion,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.navy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(devolucion.estado),
                ],
              ),
              const SizedBox(height: 6),

              // Pedido + Fecha
              Row(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Pedido: ${devolucion.pedido?.numeroOrden ?? devolucion.ordenId}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    devolucion.fechaSolicitud != null
                        ? DateFormat('dd/MM/yy HH:mm')
                            .format(devolucion.fechaSolicitud!)
                        : 'N/A',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),

              // Products list
              if (items.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 12),
                ...items.take(3).map((item) => _buildProductRow(item)),
                if (items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${items.length - 3} producto(s) más',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],

              // Total
              if (devolucion.pedido != null) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Total: ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(devolucion.pedido!.total / 100).toStringAsFixed(2)}€',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 10),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 8),
              if (!_isFinalStatus(devolucion.estado))
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onStatusChange,
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Actualizar Estado'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.green),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductRow(ItemOrdenModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Product image
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
              image: item.imagenUrl != null
                  ? DecorationImage(
                      image: NetworkImage(item.imagenUrl!),
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
            child: item.imagenUrl == null
                ? Icon(Icons.image_not_supported,
                    size: 16, color: Colors.grey.shade400)
                : null,
          ),
          const SizedBox(width: 10),
          // Name + variant
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombreProducto ?? 'Producto',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.talla ?? 'Única'} · ${item.color ?? 'N/A'}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          // Price
          Text(
            '${(item.precioUnitario / 100).toStringAsFixed(2)}€ x${item.cantidad}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;

    switch (status.toLowerCase()) {
      case 'pendiente':
      case 'solicitud pendiente':
        bg = Colors.orange.shade50;
        text = Colors.orange.shade700;
        break;
      case 'aprobada':
      case 'recibida':
        bg = Colors.blue.shade50;
        text = Colors.blue.shade700;
        break;
      case 'reembolsada':
        bg = Colors.green.shade50;
        text = Colors.green.shade700;
        break;
      case 'rechazada':
        bg = Colors.red.shade50;
        text = Colors.red.shade700;
        break;
      default:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: text.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  bool _isFinalStatus(String status) {
    final s = status.toLowerCase();
    return s == 'reembolsada' || s == 'rechazada';
  }
}
