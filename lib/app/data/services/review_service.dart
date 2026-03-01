import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/resena_model.dart';
import '../models/pedido_model.dart';
import '../models/reviewable_item_model.dart';

/// Servicio de Reseñas
class ReviewService {
  final _supabase = Supabase.instance.client;

  /// Obtener reseñas de un producto
  Future<List<ResenaModel>> getProductReviews(String productId) async {
    try {
      final response = await _supabase
          .from('resenas')
          .select('*, usuarios(nombre, avatar_url)')
          .eq('producto_id', productId)
          .eq('estado', 'Aprobada')
          .order('fecha_creacion', ascending: false);
      return (response as List).map((r) => ResenaModel.fromJson(r)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener promedio de calificación de un producto
  Future<Map<String, dynamic>> getProductRating(String productId) async {
    try {
      final response = await _supabase
          .from('resenas')
          .select('calificacion')
          .eq('producto_id', productId)
          .eq('estado', 'Aprobada');

      final reviews = response as List;
      if (reviews.isEmpty) return {'average': 0.0, 'count': 0};

      double total = 0;
      for (final r in reviews) {
        total += (r['calificacion'] as num).toDouble();
      }
      return {
        'average': total / reviews.length,
        'count': reviews.length,
      };
    } catch (e) {
      return {'average': 0.0, 'count': 0};
    }
  }

  /// Obtener elementos susceptibles a recibir una reseña
  Future<List<ReviewableItemModel>> getReviewableItems(String userId) async {
    try {
      // 1. Obtener todas las órdenes completadas/entregadas de este usuario
      final ordersResponse = await _supabase
          .from('ordenes')
          .select('*, items_orden(*)')
          .eq('usuario_id', userId)
          .inFilter('estado',
              ['Completado', 'Entregado']) // Puede ser 'Entregado' en BD
          .order('fecha_creacion', ascending: false);

      final List<PedidoModel> completedOrders =
          (ordersResponse as List).map((o) => PedidoModel.fromJson(o)).toList();

      if (completedOrders.isEmpty) return [];

      // Extraer IDs de las órdenes completadas para filtrar las reseñas
      final orderIds = completedOrders.map((o) => o.id).toList();

      // 2. Obtener las reseñas del usuario que correspondan a estas órdenes
      final reviewsResponse = await _supabase
          .from('resenas')
          .select('*')
          .eq('usuario_id', userId)
          .inFilter('orden_id', orderIds);

      final List<ResenaModel> userReviews = (reviewsResponse as List)
          .map((r) => ResenaModel.fromJson(r))
          .toList();

      // 3. Cruzar productos de los pedidos Entregados con las Reseñas
      List<ReviewableItemModel> reviewableItems = [];

      for (var order in completedOrders) {
        for (var item in order.items) {
          // Check if this specific item in this specific order has a review
          final existingReviewIndex = userReviews.indexWhere(
              (r) => r.productoId == item.productoId && r.ordenId == order.id);

          final resenaExistente = existingReviewIndex >= 0
              ? userReviews[existingReviewIndex]
              : null;

          reviewableItems.add(ReviewableItemModel(
            item: item,
            ordenId: order.id,
            fechaCompra: order.fechaCreacion,
            estaResenado: resenaExistente != null,
            resenaExistente: resenaExistente,
          ));
        }
      }

      return reviewableItems;
    } catch (e) {
      print('Error obteniendo ReviewableItems: $e');
      return [];
    }
  }

  /// Crear reseña (API)
  Future<bool> createReview({
    required String productoId,
    required String usuarioId,
    required String ordenId,
    required int calificacion,
    required String titulo,
    required String comentario,
  }) async {
    try {
      await _supabase.from('resenas').insert({
        'producto_id': productoId,
        'usuario_id': usuarioId,
        'orden_id': ordenId,
        'calificacion': calificacion,
        'titulo': titulo,
        'comentario': comentario,
        'verificada_compra': true,
        'estado': 'Pendiente', // El admin debe validarla si se desea
        'creada_en': DateTime.now().toIso8601String()
      });
      return true;
    } catch (e) {
      print('Error al crear resena: $e');
      return false;
    }
  }

  /// Obtener reseñas del usuario (Histórico Clásico)
  Future<List<ResenaModel>> getUserReviews(String userId) async {
    try {
      final response = await _supabase
          .from('resenas')
          .select('*, productos(nombre)')
          .eq('usuario_id', userId)
          .order('creada_en', ascending: false);
      return (response as List).map((r) => ResenaModel.fromJson(r)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Alias for createReview with parameter names matching the provider
  Future<bool> submitReview({
    required String userId,
    required String productId,
    required String ordenId,
    required int rating,
    required String comment,
  }) {
    return createReview(
      productoId: productId,
      usuarioId: userId,
      ordenId: ordenId,
      calificacion: rating,
      titulo: comment.length > 50 ? comment.substring(0, 50) : comment,
      comentario: comment,
    );
  }
}
