class AdminProduct {
  final String id;
  final String nombre;
  final String? descripcion;
  final int precioVenta; // stored in céntimos
  final int? costo; // stored in céntimos
  final int stockTotal;
  final String? imagenUrl;
  final String? categoriaId;
  final String? marcaId;
  final String? sku;
  final bool activo;
  final String creadoEn;
  final double? valoracionPromedio;
  final int? totalResenas;

  const AdminProduct({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precioVenta,
    this.costo,
    required this.stockTotal,
    this.imagenUrl,
    this.categoriaId,
    this.marcaId,
    this.sku,
    required this.activo,
    required this.creadoEn,
    this.valoracionPromedio,
    this.totalResenas,
  });

  double get precioEnEuros => precioVenta / 100;
  double? get costoEnEuros => costo != null ? costo! / 100 : null;

  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    return AdminProduct(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      precioVenta: (json['precio_venta'] ?? 0) as int,
      costo: json['costo'] as int?,
      stockTotal: (json['stock_total'] ?? 0) as int,
      imagenUrl: json['imagen_url'],
      categoriaId: json['categoria_id'],
      marcaId: json['marca_id'],
      sku: json['sku'],
      activo: json['activo'] ?? true,
      creadoEn: json['creado_en'] ?? json['created_at'] ?? '',
      valoracionPromedio: (json['valoracion_promedio'] as num?)?.toDouble(),
      totalResenas: json['total_resenas'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'precio_venta': precioVenta,
        'costo': costo,
        'imagen_url': imagenUrl,
        'categoria_id': categoriaId,
        'marca_id': marcaId,
        'activo': activo,
      };
}
