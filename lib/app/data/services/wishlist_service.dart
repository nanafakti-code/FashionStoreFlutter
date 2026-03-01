import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio de Lista de Deseos
class WishlistService {
  final _supabase = Supabase.instance.client;

  /// Obtener lista de deseos del usuario
  Future<List<Map<String, dynamic>>> getWishlist(String userId) async {
    try {
      print('⭐ WishlistService: Cargando favoritos para $userId');
      final response = await _supabase
          .from('lista_deseos')
          .select(
              '*, productos(*, categorias(*), marcas(*), imagenes_producto(*))')
          .eq('usuario_id', userId)
          .order('created_at', ascending: false);

      print('⭐ WishlistService: ${response.length} items cargados');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error loading wishlist: $e');
      return [];
    }
  }

  /// Agregar a lista de deseos
  Future<bool> addToWishlist(String userId, String productId) async {
    try {
      print('⭐ WishlistService: Añadiendo $productId a favoritos de $userId');
      await _supabase.from('lista_deseos').insert({
        'usuario_id': userId,
        'producto_id': productId,
      });
      return true;
    } catch (e) {
      print('❌ Error adding to wishlist: $e');
      return false;
    }
  }

  /// Quitar de lista de deseos
  Future<bool> removeFromWishlist(String userId, String productId) async {
    try {
      print('⭐ WishlistService: Eliminando $productId de favoritos de $userId');
      await _supabase
          .from('lista_deseos')
          .delete()
          .eq('usuario_id', userId)
          .eq('producto_id', productId);
      return true;
    } catch (e) {
      print('❌ Error removing from wishlist: $e');
      return false;
    }
  }

  /// Verificar si está en la lista
  Future<bool> isInWishlist(String userId, String productId) async {
    try {
      final response = await _supabase
          .from('lista_deseos')
          .select('id')
          .eq('usuario_id', userId)
          .eq('producto_id', productId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      print('❌ Error checking if in wishlist: $e');
      return false;
    }
  }

  /// Toggle wishlist
  Future<bool> toggleWishlist(String userId, String productId) async {
    final isIn = await isInWishlist(userId, productId);
    if (isIn) {
      return await removeFromWishlist(userId, productId);
    } else {
      return await addToWishlist(userId, productId);
    }
  }
}
