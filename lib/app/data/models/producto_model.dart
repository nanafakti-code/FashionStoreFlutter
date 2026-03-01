import 'package:freezed_annotation/freezed_annotation.dart';

part 'producto_model.freezed.dart';

// ─── VarianteProductoModel ───────────────────────────────────────────────────

@Freezed(toJson: false, fromJson: false)
class VarianteProductoModel with _$VarianteProductoModel {
  const VarianteProductoModel._(); // Allows custom methods

  const factory VarianteProductoModel({
    required String id,
    String? talla,
    String? color,
    String? capacidad,
    @Default(0) int stock,
    @Default(0) int precioAdicional,
    int? precioVenta,
    String? imagenUrl,
  }) = _VarianteProductoModel;

  factory VarianteProductoModel.fromJson(Map<String, dynamic> json) =>
      VarianteProductoModel(
        id: json['id'] ?? '',
        talla: json['talla'],
        color: json['color'],
        capacidad: json['capacidad'],
        stock: json['stock'] ?? 0,
        precioAdicional: json['precio_adicional'] ?? 0,
        precioVenta: json['precio_venta'],
        imagenUrl: json['imagen_url'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'talla': talla,
        'color': color,
        'capacidad': capacidad,
        'stock': stock,
        'precio_adicional': precioAdicional,
        'precio_venta': precioVenta,
        'imagen_url': imagenUrl,
      };
}

// ─── CategoriaModel ──────────────────────────────────────────────────────────

@Freezed(toJson: false, fromJson: false)
class CategoriaModel with _$CategoriaModel {
  const factory CategoriaModel({
    required String id,
    required String nombre,
    required String slug,
  }) = _CategoriaModel;

  factory CategoriaModel.fromJson(Map<String, dynamic> json) => CategoriaModel(
        id: json['id'] ?? '',
        nombre: json['nombre'] ?? '',
        slug: json['slug'] ?? '',
      );

  const CategoriaModel._();

  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre, 'slug': slug};
}

// ─── MarcaModel ──────────────────────────────────────────────────────────────

@Freezed(toJson: false, fromJson: false)
class MarcaModel with _$MarcaModel {
  const factory MarcaModel({
    required String id,
    required String nombre,
    required String slug,
  }) = _MarcaModel;

  factory MarcaModel.fromJson(Map<String, dynamic> json) => MarcaModel(
        id: json['id'] ?? '',
        nombre: json['nombre'] ?? '',
        slug: json['slug'] ?? '',
      );

  const MarcaModel._();

  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre, 'slug': slug};
}

// ─── ProductoModel ───────────────────────────────────────────────────────────

@Freezed(toJson: false, fromJson: false)
class ProductoModel with _$ProductoModel {
  const ProductoModel._(); // Allows custom methods/getters

  const factory ProductoModel({
    required String id,
    required String nombre,
    required String slug,
    String? descripcion,
    String? descripcionLarga,
    required int precioVenta,
    int? precioOriginal,
    required int stockTotal,
    String? imagenPrincipal,
    @Default([]) List<String> imagenes,
    @Default([]) List<VarianteProductoModel> variantes,
    String? parentId,
    String? nombreVariante,
    String? categoriaId,
    String? marcaId,
    String? sku,
    String? genero,
    String? color,
    String? material,
    @Default(false) bool destacado,
    @Default(true) bool activo,
    CategoriaModel? categoria,
    MarcaModel? marca,
  }) = _ProductoModel;

  // ── Custom fromJson with variant detection ──────────────────────────────────
  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? productData;
    bool isVariant = false;

    if (json['producto'] != null && json['producto'] is Map) {
      productData = json['producto'] as Map<String, dynamic>;
      isVariant = true;
    }

    final baseData = isVariant ? productData! : json;

    // Image processing
    List<String> imgs = [];
    String? thumb;

