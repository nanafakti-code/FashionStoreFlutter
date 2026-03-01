import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_store_flutter/app/data/models/devolucion_model.dart';
import 'package:fashion_store_flutter/app/data/services/return_service.dart';
import 'package:fashion_store_flutter/app/data/services/order_service.dart';
import 'package:fashion_store_flutter/app/data/services/invoice_service.dart';
import 'package:fashion_store_flutter/app/providers/services_providers.dart';
import 'package:fashion_store_flutter/app/providers/auth_provider.dart';

final returnsProvider =
    StateNotifierProvider<ReturnNotifier, AsyncValue<List<DevolucionModel>>>(
        (ref) {
  final service = ref.watch(returnServiceProvider);
  final orderService = ref.watch(orderServiceProvider);
  final invoiceService = ref.watch(invoiceServiceProvider);
  final userId = ref.watch(authNotifierProvider).user?.id;
  return ReturnNotifier(service, userId, orderService, invoiceService);
});

class ReturnNotifier extends StateNotifier<AsyncValue<List<DevolucionModel>>> {
  final ReturnService _service;
  final OrderService _orderService;
  final InvoiceService _invoiceService;
  final String? _userId;

  ReturnNotifier(
      this._service, this._userId, this._orderService, this._invoiceService)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadReturns();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadReturns() async {
    if (_userId == null) return;
    try {
      state = const AsyncValue.loading();
      final returns = await _service.getUserReturns(_userId);
      state = AsyncValue.data(returns);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> createReturn(String orderId, String motivo) async {
    try {
      final returnId = await _service.solicitarDevolucion(orderId, motivo);
      if (returnId != null) {
        // Enviar correo de instrucciones
        final dev = await _service.getReturnById(returnId);
        final pedido = await _orderService.getOrderById(orderId);

        if (dev != null && pedido != null) {
          await _invoiceService.sendReturnRequestEmail(pedido, dev);
        }

        if (_userId != null) {
          // Refrescar lista de devoluciones tras insertar
          await loadReturns();
        }
      }
      return returnId;
    } catch (e) {
      print('Error en ReturnNotifier.createReturn: $e');
      return null;
    }
  }
}
