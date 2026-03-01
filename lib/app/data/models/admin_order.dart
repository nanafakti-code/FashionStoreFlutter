class AdminOrder {
  final String id;
  final String orderNumber;
  final String status;
  final int total;
  final int discount;
  final DateTime createdAt;
  final String? clientName;
  final String? clientEmail;
  final String? clientPhone;
  final Map<String, dynamic>? shippingAddress;
  final List<AdminOrderItem> items;

  AdminOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    this.discount = 0,
    required this.createdAt,
    this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.shippingAddress,
    this.items = const [],
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    var itemsList = <AdminOrderItem>[];
    if (json['items_orden'] != null && json['items_orden'] is List) {
      itemsList = (json['items_orden'] as List)
          .map((i) => AdminOrderItem.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return AdminOrder(
      id: json['id'] as String? ?? '',
      orderNumber: json['numero_orden'] as String? ?? 'N/A',
      status: json['estado'] as String? ?? 'Pendiente',
      total: json['total'] as int? ?? 0,
      discount: json['descuento'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['fecha_creacion'] as String? ?? '') ??
          DateTime.now(),
      clientName: json['nombre_cliente'] as String?,
      clientEmail: json['email_cliente'] as String?,
      clientPhone: json['telefono_cliente'] as String?,
      shippingAddress: json['direccion_envio'] as Map<String, dynamic>?,
      items: itemsList,
    );
  }
}

class AdminOrderItem {
  final String productName;
  final String? productImage;
  final int quantity;
  final int unitPrice;
  final String? size;
  final String? color;

  AdminOrderItem({
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    this.size,
    this.color,
  });

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    return AdminOrderItem(
      productName: json['producto_nombre'] as String? ?? 'Desconocido',
      productImage: json['producto_imagen'] as String?,
      quantity: json['cantidad'] as int? ?? 1,
      unitPrice: json['precio_unitario'] as int? ?? 0,
      size: json['talla'] as String?,
      color: json['color'] as String?,
    );
  }
}
