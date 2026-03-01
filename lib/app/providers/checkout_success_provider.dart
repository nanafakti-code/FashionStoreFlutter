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
          // 1. Consultar estado actual antes de actualizar
          final preOrder =
              await ref.read(orderServiceProvider).getOrderById(orderId);
          final isFirstTimePaid =
              preOrder != null && preOrder.estado != 'Pagado';

          // 2. Update Order Status
          final success = await ref
              .read(orderServiceProvider)
              .updateOrderStatus(orderId, 'Pagado');
          if (success) {
            // Clear Cart Globally (updates UI automatically)
            await ref.read(cartNotifierProvider.notifier).clearCart();

            // Clear Global Reservations
            final userId = response.data['metadata']?['user_id'];
            if (userId != null) {
              await ref
                  .read(productServiceProvider)
                  .clearUserReservations(userId.toString());
            }

            // Fetch Final Order Details
            final order =
                await ref.read(orderServiceProvider).getOrderById(orderId);

            if (order != null && isFirstTimePaid) {
              // Enviar factura PDF por email SOLO si es la primera vez que se marca como pagado
              ref
                  .read(invoiceServiceProvider)
                  .generateInvoicePdf(order)
                  .then((pdfFile) {
                ref
                    .read(invoiceServiceProvider)
                    .sendInvoiceEmail(order, pdfFile);
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
            try {
              final metadata = response.data['metadata'];
              if (metadata != null && metadata['coupon_id'] != null) {
                final couponId = int.tryParse(metadata['coupon_id'].toString());
                final uId = metadata['user_id']; // Changed userId to uId
                // discount_amount in metadata is in cents (String), redeemCoupon expects Amount (Euros or logic?)
                // Controller passed: discountAmount (double from metadata)
                // Service redeemCoupon: discountAmount

                final discountAmountStr = metadata['discount_amount'];
                double discountAmount = 0.0;
                if (discountAmountStr != null) {
                  discountAmount =
                      double.tryParse(discountAmountStr.toString()) ?? 0.0;
                }

                if (couponId != null && uId != null) {
                  // Changed userId to uId
                  // Note: discountAmount in metadata is total cents.
                  // Service redeemCoupon expects... amount?
                  // Controller passed it directly. Let's assume service handles it or we convert.
                  // Viewing CheckoutController, it passed `state.discountAmount / 100` (Euros).
                  // Here we have it in cents (from CheckoutNotifier metadata).
                  // So we should divide by 100.

                  await ref.read(couponServiceProvider).redeemCoupon(
                        couponId: couponId,
                        userId: uId.toString(), // Changed userId to uId
                        orderId: orderId,
                        discountAmount: discountAmount / 100,
                      );
                }
              }
            } catch (e) {
              print('Error redeeming coupon: $e');
            }
          } else {
            state = state.copyWith(
              isLoading: false,
              isSuccess: false,
              message: 'Pago exitoso, pero error al actualizar el pedido.',
            );
          }
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
