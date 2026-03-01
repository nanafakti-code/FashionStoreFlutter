class AdminVariant {
  final String id;
  final String productoId;
  final String talla;
  final String? color;
  final String? capacidad;
  int stock;
  final String? imagenUrl;
  final int precioAdicional; // céntimos
  bool pendingDelete;

  AdminVariant({
    required this.id,
    required this.productoId,
    required this.talla,
    this.color,
    this.capacidad,
    required this.stock,
    this.imagenUrl,
    required this.precioAdicional,
    this.pendingDelete = false,
  });

  double get precioAdicionalEuros => precioAdicional / 100;

  factory AdminVariant.fromJson(Map<String, dynamic> json) {
    return AdminVariant(
      id: json['id'] ?? '',
      productoId: json['producto_id'] ?? '',
      talla: json['talla'] ?? '',
      color: json['color'],
      capacidad: json['capacidad'],
      stock: (json['stock'] ?? 0) as int,
      imagenUrl: json['imagen_url'],
      precioAdicional: (json['precio_adicional'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'talla': talla,
        'color': color ?? '',
        'capacidad': capacidad ?? '',
        'stock': stock,
        'precio': precioAdicional,
        'imagen_url': imagenUrl ?? '',
      };

  AdminVariant copyWith({
    String? id,
    String? productoId,
    String? talla,
    String? color,
    String? capacidad,
    int? stock,
    String? imagenUrl,
    int? precioAdicional,
    bool? pendingDelete,
  }) {
    return AdminVariant(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      talla: talla ?? this.talla,
      color: color ?? this.color,
      capacidad: capacidad ?? this.capacidad,
      stock: stock ?? this.stock,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      precioAdicional: precioAdicional ?? this.precioAdicional,
      pendingDelete: pendingDelete ?? this.pendingDelete,
    );
  }
}
