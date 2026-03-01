import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/devolucion_model.dart';
import '../../../../data/models/pedido_model.dart';

class ReturnDetailDialog extends StatelessWidget {
  final DevolucionModel devolucion;
  final VoidCallback? onDownloadInvoice;

  const ReturnDetailDialog({
    super.key,
    required this.devolucion,
    this.onDownloadInvoice,
  });

  @override
  Widget build(BuildContext context) {
    final pedido = devolucion.pedido;
    final items = pedido?.items ?? [];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      devolucion.numeroDevolucion,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(devolucion.estado),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pedido Info
              _buildSection(
                title: 'PEDIDO ASOCIADO',
                icon: Icons.receipt_long_outlined,
                content: Text(
                  pedido?.numeroOrden ?? devolucion.ordenId,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),

              // Motivo
              _buildSection(
                title: 'MOTIVO DE DEVOLUCIÓN',
                icon: Icons.chat_bubble_outline_rounded,
                content: Text(
                  devolucion.motivo,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Notas Admin
              if (devolucion.notasAdmin != null &&
                  devolucion.notasAdmin!.isNotEmpty) ...[
                _buildSection(
                  title: 'NOTAS DEL ADMINISTRADOR',
                  icon: Icons.note_alt_outlined,
                  content: Text(
                    devolucion.notasAdmin!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Productos del pedido
              if (items.isNotEmpty) ...[
                const Text(
                  'PRODUCTOS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _buildProductItem(items[i]),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 8),

              // Reembolso
              const Divider(),
              const SizedBox(height: 12),

              if (devolucion.metodoReembolso != null) ...[
                _buildSummaryRow(
                  'Método:',
                  devolucion.metodoReembolso!,
                ),
                const SizedBox(height: 8),
              ],

              // Importe del reembolso: usar el total del pedido si no hay importe específico
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Importe Reembolso:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    _getRefundText(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          _getRefundAmount() > 0 ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Buttons
              if (onDownloadInvoice != null &&
                  devolucion.estado.toLowerCase() == 'reembolsada') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onDownloadInvoice,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('DESCARGAR FACTURA',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B2A4A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('CERRAR',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getRefundAmount() {
    if (devolucion.importeReembolso != null &&
        devolucion.importeReembolso! > 0) {
      return devolucion.importeReembolso! / 100;
    }
    if (devolucion.pedido != null) {
      return devolucion.pedido!.total / 100;
    }
    return 0;
  }

  String _getRefundText() {
    final amount = _getRefundAmount();
    if (amount > 0) {
      return '${amount.toStringAsFixed(2)}€';
    }
    return 'Pendiente';
  }

  Widget _buildProductItem(ItemOrdenModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            image: item.imagenUrl != null
                ? DecorationImage(
                    image: NetworkImage(item.imagenUrl!),
                    fit: BoxFit.contain,
                  )
                : null,
          ),
          child: item.imagenUrl == null
              ? const Icon(Icons.image_not_supported,
                  size: 18, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 10),
        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.nombreProducto ?? 'Producto',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${item.talla ?? 'Única'} | ${item.color ?? 'N/A'}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
        ),
        // Price & Qty
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(item.precioUnitario / 100).toStringAsFixed(2)}€ x ${item.cantidad}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.grey.shade700),
            ),
            Text(
              '${((item.precioUnitario * item.cantidad) / 100).toStringAsFixed(2)}€',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Widget content,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime? date, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Text(
            date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : 'N/A',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Text(value,
            style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
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
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
