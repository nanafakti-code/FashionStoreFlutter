/// Modelo de Producto
class Producto {
  final String id;
  final String nombre;
  final String slug;
  final String? descripcion;
  final String? descripcionLarga;
  final int precioVenta; // En céntimos
  final int? precioOriginal; // En céntimos
  final int? costo;
  final int stockTotal;
  final String? sku;
  final String? categoriaId;
  final String? marcaId;
  final String? genero;
  final String? color;
  final String? material;
  final bool destacado;
  final bool activo;
  final double valoracionPromedio;
  final int totalResenas;
  final DateTime? creadoEn;
  final DateTime? actualizadoEn;
  final List<String> imagenes;
  final List<VarianteProducto> variantes;
  final Categoria? categoria;
  final Marca? marca;

  Producto({
    required this.id,
    required this.nombre,
    required this.slug,
    this.descripcion,
    this.descripcionLarga,
    required this.precioVenta,
    this.precioOriginal,
    this.costo,
    this.stockTotal = 0,
    this.sku,
    this.categoriaId,
    this.marcaId,
    this.genero,
    this.color,
    this.material,
    this.destacado = false,
    this.activo = true,
    this.valoracionPromedio = 0,
    this.totalResenas = 0,
    this.creadoEn,
    this.actualizadoEn,
    this.imagenes = const [],
    this.variantes = const [],
    this.categoria,
    this.marca,
  });

  /// Precio en euros (formato decimal)
  double get precioEnEuros => precioVenta / 100;

  /// Precio original en euros
  double? get precioOriginalEnEuros =>
      precioOriginal != null ? precioOriginal! / 100 : null;

  /// Porcentaje de descuento
  int? get descuento {
    if (precioOriginal == null || precioOriginal! <= precioVenta) return null;
    return (((precioOriginal! - precioVenta) / precioOriginal!) * 100).round();
  }

  /// Imagen principal
  String? get imagenPrincipal => imagenes.isNotEmpty ? imagenes.first : null;

  /// Tiene stock disponible
  bool get tieneStock => stockTotal > 0;

  /// Está en oferta
  bool get enOferta => precioOriginal != null && precioOriginal! > precioVenta;

  factory Producto.fromJson(Map<String, dynamic> json) {
    // Procesar imágenes
    List<String> imagenes = [];
    if (json['imagenes_producto'] != null) {
      if (json['imagenes_producto'] is List) {
        imagenes = (json['imagenes_producto'] as List)
            .map((img) => img['url'] as String)
            .toList();
      }
    }

    // Procesar variantes
    List<VarianteProducto> variantes = [];
    if (json['variantes_producto'] != null) {
      if (json['variantes_producto'] is List) {
        variantes = (json['variantes_producto'] as List)
            .map((v) => VarianteProducto.fromJson(v))
            .toList();
      }
    }

    return Producto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      slug: json['slug'] as String,
      descripcion: json['descripcion'] as String?,
      descripcionLarga: json['descripcion_larga'] as String?,
      precioVenta: json['precio_venta'] as int,
      precioOriginal: json['precio_original'] as int?,
      costo: json['costo'] as int?,
      stockTotal: json['stock_total'] as int? ?? 0,
      sku: json['sku'] as String?,
      categoriaId: json['categoria_id'] as String?,
      marcaId: json['marca_id'] as String?,
      genero: json['genero'] as String?,
      color: json['color'] as String?,
      material: json['material'] as String?,
      destacado: json['destacado'] as bool? ?? false,
      activo: json['activo'] as bool? ?? true,
      valoracionPromedio:
          (json['valoracion_promedio'] as num?)?.toDouble() ?? 0,
      totalResenas: json['total_resenas'] as int? ?? 0,
      creadoEn: json['creado_en'] != null
          ? DateTime.parse(json['creado_en'] as String)
          : null,
      actualizadoEn: json['actualizado_en'] != null
          ? DateTime.parse(json['actualizado_en'] as String)
          : null,
      imagenes: imagenes,
      variantes: variantes,
      categoria: json['categorias'] != null
          ? Categoria.fromJson(json['categorias'])
          : null,
      marca: json['marcas'] != null ? Marca.fromJson(json['marcas']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'slug': slug,
      'descripcion': descripcion,
      'descripcion_larga': descripcionLarga,
      'precio_venta': precioVenta,
      'precio_original': precioOriginal,
      'costo': costo,
      'stock_total': stockTotal,
      'sku': sku,
      'categoria_id': categoriaId,
      'marca_id': marcaId,
      'genero': genero,
      'color': color,
      'material': material,
      'destacado': destacado,
      'activo': activo,
    };
  }
}

/// Modelo de Variante de Producto
class VarianteProducto {
  final String id;
  final String productoId;
  final String talla;
  final String? color;
  final int stock;
  final String? skuVariante;
  final int precioAdicional;

  VarianteProducto({
    required this.id,
    required this.productoId,
    required this.talla,
    this.color,
    this.stock = 0,
    this.skuVariante,
    this.precioAdicional = 0,
  });

  factory VarianteProducto.fromJson(Map<String, dynamic> json) {
    return VarianteProducto(
      id: json['id'] as String,
      productoId: json['producto_id'] as String,
      talla: json['talla'] as String,
      color: json['color'] as String?,
      stock: json['stock'] as int? ?? 0,
      skuVariante: json['sku_variante'] as String?,
      precioAdicional: json['precio_adicional'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_id': productoId,
      'talla': talla,
      'color': color,
      'stock': stock,
      'sku_variante': skuVariante,
      'precio_adicional': precioAdicional,
    };
  }
}

/// Modelo de Categoría
class Categoria {
  final String id;
  final String nombre;
  final String slug;
  final String? descripcion;
  final String? icono;
  final String? imagenPortada;
  final String? padreId;
  final int orden;
  final bool activa;

  Categoria({
    required this.id,
    required this.nombre,
    required this.slug,
    this.descripcion,
    this.icono,
    this.imagenPortada,
    this.padreId,
    this.orden = 0,
    this.activa = true,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      slug: json['slug'] as String,
      descripcion: json['descripcion'] as String?,
      icono: json['icono'] as String?,
      imagenPortada: json['imagen_portada'] as String?,
      padreId: json['padre_id'] as String?,
      orden: json['orden'] as int? ?? 0,
      activa: json['activa'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'slug': slug,
      'descripcion': descripcion,
      'icono': icono,
      'imagen_portada': imagenPortada,
      'padre_id': padreId,
      'orden': orden,
      'activa': activa,
    };
  }
}

/// Modelo de Marca
class Marca {
  final String id;
  final String nombre;
  final String slug;
  final String? descripcion;
  final String? logo;
  final String? sitioWeb;
  final bool activa;

  Marca({
    required this.id,
    required this.nombre,
    required this.slug,
    this.descripcion,
    this.logo,
    this.sitioWeb,
    this.activa = true,
  });

  factory Marca.fromJson(Map<String, dynamic> json) {
    return Marca(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      slug: json['slug'] as String,
      descripcion: json['descripcion'] as String?,
      logo: json['logo'] as String?,
      sitioWeb: json['sitio_web'] as String?,
      activa: json['activa'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'slug': slug,
      'descripcion': descripcion,
      'logo': logo,
      'sitio_web': sitioWeb,
      'activa': activa,
    };
  }
}
