/// Modelo de Item de Carrito
class CarritoItem {
  final String id;
  final String productoId;
  final String productoNombre;
  final int cantidad;
  final String? talla;
  final String? color;
  final int precioUnitario; // En céntimos
  final String? productoImagen;
  final int? productoStock;
  final DateTime? anadidoEn;

  CarritoItem({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    this.talla,
    this.color,
    required this.precioUnitario,
    this.productoImagen,
    this.productoStock,
    this.anadidoEn,
  });

  /// Precio unitario en euros
  double get precioEnEuros => precioUnitario / 100;

  /// Subtotal del item en céntimos
  int get subtotal => precioUnitario * cantidad;

  /// Subtotal en euros
  double get subtotalEnEuros => subtotal / 100;

  /// Identificador único para variante (producto + talla + color)
  String get varianteId {
    final parts = [productoId];
    if (talla != null) parts.add(talla!);
    if (color != null) parts.add(color!);
    return parts.join('_');
  }

  /// Tiene stock suficiente
  bool get tieneStock {
    if (productoStock == null) return true;
    return cantidad <= productoStock!;
  }

  factory CarritoItem.fromJson(Map<String, dynamic> json) {
    return CarritoItem(
      id: json['id'] as String,
      productoId: json['producto_id'] ?? json['product_id'] as String,
      productoNombre: json['producto_nombre'] ?? json['product_name'] as String,
      cantidad: json['cantidad'] ?? json['quantity'] as int,
      talla: json['talla'] as String?,
      color: json['color'] as String?,
      precioUnitario: json['precio_unitario'] as int,
      productoImagen:
          json['producto_imagen'] ?? json['product_image'] as String?,
      productoStock: json['producto_stock'] ?? json['product_stock'] as int?,
      anadidoEn: json['anadido_en'] != null
          ? DateTime.parse(json['anadido_en'] as String)
          : null,
    );
  }

  /// Desde respuesta de Supabase con join de productos
  factory CarritoItem.fromSupabaseJson(Map<String, dynamic> json) {
    final producto = json['productos'] as Map<String, dynamic>?;
    String? imagen;

    if (producto != null && producto['imagenes_producto'] != null) {
      final imagenes = producto['imagenes_producto'] as List;
      if (imagenes.isNotEmpty) {
        imagen = imagenes.first['url'] as String?;
      }
    }

    return CarritoItem(
      id: json['id'] as String,
      productoId: json['producto_id'] as String,
      productoNombre: producto?['nombre'] ?? 'Producto',
      cantidad: json['cantidad'] as int,
      talla: json['talla'] as String?,
      color: json['color'] as String?,
      precioUnitario: json['precio_unitario'] as int,
      productoImagen: imagen,
      productoStock: producto?['stock_total'] as int?,
      anadidoEn: json['anadido_en'] != null
          ? DateTime.parse(json['anadido_en'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_id': productoId,
      'producto_nombre': productoNombre,
      'cantidad': cantidad,
      'talla': talla,
      'color': color,
      'precio_unitario': precioUnitario,
      'producto_imagen': productoImagen,
      'producto_stock': productoStock,
      'anadido_en': anadidoEn?.toIso8601String(),
    };
  }

  CarritoItem copyWith({
    int? cantidad,
    int? precioUnitario,
    int? productoStock,
  }) {
    return CarritoItem(
      id: id,
      productoId: productoId,
      productoNombre: productoNombre,
      cantidad: cantidad ?? this.cantidad,
      talla: talla,
      color: color,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      productoImagen: productoImagen,
      productoStock: productoStock ?? this.productoStock,
      anadidoEn: anadidoEn,
    );
  }
}

/// Modelo de Carrito Invitado (almacenado en localStorage)
class GuestCarritoItem {
  final String productoId;
  final String productoNombre;
  final int cantidad;
  final String? talla;
  final String? color;
  final int precioUnitario;
  final String? productoImagen;
  final int createdAt;

  GuestCarritoItem({
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    this.talla,
    this.color,
    required this.precioUnitario,
    this.productoImagen,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  /// ID generado para el item
  String get id => '${productoId}_${talla ?? ''}_${color ?? ''}_$createdAt';

  /// Subtotal
  int get subtotal => precioUnitario * cantidad;

  /// Precio en euros
  double get precioEnEuros => precioUnitario / 100;

  /// Subtotal en euros
  double get subtotalEnEuros => subtotal / 100;

  /// Convertir a CarritoItem normal
  CarritoItem toCarritoItem() {
    return CarritoItem(
      id: id,
      productoId: productoId,
      productoNombre: productoNombre,
      cantidad: cantidad,
      talla: talla,
      color: color,
      precioUnitario: precioUnitario,
      productoImagen: productoImagen,
    );
  }

  factory GuestCarritoItem.fromJson(Map<String, dynamic> json) {
    return GuestCarritoItem(
      productoId: json['producto_id'] as String,
      productoNombre: json['producto_nombre'] as String,
      cantidad: json['cantidad'] as int,
      talla: json['talla'] as String?,
      color: json['color'] as String?,
      precioUnitario: json['precio_unitario'] as int,
      productoImagen: json['producto_imagen'] as String?,
      createdAt: json['created_at'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'producto_nombre': productoNombre,
      'cantidad': cantidad,
      'talla': talla,
      'color': color,
      'precio_unitario': precioUnitario,
      'producto_imagen': productoImagen,
      'created_at': createdAt,
    };
  }

  GuestCarritoItem copyWith({int? cantidad}) {
    return GuestCarritoItem(
      productoId: productoId,
      productoNombre: productoNombre,
      cantidad: cantidad ?? this.cantidad,
      talla: talla,
      color: color,
      precioUnitario: precioUnitario,
      productoImagen: productoImagen,
      createdAt: createdAt,
    );
  }
}

/// Resumen del carrito
class CarritoResumen {
  final List<CarritoItem> items;
  final int subtotal;
  final int impuestos;
  final int envio;
  final int descuento;
  final int total;

  CarritoResumen({
    required this.items,
    required this.subtotal,
    required this.impuestos,
    required this.envio,
    required this.descuento,
    required this.total,
  });

  /// Número de items
  int get itemCount => items.fold(0, (sum, item) => sum + item.cantidad);

  /// Está vacío
  bool get isEmpty => items.isEmpty;

  /// Total en euros
  double get totalEnEuros => total / 100;

  /// Subtotal en euros
  double get subtotalEnEuros => subtotal / 100;

  /// Impuestos en euros
  double get impuestosEnEuros => impuestos / 100;

  /// Envío en euros
  double get envioEnEuros => envio / 100;

  /// Descuento en euros
  double get descuentoEnEuros => descuento / 100;

  factory CarritoResumen.empty() {
    return CarritoResumen(
      items: [],
      subtotal: 0,
      impuestos: 0,
      envio: 0,
      descuento: 0,
      total: 0,
    );
  }

  factory CarritoResumen.fromItems(
    List<CarritoItem> items, {
    int descuento = 0,
    int envio = 0,
  }) {
    final subtotal = items.fold(0, (sum, item) => sum + item.subtotal);
    final impuestos = (subtotal * 0.21).round(); // 21% IVA
    final total = subtotal + envio - descuento;

    return CarritoResumen(
      items: items,
      subtotal: subtotal,
      impuestos: impuestos,
      envio: envio,
      descuento: descuento,
      total: total,
    );
  }
}
