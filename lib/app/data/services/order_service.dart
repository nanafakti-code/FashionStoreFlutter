import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pedido_model.dart';
import './product_service.dart';

/// Servicio de Pedidos
class OrderService {
  final _supabase = Supabase.instance.client;
  final _productService = ProductService();

  /// Crear pedido con transacción atómica en Supabase
  Future<PedidoModel?> createOrder({
    String? userId,
    required List<Map<String, dynamic>> items,
    required int subtotal,
    required int total,
    int impuestos = 0,
    int descuento = 0,
    int costeEnvio = 0,
    String? cuponId,
    String? emailCliente,
    String? nombreCliente,
    String? telefonoCliente,
    Map<String, dynamic>? direccionEnvio,
    String? notas,
  }) async {
    try {
      // 1. Preparar lista de items para el RPC de Supabase
      final pItems = items
          .map((item) => {
                'producto_id': item['producto_id'],
                'variant_id': item['variant_id'], // Puede ser nulo
                'cantidad': item['cantidad'],
                'precio_unitario': item['precio_unitario'],
                'nombre': item['nombre'],
                'imagen': item['imagen'],
                'talla': item['talla'],
                'color': item['color']
              })
          .toList();

      // 2. Llamada atómica a la DB
      final response = await _supabase.rpc('checkout_atomic', params: {
        'p_usuario_id': userId,
        'p_subtotal': subtotal,
        'p_total': total,
        'p_impuestos': impuestos,
        'p_descuento': descuento,
        'p_coste_envio': costeEnvio,
        'p_cupon_id': cuponId,
        'p_email_cliente': emailCliente,
        'p_nombre_cliente': nombreCliente,
        'p_telefono_cliente': telefonoCliente,
        'p_direccion_envio': direccionEnvio,
        'p_notas': notas,
        'p_items': pItems,
      });

      return PedidoModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.message.startsWith('STOCK_INSUFFICIENTE')) {
        final parts = e.message.split(':');
        final itemName = parts.length >= 3 ? parts[2] : 'un producto';
        throw Exception('Stock insuficiente para el producto: $itemName');
      } else if (e.message.startsWith('VARIANTE_NO_ENCONTRADA') ||
          e.message.startsWith('PRODUCTO_NO_ENCONTRADO')) {
        throw Exception('Uno de los productos ya no está disponible.');
      }
      print('Error DB createOrder: ${e.message}');
      throw Exception('Error al procesar el pedido. Inténtelo de nuevo.');
    } catch (e) {
      print('Error interno al crear order: $e');
      throw Exception('Error inesperado al generar el pedido.');
    }
  }

  /// Obtener pedidos del usuario
  Future<List<PedidoModel>> getUserOrders(String userId) async {
    try {
      final response = await _supabase
          .from('ordenes')
          .select('*, items_orden(*)')
          .eq('usuario_id', userId)
          .order('fecha_creacion', ascending: false);

      return (response as List).map((o) => PedidoModel.fromJson(o)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  /// Asociar pedidos de invitado a un usuario recién registrado/logueado
  Future<void> associateGuestOrders(String userId, String email) async {
    try {
      await _supabase
          .from('ordenes')
          .update({'usuario_id': userId})
          .eq('email_cliente', email)
          .filter('usuario_id', 'is', null);
    } catch (e) {
      print('Error asociando pedidos de invitado: $e');
    }
  }

  /// Obtener pedido por ID
  Future<PedidoModel?> getOrderById(String orderId) async {
    try {
      final response = await _supabase
          .from('ordenes')
          .select('*, items_orden(*)')
          .eq('id', orderId)
          .single();

      return PedidoModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Cancelar pedido
  Future<bool> cancelOrder(String orderId) async {
    try {
      await _supabase
          .from('ordenes')
          .update({'estado': 'Cancelado'}).eq('id', orderId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener todos los pedidos (admin)
  Future<List<PedidoModel>> getAllOrders(
      {String? estado, int limit = 50}) async {
    try {
      var query = _supabase.from('ordenes').select('*, items_orden(*)');

      if (estado != null && estado.isNotEmpty) {
        query = query.eq('estado', estado);
      }

      final response =
          await query.order('fecha_creacion', ascending: false).limit(limit);

      return (response as List).map((o) => PedidoModel.fromJson(o)).toList();
    } catch (e) {
      print('Error fetching all orders: $e');
      return [];
    }
  }

  /// Actualizar estado de pedido (admin)
  Future<bool> updateOrderStatus(String orderId, String nuevoEstado) async {
    try {
      // 1. Obtener estado actual
      final currentOrder = await getOrderById(orderId);
      if (currentOrder == null) return false;

      // 2. Regla de inmutabilidad: Si ya está cancelado, no se puede cambiar
      if (currentOrder.estado == 'Cancelado') {
        throw Exception(
            'No se puede cambiar el estado de un pedido ya cancelado.');
      }

      // 3. Regla de stock: Si se cambia a Cancelado, reponer stock
      if (nuevoEstado == 'Cancelado') {
        for (var item in currentOrder.items) {
          await _productService.incrementStock(
            item.productoId,
            item.cantidad,
            variantId: item.variantId,
          );
        }
      }

      await _supabase
          .from('ordenes')
          .update({'estado': nuevoEstado}).eq('id', orderId);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
