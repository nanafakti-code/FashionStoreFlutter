import 'package:flutter/material.dart';
import '../../../../data/models/admin_order.dart';

class OrderDetailDialog extends StatelessWidget {
  final AdminOrder order;
  final VoidCallback? onDownloadInvoice;

  const OrderDetailDialog({
    super.key,
    required this.order,
    this.onDownloadInvoice,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
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
                      'Pedido ${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Client Info Box
              _buildSection(
                title: 'CLIENTE',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.clientName ?? 'Cliente Invitado',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    if (order.clientEmail != null)
                      Text(
                        order.clientEmail!,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    if (order.clientPhone != null)
                      Text(
                        order.clientPhone!,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Shipping Address Box
              _buildSection(
                title: 'DIRECCIÓN DE ENVÍO',
                content: Text(
                  _formatAddress(order.shippingAddress),
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),

              // Products Header
              const Text(
                'PRODUCTOS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Products List (inline, no separate scroll)
              ...order.items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _buildProductItem(item),
                    if (i < order.items.length - 1) const SizedBox(height: 12),
                  ],
                );
              }),
              const SizedBox(height: 24),

              // Totals
              const Divider(),
              const SizedBox(height: 16),
              _buildSummaryRow(
                  'Subtotal:', '${(order.total / 100).toStringAsFixed(2)}€'),
              if (order.discount > 0) ...[
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Descuento:',
                  '-${(order.discount / 100).toStringAsFixed(2)}€',
                  color: Colors.redAccent,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A)),
                  ),
                  Text(
                    '${(order.total / 100).toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Buttons
              if (onDownloadInvoice != null) ...[
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('CERRAR',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildProductItem(AdminOrderItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            image: item.productImage != null
                ? DecorationImage(
                    image: NetworkImage(item.productImage!),
                    fit: BoxFit.contain,
                  )
                : null,
          ),
          child: item.productImage == null
              ? const Icon(Icons.image_not_supported,
                  size: 20, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 12),
        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${item.size ?? 'Única'} | ${item.color ?? 'N/A'}',
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
              '${(item.unitPrice / 100).toStringAsFixed(2)}€ x ${item.quantity}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey.shade700),
            ),
            Text(
              '${((item.unitPrice * item.quantity) / 100).toStringAsFixed(2)}€',
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

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Text(value,
            style: TextStyle(
                color: color ?? Colors.grey.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _formatAddress(Map<String, dynamic>? address) {
    if (address == null) return 'Dirección no disponible';

    final parts = <String>[];

    // Dirección / calle
    final direccion = address['direccion'] ?? address['calle'] ?? '';
    if (direccion.toString().trim().isNotEmpty)
      parts.add(direccion.toString().trim());

    // Número (si existe por separado)
    final numero = address['numero'] ?? '';
    if (numero.toString().trim().isNotEmpty)
      parts.add(numero.toString().trim());

    // CP + Ciudad
    final cp = address['cp'] ?? address['codigo_postal'] ?? '';
    final ciudad = address['ciudad'] ?? '';
    final cpCiudad =
        [cp, ciudad].where((s) => s.toString().trim().isNotEmpty).join(' ');
    if (cpCiudad.isNotEmpty) parts.add(cpCiudad);

    // Provincia
    final provincia = address['provincia'] ?? '';
    if (provincia.toString().trim().isNotEmpty)
      parts.add(provincia.toString().trim());

    // País
    final pais = address['pais'] ?? '';
    if (pais.toString().trim().isNotEmpty) parts.add(pais.toString().trim());

    return parts.isEmpty ? 'Dirección no disponible' : parts.join('\n');
  }
}
