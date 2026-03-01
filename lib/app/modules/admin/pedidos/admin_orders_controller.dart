import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fashion_store_flutter/app/data/services/order_service.dart';
import 'package:fashion_store_flutter/app/data/services/invoice_service.dart';
import 'package:fashion_store_flutter/app/providers/services_providers.dart';
import '../../../data/models/admin_order.dart';

final adminOrdersProvider =
    StateNotifierProvider.autoDispose<AdminOrdersController, AdminOrdersState>(
        (ref) {
  return AdminOrdersController(
    ref.watch(orderServiceProvider),
    ref.watch(invoiceServiceProvider),
  );
});

class AdminOrdersState {
  final bool isLoading;
  final List<AdminOrder> orders;
  final String? error;

  AdminOrdersState({
    this.isLoading = false,
    this.orders = const [],
    this.error,
  });

  AdminOrdersState copyWith({
    bool? isLoading,
    List<AdminOrder>? orders,
    String? error,
  }) {
    return AdminOrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      error: error,
    );
  }
}

class AdminOrdersController extends StateNotifier<AdminOrdersState> {
  final OrderService _orderService;
  final InvoiceService _invoiceService;

  AdminOrdersController(this._orderService, this._invoiceService)
      : super(AdminOrdersState());

  final _supabase = Supabase.instance.client;

  // Estados que pertenecen a Gestión de Devoluciones, no a Gestión de Pedidos
  static const _returnStatuses = [
    'solicitud pendiente',
    'devolucion en proceso',
    'devolucion_en_proceso',
    'solicitud_pendiente',
  ];

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _supabase
          .from('ordenes')
          .select('*, items_orden(*)')
          .order('fecha_creacion', ascending: false);

      final allOrders =
          (response as List).map((e) => AdminOrder.fromJson(e)).toList();

      // Filtrar estados que pertenecen a Devoluciones
      final orders = allOrders
          .where((o) => !_returnStatuses.contains(o.status.toLowerCase()))
          .toList();

      state = state.copyWith(isLoading: false, orders: orders);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateStatus(String id, String newStatus) async {
    try {
      // Usar el servicio para que se aplique la lógica de stock e inmutabilidad
      final success = await _orderService.updateOrderStatus(id, newStatus);

      if (success) {
        // Enviar notificación al usuario
        try {
          final pedido = await _orderService.getOrderById(id);
          if (pedido != null) {
            await _invoiceService.sendOrderStatusUpdateEmail(pedido, newStatus);
          }
        } catch (emailError) {
          print('Error enviando notificación de estado: $emailError');
        }

        await loadOrders();
        return true;
      }
      return false;
    } catch (e) {
      // El error puede ser por intentar cambiar un pedido cancelado
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception: ')) {
        errorMsg = errorMsg.split('Exception: ').last;
      }
      state = state.copyWith(error: errorMsg);
      return false;
    }
  }

  Future<void> deleteOrder(String id) async {
    // Optional: Only if needed.
    try {
      await _supabase.from('ordenes').delete().eq('id', id);
      state = state.copyWith(
        orders: state.orders.where((o) => o.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
