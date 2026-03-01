import 'package:flutter/material.dart';
import '../../../../data/models/admin_order.dart';

class OrderCard extends StatelessWidget {
  final AdminOrder order;
  final VoidCallback onTap;
  final VoidCallback onStatusChange;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onStatusChange,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'pagado':
      case 'confirmado':
        return Colors.blue;
      case 'enviado':
        return Colors.indigo;
      case 'entregado':
        return Colors.green;
      case 'cancelado':
      case 'devuelto':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order # + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.orderNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info Row: Client and Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CLIENTE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.clientName ?? 'Cliente Invitado',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (order.clientEmail != null)
                      Text(
                        order.clientEmail!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Total Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
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
            ],
          ),

          // Products
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFEEEEEE), height: 1),
            const SizedBox(height: 14),
            ...order.items.take(3).map((item) => _buildProductRow(item)),
            if (order.items.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '+${order.items.length - 3} producto(s) más',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],

          const SizedBox(height: 14),

          // Date
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                '${order.createdAt.day} ${_getMonthName(order.createdAt.month)} ${order.createdAt.year}, ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              // Ver Detalles Button
              Expanded(
                flex: 4,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.remove_red_eye_rounded,
                      size: 18, color: Colors.white),
                  label: const Text('Ver Detalles'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Change Status (if not returned or cancelled)
              if (!(order.status.toLowerCase().contains('devuelto') ||
                  order.status.toLowerCase().contains('devolucion') ||
                  order.status.toLowerCase().contains('cancelado')))
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    onPressed: onStatusChange,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _formatStatus(order.status),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(AdminOrderItem item) {
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
              image: item.productImage != null
                  ? DecorationImage(
                      image: NetworkImage(item.productImage!),
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
            child: item.productImage == null
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
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.size ?? 'Única'} · ${item.color ?? 'N/A'}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          // Price
          Text(
            '${(item.unitPrice / 100).toStringAsFixed(2)}€ x${item.quantity}',
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

  String _formatStatus(String status) {
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  String _getMonthName(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return months[month - 1];
  }
}
