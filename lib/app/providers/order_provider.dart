import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_store_flutter/app/data/models/pedido_model.dart';
import 'package:fashion_store_flutter/app/data/services/order_service.dart';
import 'package:fashion_store_flutter/app/providers/services_providers.dart';

// ── Order State ────────────────────────────────────────────────────────────

class OrderState {
  final List<PedidoModel> orders;
  final PedidoModel? selectedOrder;
  final bool isLoading;
  final String? error;

  const OrderState({
    this.orders = const [],
    this.selectedOrder,
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<PedidoModel>? orders,
    PedidoModel? selectedOrder,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── Order Notifier ─────────────────────────────────────────────────────────

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderService _orderService;

  OrderNotifier(this._orderService) : super(const OrderState());

  Future<void> loadUserOrders(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orders = await _orderService.getUserOrders(userId);
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadOrderDetail(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final order = await _orderService.getOrderById(orderId);
      state = state.copyWith(selectedOrder: order, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<PedidoModel?> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required int subtotal,
    required int total,
    required Map<String, dynamic> shippingAddress,
    String? couponId,
    int? discountAmount,
    String? paymentMethod, // Not used in service currently
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final order = await _orderService.createOrder(
        userId: userId,
        items: items,
        subtotal: subtotal,
        total: total,
        direccionEnvio: shippingAddress,
        cuponId: couponId,
        descuento: discountAmount ?? 0,
        // paymentMethod is handled by payment gateway or status
      );
      if (order != null) {
        state = state.copyWith(
          orders: [order, ...state.orders],
          selectedOrder: order,
          isLoading: false,
        );
      } else {
        state =
            state.copyWith(isLoading: false, error: 'Error al crear el pedido');
      }
      return order;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _orderService.cancelOrder(orderId);
      if (success) {
        // Refresh orders or selected order
        await loadOrderDetail(orderId);
        // Also refresh list if needed, or update local state
        // Simplest is to reload details
      }
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(ref.watch(orderServiceProvider));
});
