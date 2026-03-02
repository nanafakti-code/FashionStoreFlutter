import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:fashion_store_flutter/app/data/models/pedido_model.dart';
import 'package:fashion_store_flutter/app/providers/services_providers.dart';
import 'package:fashion_store_flutter/app/providers/cart_provider.dart';
import 'package:fashion_store_flutter/config/stripe_config.dart';

class CheckoutSuccessState {
  final bool isLoading;
  final bool isSuccess;
  final String message;
  final PedidoModel? order;

  const CheckoutSuccessState({
    this.isLoading = true,
    this.isSuccess = false,
    this.message = 'Verificando pago...',
    this.order,
  });

  CheckoutSuccessState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? message,
    PedidoModel? order,
  }) {
    return CheckoutSuccessState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
      order: order ?? this.order,
    );
  }
}

class CheckoutSuccessNotifier extends StateNotifier<CheckoutSuccessState> {
  final Ref ref;

  CheckoutSuccessNotifier(this.ref) : super(const CheckoutSuccessState());

  Future<void> verifyPayment(String sessionId, String orderId) async {
    print(
        '🔍 StripeVerify: Iniciando verificación... Session: $sessionId, Order: $orderId');
    // If already Verified/Success, don't redo
    if (!state.isLoading && state.isSuccess) {
      print('🔍 StripeVerify: Ya verificado anteriormente. Saltando.');
      return;
    }

    // Android Payment Sheet flow: the Stripe SDK already confirmed the payment
    // before navigating here, so there is no checkout session to query.
    // Skip the Stripe API call and mark the order as paid directly.
    if (sessionId == 'pi_success') {
      print('🔍 StripeVerify: Pago con Payment Sheet confirmado. Marcando como pagado.');
      await _confirmOrderAsPaid(orderId, metadata: null);
      return;
    }

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.stripe.com/v1/checkout/sessions/$sessionId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${StripeConfig.secretKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        final paymentStatus = response.data['payment_status'];
        print('🔍 StripeVerify: Respuesta Stripe OK. Status: $paymentStatus');

        if (paymentStatus == 'paid') {
          await _confirmOrderAsPaid(orderId, metadata: response.data['metadata']);
        } else {
          state = state.copyWith(
            isLoading: false,
            isSuccess: false,
            message: 'El pago no se ha completado.',
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          message: 'Error al verificar con Stripe.',
        );
      }
    } catch (e) {
      print('❌ StripeVerify Error: $e');
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  /// Marks the order as paid, clears the cart/reservations, sends the invoice,
  /// and redeems any coupon stored in [metadata].
  Future<void> _confirmOrderAsPaid(String orderId, {Map<String, dynamic>? metadata}) async {
    // 1. Check current order state to avoid duplicate processing
    final preOrder = await ref.read(orderServiceProvider).getOrderById(orderId);
    final isFirstTimePaid = preOrder != null && preOrder.estado != 'Pagado';

    // 2. Update Order Status
    final success = await ref
        .read(orderServiceProvider)
        .updateOrderStatus(orderId, 'Pagado');

    if (success) {
      // Clear Cart Globally (updates UI automatically)
      await ref.read(cartNotifierProvider.notifier).clearCart();

      // Clear Global Reservations
      final userId = metadata?['user_id'];
      if (userId != null) {
        await ref
            .read(productServiceProvider)
            .clearUserReservations(userId.toString());
      }

      // Fetch Final Order Details
      final order = await ref.read(orderServiceProvider).getOrderById(orderId);

      if (order != null && isFirstTimePaid) {
        // Send invoice PDF by email only the first time the order is marked as paid
        ref
            .read(invoiceServiceProvider)
            .generateInvoicePdf(order)
            .then((pdfFile) {
          ref.read(invoiceServiceProvider).sendInvoiceEmail(order, pdfFile);
        }).catchError((e) {
          print('Error enviando factura: $e');
        });
      }

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        message: '¡Pago registrado correctamente!',
        order: order,
      );

      // Redeem Coupon if present in metadata
      if (metadata != null) {
        try {
          if (metadata['coupon_id'] != null) {
            final couponId = int.tryParse(metadata['coupon_id'].toString());
            final uId = metadata['user_id'];
            final discountAmountStr = metadata['discount_amount'];
            double discountAmount = 0.0;
            if (discountAmountStr != null) {
              discountAmount =
                  double.tryParse(discountAmountStr.toString()) ?? 0.0;
            }

            if (couponId != null && uId != null) {
              await ref.read(couponServiceProvider).redeemCoupon(
                    couponId: couponId,
                    userId: uId.toString(),
                    orderId: orderId,
                    discountAmount: discountAmount / 100,
                  );
            }
          }
        } catch (e) {
          print('Error redeeming coupon: $e');
        }
      }
    } else {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        message: 'Pago exitoso, pero error al actualizar el pedido.',
      );
    }
  }
}

final checkoutSuccessNotifierProvider = StateNotifierProvider.autoDispose<
    CheckoutSuccessNotifier, CheckoutSuccessState>((ref) {
  return CheckoutSuccessNotifier(ref);
});

// Helper for cart Service if not Exposed directly:
// In services_providers.dart, cartServiceProvider returns CartService (singleton/provider).
// cartNotifierProvider uses it.
// We can use ref.read(cartServiceProvider) if available.
final cartServiceBaseProvider =
    Provider((ref) => ref.watch(cartServiceProvider));
