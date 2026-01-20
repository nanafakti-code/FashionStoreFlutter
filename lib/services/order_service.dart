import '../models/pedido.dart';
import '../config/constants.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

/// Servicio de pedidos
class OrderService {
  final SupabaseService _supabase = SupabaseService.instance;
  final AuthService _auth = AuthService();

  // ============================================================
  // CONSULTAS DE PEDIDOS
  // ============================================================

  /// Obtener pedidos del usuario actual
  Future<List<Pedido>> getMisPedidos() async {
    if (!_auth.isAuthenticated) return [];

    try {
      // Primero intentar con la tabla 'ordenes' (nueva estructura)
      final response = await _supabase
          .from(AppConstants.tableOrdenes)
          .select('''
            *,
            items_orden(*)
          ''')
          .eq('usuario_id', _auth.currentUserId!)
          .order('fecha_creacion', ascending: false);

      return (response as List).map((json) => Pedido.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo pedidos: $e');

      // Fallback a tabla 'pedidos' (estructura antigua)
      try {
        final response = await _supabase
            .from(AppConstants.tablePedidos)
            .select('''
              *,
              detalles_pedido(*)
            ''')
            .eq('usuario_id', _auth.currentUserId!)
            .order('fecha_creacion', ascending: false);

        return (response as List).map((json) => Pedido.fromJson(json)).toList();
      } catch (e2) {
        print('Error obteniendo pedidos (fallback): $e2');
        return [];
      }
    }
  }

  /// Obtener pedido por ID
  Future<Pedido?> getPedidoById(String id) async {
    try {
      final response =
          await _supabase.from(AppConstants.tableOrdenes).select('''
            *,
            items_orden(*)
          ''').eq('id', id).single();

      return Pedido.fromJson(response);
    } catch (e) {
      print('Error obteniendo pedido: $e');
      return null;
    }
  }

  /// Obtener pedido por número de orden
  Future<Pedido?> getPedidoByNumero(String numeroOrden) async {
    try {
      final response = await _supabase
          .from(AppConstants.tableOrdenes)
          .select('''
            *,
            items_orden(*)
          ''')
          .or('numero_orden.eq.$numeroOrden,numero_pedido.eq.$numeroOrden')
          .single();

      return Pedido.fromJson(response);
    } catch (e) {
      print('Error obteniendo pedido por número: $e');
      return null;
    }
  }

  // ============================================================
  // SEGUIMIENTO DE PEDIDO
  // ============================================================

  /// Obtener historial de seguimiento
  Future<List<SeguimientoPedido>> getSeguimiento(String pedidoId) async {
    try {
      final response = await _supabase
          .from('seguimiento_pedido')
          .select()
          .eq('pedido_id', pedidoId)
          .order('fecha_actualizacion', ascending: false);

      return (response as List)
          .map((json) => SeguimientoPedido.fromJson(json))
          .toList();
    } catch (e) {
      print('Error obteniendo seguimiento: $e');
      return [];
    }
  }

  // ============================================================
  // ADMIN: GESTIÓN DE PEDIDOS
  // ============================================================

  /// Obtener todos los pedidos (admin)
  Future<List<Pedido>> getTodosPedidos({
    int limit = 50,
    int offset = 0,
    String? estado,
  }) async {
    try {
      dynamic query = _supabase.from(AppConstants.tableOrdenes).select('''
            *,
            items_orden(*)
          ''');

      if (estado != null) {
        query = query.eq('estado', estado);
      }

      final response = await query
          .order('fecha_creacion', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) => Pedido.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo todos los pedidos: $e');
      return [];
    }
  }

  /// Actualizar estado de pedido
  Future<bool> actualizarEstado(String pedidoId, String nuevoEstado) async {
    try {
      await _supabase.from(AppConstants.tableOrdenes).update({
        'estado': nuevoEstado,
        'actualizado_en': DateTime.now().toIso8601String(),
      }).eq('id', pedidoId);

      // Añadir entrada de seguimiento
      await _supabase.from('seguimiento_pedido').insert({
        'pedido_id': pedidoId,
        'estado': nuevoEstado,
        'descripcion': 'Estado actualizado a $nuevoEstado',
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error actualizando estado: $e');
      return false;
    }
  }

  /// Marcar como enviado
  Future<bool> marcarEnviado(String pedidoId, String numeroTracking) async {
    try {
      await _supabase.from(AppConstants.tableOrdenes).update({
        'estado': 'Enviado',
        'fecha_envio': DateTime.now().toIso8601String(),
        'actualizado_en': DateTime.now().toIso8601String(),
      }).eq('id', pedidoId);

      // Añadir entrada de seguimiento
      await _supabase.from('seguimiento_pedido').insert({
        'pedido_id': pedidoId,
        'estado': 'Enviado',
        'numero_tracking': numeroTracking,
        'descripcion': 'Pedido enviado con tracking: $numeroTracking',
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error marcando como enviado: $e');
      return false;
    }
  }

  /// Cancelar pedido
  Future<bool> cancelarPedido(String pedidoId, {String? motivo}) async {
    try {
      await _supabase.from(AppConstants.tableOrdenes).update({
        'estado': 'Cancelado',
        'notas': motivo,
        'actualizado_en': DateTime.now().toIso8601String(),
      }).eq('id', pedidoId);

      // Añadir entrada de seguimiento
      await _supabase.from('seguimiento_pedido').insert({
        'pedido_id': pedidoId,
        'estado': 'Cancelado',
        'descripcion': motivo ?? 'Pedido cancelado',
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error cancelando pedido: $e');
      return false;
    }
  }

  // ============================================================
  // ESTADÍSTICAS (ADMIN)
  // ============================================================

  /// Obtener estadísticas de pedidos
  Future<OrderStats> getEstadisticas() async {
    try {
      final hoy = DateTime.now();
      final inicioMes = DateTime(hoy.year, hoy.month, 1);
      final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);

      // Total de pedidos
      final totalPedidos =
          await _supabase.from(AppConstants.tableOrdenes).select('id').count();

      // Pedidos del mes
      final pedidosMes = await _supabase
          .from(AppConstants.tableOrdenes)
          .select('id, total')
          .gte('fecha_creacion', inicioMes.toIso8601String());

      // Pedidos de hoy
      final pedidosHoy = await _supabase
          .from(AppConstants.tableOrdenes)
          .select('id, total')
          .gte('fecha_creacion', inicioHoy.toIso8601String());

      // Pedidos pendientes
      final pedidosPendientes = await _supabase
          .from(AppConstants.tableOrdenes)
          .select('id')
          .inFilter('estado', ['Pendiente', 'Pagado', 'Confirmado']).count();

      // Calcular totales
      final ventasMes = (pedidosMes as List)
          .fold<int>(0, (sum, p) => sum + (p['total'] as int? ?? 0));
      final ventasHoy = (pedidosHoy as List)
          .fold<int>(0, (sum, p) => sum + (p['total'] as int? ?? 0));

      return OrderStats(
        totalPedidos: totalPedidos.count,
        pedidosMes: (pedidosMes).length,
        pedidosHoy: (pedidosHoy).length,
        pedidosPendientes: pedidosPendientes.count,
        ventasMes: ventasMes,
        ventasHoy: ventasHoy,
      );
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return OrderStats.empty();
    }
  }
}

/// Modelo de seguimiento de pedido
class SeguimientoPedido {
  final String id;
  final String pedidoId;
  final String estado;
  final String? descripcion;
  final String? numeroTracking;
  final String? ubicacion;
  final DateTime fechaActualizacion;

  SeguimientoPedido({
    required this.id,
    required this.pedidoId,
    required this.estado,
    this.descripcion,
    this.numeroTracking,
    this.ubicacion,
    required this.fechaActualizacion,
  });

  factory SeguimientoPedido.fromJson(Map<String, dynamic> json) {
    return SeguimientoPedido(
      id: json['id'] as String,
      pedidoId: json['pedido_id'] as String,
      estado: json['estado'] as String,
      descripcion: json['descripcion'] as String?,
      numeroTracking: json['numero_tracking'] as String?,
      ubicacion: json['ubicacion'] as String?,
      fechaActualizacion: DateTime.parse(json['fecha_actualizacion'] as String),
    );
  }
}

/// Estadísticas de pedidos
class OrderStats {
  final int totalPedidos;
  final int pedidosMes;
  final int pedidosHoy;
  final int pedidosPendientes;
  final int ventasMes;
  final int ventasHoy;

  OrderStats({
    required this.totalPedidos,
    required this.pedidosMes,
    required this.pedidosHoy,
    required this.pedidosPendientes,
    required this.ventasMes,
    required this.ventasHoy,
  });

  factory OrderStats.empty() {
    return OrderStats(
      totalPedidos: 0,
      pedidosMes: 0,
      pedidosHoy: 0,
      pedidosPendientes: 0,
      ventasMes: 0,
      ventasHoy: 0,
    );
  }

  double get ventasMesEnEuros => ventasMes / 100;
  double get ventasHoyEnEuros => ventasHoy / 100;
}