    if (isVariant) {
      if (json['imagen_url'] != null) {
        thumb = json['imagen_url'] as String;
        imgs = [thumb];
      } else {
        if (baseData['imagenes_producto'] != null &&
            baseData['imagenes_producto'] is List) {
          imgs = (baseData['imagenes_producto'] as List)
              .map((e) => e['url'] as String)
              .toList();
          if (imgs.isNotEmpty) thumb = imgs.first;
        } else if (baseData['imagen_url'] != null) {
          thumb = baseData['imagen_url'] as String;
          imgs = [thumb];
        }
      }
    } else {
      // Try variant images first
      if (json['variantes'] != null && json['variantes'] is List) {
        final vars = json['variantes'] as List;
        for (var v in vars) {
          if (v['imagen_url'] != null &&
              v['imagen_url'].toString().isNotEmpty) {
            thumb = v['imagen_url'] as String;
            imgs = [thumb];
            break;
          }
        }
      }

      // Fallback to product images
      if (thumb == null || thumb.isEmpty) {
        if (json['imagenes_producto'] != null &&
            json['imagenes_producto'] is List) {
          final pImgs = (json['imagenes_producto'] as List)
              .map((e) => e['url'] as String)
              .toList();
          if (pImgs.isNotEmpty) {
            thumb = pImgs.first;
            imgs = pImgs;
          }
        } else if (json['imagen_url'] != null) {
          thumb = json['imagen_url'] as String;
          imgs = [thumb];
        } else if (json['imagen'] != null) {
          thumb = json['imagen'] as String;
          imgs = [thumb];
        } else if (json['imagen_principal'] != null) {
          thumb = json['imagen_principal'] as String;
          imgs = [thumb];
        }
      }
    }

    // Stock calculation
    final int stockTotal;
    if (baseData['variantes'] != null &&
        baseData['variantes'] is List &&
        (baseData['variantes'] as List).isNotEmpty) {
      stockTotal = (baseData['variantes'] as List)
          .fold<int>(0, (sum, v) => sum + (v['stock'] as int? ?? 0));
    } else {
      stockTotal = (json['stock'] ?? baseData['stock_total'] ?? 0) as int;
    }

    return ProductoModel(
      id: json['id']?.toString() ?? '',
      nombre: baseData['nombre'] ?? '',
      slug: baseData['slug'] ?? '',
      descripcion: baseData['descripcion'] as String?,
      descripcionLarga: baseData['descripcion_larga'] as String?,
      precioVenta:
          ((json['precio_venta'] ?? baseData['precio_venta']) ?? 0) as int,
      precioOriginal:
          (json['precio_original'] ?? baseData['precio_original']) as int?,
      stockTotal: stockTotal,
      imagenPrincipal: thumb,
      imagenes: imgs,
      variantes:
          (baseData['variantes'] != null && baseData['variantes'] is List)
              ? (baseData['variantes'] as List)
                  .map((v) =>
                      VarianteProductoModel.fromJson(v as Map<String, dynamic>))
                  .toList()
              : [],
      categoriaId: baseData['categoria_id'] as String?,
      marcaId: baseData['marca_id'] as String?,
      sku: (json['sku'] ?? baseData['sku']) as String?,
      genero: baseData['genero'] as String?,
      color: (json['color'] ?? baseData['color']) as String?,
      material: baseData['material'] as String?,
      destacado: (baseData['destacado'] ?? false) as bool,
      activo: ((json['disponible'] ?? baseData['activo']) ?? true) as bool,
      categoria: baseData['categoria'] != null
          ? CategoriaModel.fromJson(
              baseData['categoria'] as Map<String, dynamic>)
          : null,
      marca: baseData['marca'] != null
          ? MarcaModel.fromJson(baseData['marca'] as Map<String, dynamic>)
          : null,
      parentId: isVariant ? baseData['id']?.toString() : null,
      nombreVariante: isVariant ? json['nombre_variante'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'slug': slug,
        'precio_venta': precioVenta,
        'stock_total': stockTotal,
        'imagen': imagenPrincipal,
        'parent_id': parentId,
      };

  // ── Computed getters ────────────────────────────────────────────────────────
  double get precioEnEuros => precioVenta / 100;
  double? get precioOriginalEnEuros =>
      precioOriginal != null ? precioOriginal! / 100 : null;
  bool get tieneStock => stockTotal > 0;
  bool get enOferta => precioOriginal != null && precioOriginal! > precioVenta;

  int? get descuento {
    if (precioOriginal == null || precioOriginal! <= precioVenta) return null;
    return (((precioOriginal! - precioVenta) / precioOriginal!) * 100).round();
  }

  /// Updates the stock of a specific variant and returns a new ProductoModel.
  ProductoModel updateVariantStock(String variantId, int newStock) {
    final updatedVariantes = variantes.map((v) {
      if (v.id == variantId) return v.copyWith(stock: newStock);
      return v;
    }).toList();
    return copyWith(variantes: updatedVariantes);
  }
}
