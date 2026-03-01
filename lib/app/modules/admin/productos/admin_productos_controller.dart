import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../../../data/models/admin_product.dart';
import '../../../data/models/admin_variant.dart';
import '../../../../config/api_config.dart';
import '../../../data/services/api_service.dart';

// ─── Simple models for dropdowns ──────────────────────────────────────────────
class SimpleCategory {
  final String id;
  final String nombre;
  SimpleCategory({required this.id, required this.nombre});
}

class SimpleBrand {
  final String id;
  final String nombre;
  SimpleBrand({required this.id, required this.nombre});
}

// ─── State ─────────────────────────────────────────────────────────────────────
class AdminProductosState {
  final bool isLoading;
  final bool isSaving;
  final List<AdminProduct> products;
  final List<SimpleCategory> categories;
  final List<SimpleBrand> brands;
  final String? error;
  final String? successMessage;

  const AdminProductosState({
    this.isLoading = false,
    this.isSaving = false,
    this.products = const [],
    this.categories = const [],
    this.brands = const [],
    this.error,
    this.successMessage,
  });

  AdminProductosState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<AdminProduct>? products,
    List<SimpleCategory>? categories,
    List<SimpleBrand>? brands,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminProductosState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      error: clearError ? null : error ?? this.error,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class AdminProductosNotifier extends StateNotifier<AdminProductosState> {
  final ApiService _api;
  final _db = Supabase.instance.client;

  AdminProductosNotifier(this._api) : super(const AdminProductosState());

  // ── Load ─────────────────────────────────────────────────────────────────
  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      print('DEBUG: Loading products from Supabase...');
      final results = await Future.wait([
        _db
            .from('productos')
            .select(
                'id, nombre, descripcion, precio_venta, costo, stock_total, categoria_id, marca_id, sku, activo, creado_en, valoracion_promedio, total_resenas')
            .order('creado_en', ascending: false),
        _db.from('categorias').select('id, nombre').order('nombre'),
        _db.from('marcas').select('id, nombre').order('nombre'),
      ]);

      print('DEBUG: Products loaded: ${(results[0] as List).length}');

      final products =
          (results[0] as List).map((p) => AdminProduct.fromJson(p)).toList();
      final categories = (results[1] as List)
          .map((c) =>
              SimpleCategory(id: c['id'] ?? '', nombre: c['nombre'] ?? ''))
          .toList();
      final brands = (results[2] as List)
          .map((b) => SimpleBrand(id: b['id'] ?? '', nombre: b['nombre'] ?? ''))
          .toList();

      // Fetch first image per product
      final productsWithImages = await _attachImages(products);

      state = state.copyWith(
        isLoading: false,
        products: productsWithImages,
        categories: categories,
        brands: brands,
      );
    } catch (e) {
      print('DEBUG: Error loading products: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<List<AdminProduct>> _attachImages(List<AdminProduct> products) async {
    try {
      final ids = products.map((p) => p.id).toList();
      if (ids.isEmpty) return products;

      final results = await Future.wait([
        // 1. Get images from imagenes_producto
        _db
            .from('imagenes_producto')
            .select('producto_id, url')
            .inFilter('producto_id', ids),
        // 2. Get images from variantes_producto (fallback)
        _db
            .from('variantes_producto')
            .select('producto_id, imagen_url')
            .inFilter('producto_id', ids)
            .not('imagen_url', 'is', null)
      ]);

      // Build map from imagenes_producto
      final Map<String, String> imageMap = {};
      for (final img in results[0] as List) {
        final pid = img['producto_id'] as String;
        if (!imageMap.containsKey(pid)) {
          imageMap[pid] = img['url'] as String;
        }
      }

      // Build map from variants (only if not already in imageMap ideally, but map builder handles it)
      final Map<String, String> variantImageMap = {};
      for (final v in results[1] as List) {
        final pid = v['producto_id'] as String;
        final url = v['imagen_url'] as String?;
        if (url != null && url.isNotEmpty) {
          // We just need one image per product
          if (!variantImageMap.containsKey(pid)) {
            variantImageMap[pid] = url;
          }
        }
      }

      return products.map((p) {
        // Priority: 1. Main image. 2. Variant image. 3. Null
        String? url = imageMap[p.id] ?? variantImageMap[p.id];

        if (url != null && p.imagenUrl == null) {
          return AdminProduct(
            id: p.id,
            nombre: p.nombre,
            descripcion: p.descripcion,
            precioVenta: p.precioVenta,
            costo: p.costo,
            stockTotal: p.stockTotal,
            imagenUrl: url,
            categoriaId: p.categoriaId,
            marcaId: p.marcaId,
            sku: p.sku,
            activo: p.activo,
            creadoEn: p.creadoEn,
            valoracionPromedio: p.valoracionPromedio,
            totalResenas: p.totalResenas,
          );
        }
        return p;
      }).toList();
    } catch (_) {
      return products;
    }
  }

  Future<List<AdminVariant>> loadVariants(String productId) async {
    try {
      final data = await _db
          .from('variantes_producto')
          .select(
              'id, producto_id, talla, color, capacidad, stock, imagen_url, precio_adicional')
          .eq('producto_id', productId)
          .order('capacidad')
          .order('color');
      return (data as List).map((v) => AdminVariant.fromJson(v)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Save (Create / Update) ────────────────────────────────────────────────
  Future<bool> saveProduct({
    required String? id,
    required Map<String, dynamic> data,
    required List<AdminVariant> variants,
    required List<String> variantsToDelete,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final isCreate = id == null;
      String productId = id ?? '';

      // 1. Insert/Update Product
      final productData = {
        'nombre': data['nombre'],
        'slug': data['slug'],
        'descripcion': data['descripcion'],
        'precio_venta': data['precio_venta'],
        'costo': data['costo'],
        // 'imagen_url': data['imagen_url'], // Removed as column doesn't exist
        'categoria_id': data['categoria_id'],
        'marca_id': data['marca_id'],
        'activo': data['activo'],
        'stock_total': variants.fold(0, (sum, v) => sum + v.stock),
        'actualizado_en': DateTime.now().toIso8601String(),
      };

      if (isCreate) {
        // Generate SKU if needed or use slug
        productData['sku'] =
            (data['slug'] as String).toUpperCase().replaceAll('-', '');
        final res =
            await _db.from('productos').insert(productData).select().single();
        productId = res['id'];
      } else {
        await _db.from('productos').update(productData).eq('id', productId);
      }

      // 1.5 Handle Image (Save to imagenes_producto)
      final imgUrl = data['imagen_url'] as String?;
      if (imgUrl != null && imgUrl.isNotEmpty) {
        // For simplicity, delete all images and insert new one
        await _db
            .from('imagenes_producto')
            .delete()
            .eq('producto_id', productId);
        await _db.from('imagenes_producto').insert({
          'producto_id': productId,
          'url': imgUrl,
        });
      }

      // 2. Handle Variants

      // Delete removed variants
      if (variantsToDelete.isNotEmpty) {
        await _db
            .from('variantes_producto')
            .delete()
            .inFilter('id', variantsToDelete);
      }

      // Upsert variants
      for (final v in variants) {
        if (v.pendingDelete) continue;

        final basePrice = data['precio_venta'] as int;
        final finalPrice = basePrice + v.precioAdicional;

        // Generate SKU for variant
        final variantSku =
            '${data['slug']}-${v.color ?? 'NOCOLOR'}-${v.capacidad ?? 'NOCAP'}-${v.talla}'
                .toUpperCase()
                .replaceAll(' ', '');

        final variantData = {
          'producto_id': productId,
          'nombre_variante':
              '${data['nombre']} ${v.color ?? ''} ${v.capacidad ?? ''}'.trim(),
          'sku_variante': variantSku +
              (v.id.startsWith('new_')
                  ? '-${DateTime.now().millisecondsSinceEpoch}'
                  : ''), // Ensure unique on create
          'precio_venta': finalPrice, // Required by schema
          'stock': v.stock,
          'color': v.color,
          'capacidad': v.capacidad,
          'talla': v.talla,
          'imagen_url': v.imagenUrl,
          'precio_adicional': v.precioAdicional,
          // 'stock_minimo': 5, // Default in DB
          'disponible': v.stock > 0,
        };

        if (v.id.startsWith('new_')) {
          // Create
          await _db.from('variantes_producto').insert(variantData);
        } else {
          // Update
          await _db
              .from('variantes_producto')
              .update(variantData)
              .eq('id', v.id);
        }
      }

      // Update total stock in product again just in case?
      // (Already done in step 1 with optimistic calc, but triggers might handle it too)

      state = state.copyWith(
        isSaving: false,
        successMessage:
            'Producto ${isCreate ? 'creado' : 'actualizado'} correctamente',
      );
      await loadAll();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: 'Error al guardar: $e');
      return false;
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<bool> deleteProduct(String id) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      // Direct DB delete (Cascades should handle variants/images if configured, else manual)
      await _db.from('productos').delete().eq('id', id);
      state = state.copyWith(
          isSaving: false, successMessage: 'Producto eliminado correctamente');
      await loadAll();
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Error';
      state = state.copyWith(isSaving: false, error: 'Error al eliminar: $msg');
      return false;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: 'Error al eliminar: $e');
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final adminProductosProvider =
    StateNotifierProvider<AdminProductosNotifier, AdminProductosState>((ref) {
  return AdminProductosNotifier(ApiService());
});
