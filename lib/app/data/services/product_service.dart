import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/producto_model.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ProductoModel>> getProducts({
    String? category,
    String? search,
    bool featured = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      debugPrint('🏠 ProductService: Cargando productos desde Supabase...');

      dynamic query = _supabase
          .from('productos')
          .select('*, imagenes_producto(*), variantes:variantes_producto(*)');

      if (category != null) {
        query = query.eq('categoria_id', category);
      }

      if (featured) {
        query = query.eq('destacado', true);
      }

      if (search != null && search.isNotEmpty) {
        query = query.ilike('nombre', '%$search%');
      }

      query = query.order('creado_en', ascending: false);

      final response = await query.range(offset, offset + limit - 1);

      if (response == null) return [];

      final List<dynamic> data = response as List<dynamic>;

      final products =
          data.map((json) => ProductoModel.fromJson(json)).toList();

      debugPrint('🏠 ProductService: ${products.length} productos cargados.');
      return products;
    } catch (e) {
      debugPrint('❌ Error fetching products via Supabase: $e');
      return [];
    }
  }

  /// Shortcut: get featured products
  Future<List<ProductoModel>> getFeaturedProducts({int limit = 10}) {
    return getProducts(featured: true, limit: limit);
  }

  Future<ProductoModel?> getProductById(String id) async {
    try {
      final response = await _supabase
          .from('productos')
          .select('*, imagenes_producto(*), variantes:variantes_producto(*)')
          .eq('id', id)
          .single();

      return ProductoModel.fromJson(response);
    } catch (e) {
      print('❌ Error fetching product by ID: $e');
    }
    return null;
  }

  Future<ProductoModel?> getProductBySlug(String slug) async {
    try {
      final response = await _supabase
          .from('productos')
          .select('*, imagenes_producto(*), variantes:variantes_producto(*)')
          .eq('slug', slug)
          .single();

      return ProductoModel.fromJson(response);
    } catch (e) {
      print('❌ Error fetching product by Slug: $e');
    }
    return null;
  }

  Future<List<CategoriaModel>> getCategories() async {
    try {
      final response = await _supabase.from('categorias').select();
      return (response as List)
          .map((json) => CategoriaModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching categories: $e');
      return [];
    }
  }

  Future<bool> decrementStock(String productId, int quantity,
      {String? variantId}) async {
    try {
      // 1. Update Product Total Stock
      final productRes = await _supabase
          .from('productos')
          .select('stock_total')
          .eq('id', productId)
          .single();
      final int currentStock = productRes['stock_total'] as int;
      final int newStock = (currentStock - quantity).clamp(0, 999999);

      await _supabase
          .from('productos')
          .update({'stock_total': newStock}).eq('id', productId);

      // 2. Update Variant Stock if exists
      if (variantId != null) {
        final variantRes = await _supabase
            .from('variantes_producto')
            .select('stock')
            .eq('id', variantId)
            .single();
        final int currentVariantStock = variantRes['stock'] as int;
        final int newVariantStock =
            (currentVariantStock - quantity).clamp(0, 999999);

        await _supabase
            .from('variantes_producto')
            .update({'stock': newVariantStock}).eq('id', variantId);
      }
      return true;
    } catch (e) {
      debugPrint('❌ Error updating stock: $e');
      return false;
    }
  }

  Future<bool> incrementStock(String productId, int quantity,
      {String? variantId}) async {
    try {
      debugPrint('⬆️ Incrementando stock: Producto $productId, Cant $quantity');

      // 1. Update Product Total Stock
      final productRes = await _supabase
          .from('productos')
          .select('stock_total')
          .eq('id', productId)
          .single();
      final int currentStock = productRes['stock_total'] as int;
      final int newStock = currentStock + quantity;

      await _supabase
          .from('productos')
          .update({'stock_total': newStock}).eq('id', productId);

      // 2. Update Variant Stock if exists
      if (variantId != null) {
        final variantRes = await _supabase
            .from('variantes_producto')
            .select('stock')
            .eq('id', variantId)
            .single();
        final int currentVariantStock = variantRes['stock'] as int;
        final int newVariantStock = currentVariantStock + quantity;

        await _supabase
            .from('variantes_producto')
            .update({'stock': newVariantStock}).eq('id', variantId);
      }
      return true;
    } catch (e) {
      debugPrint('❌ Error incrementing stock: $e');
      return false;
    }
  }

  /// Supabase Realtime Stream for a specific product
  Stream<List<Map<String, dynamic>>> getProductStream(String id) {
    return _supabase.from('productos').stream(primaryKey: ['id']).eq('id', id);
  }

  /// Listen to variant changes too
  Stream<List<Map<String, dynamic>>> getVariantsStream(String productId) {
    return _supabase
        .from('variantes_producto')
        .stream(primaryKey: ['id']).eq('producto_id', productId);
  }

  /// Supabase Realtime Stream for all reservations
  Stream<List<Map<String, dynamic>>> getGlobalReservationsStream() {
    return _supabase.from('reservas_stock').stream(primaryKey: ['id']);
  }

  /// Update or delete a reservation for a user
  Future<void> syncReservation({
    required String userId,
    required String productId,
    String? variantId,
    required int quantity,
  }) async {
    try {
      debugPrint(
          '🔄 Sincronizando reserva: Usuario $userId, Producto $productId, Cantidad $quantity');
      if (quantity <= 0) {
        await _supabase
            .from('reservas_stock')
            .delete()
            .eq('usuario_id', userId)
            .eq('producto_id', productId)
            .filter('variant_id', variantId == null ? 'is' : 'eq', variantId);
      } else {
        // Enlazar COALESCE para la comparación
        final fetchResp = await _supabase
            .from('reservas_stock')
            .select('id')
            .eq('usuario_id', userId)
            .eq('producto_id', productId)
            .filter('variant_id', variantId == null ? 'is' : 'eq', variantId)
            .maybeSingle();

        if (fetchResp != null) {
          // Ya existe, update
          await _supabase.from('reservas_stock').update({
            'cantidad': quantity,
            'actualizado_en': DateTime.now().toIso8601String(),
          }).eq('id', fetchResp['id']);
        } else {
          // No existe, insert
          await _supabase.from('reservas_stock').insert({
            'usuario_id': userId,
            'producto_id': productId,
            'variant_id': variantId,
            'cantidad': quantity,
            'actualizado_en': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      debugPrint(
          '⚠️ Aviso: No se pudo sincronizar la reserva global (posiblemente la tabla no existe todavía): $e');
    }
  }

  /// Clear all reservations for a user
  Future<void> clearUserReservations(String userId) async {
    try {
      await _supabase.from('reservas_stock').delete().eq('usuario_id', userId);
    } catch (e) {
      debugPrint('❌ Error clearing reservations: $e');
    }
  }
}
