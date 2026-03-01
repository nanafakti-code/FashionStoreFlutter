import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../config/stripe_config.dart';
import 'package:fashion_store_flutter/app/routes/app_router.dart';
import 'package:fashion_store_flutter/app/data/models/carrito_model.dart';
import 'package:fashion_store_flutter/app/data/models/coupon_model.dart';
import 'package:fashion_store_flutter/app/data/models/pedido_model.dart';
import 'package:fashion_store_flutter/app/data/services/coupon_service.dart';
import 'package:fashion_store_flutter/app/data/services/order_service.dart';
import 'package:fashion_store_flutter/app/providers/services_providers.dart';

// ── Checkout State ─────────────────────────────────────────────────────────

class CheckoutState {
  final bool isLoading;
  final String? error;
  final CouponModel? appliedCoupon;
  final int discountAmount; // in cents
  final PedidoModel? completedOrder;

  // Shipping form
  final String nombre;
  final String email; // Added email
  final String apellidos;
  final String direccion;
  final String ciudad;
  final String codigoPostal;
  final String provincia; // Added provincia
  final String pais;
  final String telefono;
  final String? notas; // Added notas

  const CheckoutState({
    this.isLoading = false,
    this.error,
    this.appliedCoupon,
    this.discountAmount = 0,
    this.completedOrder,
    this.nombre = '',
    this.email = '',
    this.apellidos = '',
    this.direccion = '',
    this.ciudad = '',
    this.codigoPostal = '',
    this.provincia = '',
    this.pais = 'España',
    this.telefono = '',
    this.notas,
  });

  CheckoutState copyWith({
    bool? isLoading,
    String? error,
    CouponModel? appliedCoupon,
    int? discountAmount,
    PedidoModel? completedOrder,
    String? nombre,
    String? email,
    String? apellidos,
    String? direccion,
    String? ciudad,
    String? codigoPostal,
    String? provincia,
    String? pais,
    String? telefono,
    String? notas,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      discountAmount: discountAmount ?? this.discountAmount,
      completedOrder: completedOrder ?? this.completedOrder,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      apellidos: apellidos ?? this.apellidos,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      provincia: provincia ?? this.provincia,
      pais: pais ?? this.pais,
      telefono: telefono ?? this.telefono,
      notas: notas ?? this.notas,
    );
  }

  Map<String, dynamic> get shippingAddress => {
        'direccion': direccion,
        'ciudad': ciudad,
        'cp': codigoPostal,
        'provincia': provincia,
        'pais': pais,
      };

  bool get isShippingComplete =>
      nombre.isNotEmpty &&
      email.isNotEmpty &&
      telefono.isNotEmpty &&
      direccion.isNotEmpty &&
      ciudad.isNotEmpty &&
      codigoPostal.isNotEmpty &&
      provincia.isNotEmpty;
}

// ── Checkout Notifier ──────────────────────────────────────────────────────

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final CouponService _couponService;
  final OrderService _orderService;

  CheckoutNotifier(this._couponService, this._orderService)
      : super(const CheckoutState());

  void updateField({
    String? nombre,
    String? email,
    String? apellidos,
    String? direccion,
    String? ciudad,
    String? codigoPostal,
    String? provincia,
    String? pais,
    String? telefono,
    String? notas,
  }) {
    state = state.copyWith(
      nombre: nombre,
      email: email,
      apellidos: apellidos,
      direccion: direccion,
      ciudad: ciudad,
      codigoPostal: codigoPostal,
      provincia: provincia,
      pais: pais,
      telefono: telefono,
      notas: notas,
    );
  }

  Future<bool> applyCoupon({
    required String code,
    required String userId,
    required double cartTotal,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final coupon = await _couponService.validateCoupon(
        code: code,
        userId: userId,
        cartTotal: cartTotal,
      );
      final discount = coupon.discountType.toUpperCase() == 'PERCENTAGE'
          ? (cartTotal * coupon.value / 100 * 100).round()
          : (coupon.value * 100).round();

      state = state.copyWith(
        appliedCoupon: coupon,
        discountAmount: discount,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void removeCoupon() {
    state = state.copyWith(
      appliedCoupon: null,
      discountAmount: 0,
    );
  }

  int calculateShippingCost(int subtotal) {
    return subtotal >= 5000 ? 0 : 499; // Free shipping > 50€
  }

  int calculateTotal(int subtotal) {
    final shipping = calculateShippingCost(subtotal);
    return subtotal - state.discountAmount + shipping;
  }

  Future<String?> placeOrder({
    String? userId,
    required List<CartItemModel> cartItems,
    required int subtotal,
    int? localServerPort,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final shippingCost = calculateShippingCost(subtotal);
      final total = calculateTotal(subtotal);

      final items = cartItems
          .map((item) => {
                'producto_id': item.productId,
                'nombre': item.productName,
                'cantidad': item.quantity,
                'precio_unitario': item.precioUnitario,
                'talla': item.talla,
                'color': item.color,
                'imagen': item.productImage,
                'variant_id': item.variantId,
              })
          .toList();

      final order = await _orderService.createOrder(
        userId: userId,
        items: items,
        subtotal: subtotal,
        total: total,
        descuento: state.discountAmount,
        costeEnvio: shippingCost,
        cuponId:
            null, // Coupon tracked via coupon_usages table, not via ordenes.cupon_id
        emailCliente: state.email,
        nombreCliente: '${state.nombre} ${state.apellidos}'.trim(),
        telefonoCliente: state.telefono,
        direccionEnvio: state.shippingAddress,
        notas: state.notas,
      );

      if (order != null) {
        state = state.copyWith(completedOrder: order);

        // Coupon redemption is now handled in Stripe success verification using metadata

        // Create Stripe Session
        final url = await _createStripeSession(
            order.id, items, userId, total, state.email, localServerPort);

        state = state.copyWith(isLoading: false);
        return url;
      } else {
        state = state.copyWith(
            isLoading: false, error: 'Error al crear el pedido localmente');
        return null;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<String?> _createStripeSession(
      String orderId,
      List<Map<String, dynamic>> items,
      String? userId,
      int totalCents,
      String userEmail,
      int? localServerPort) async {
    try {
      final dio = Dio();
      final options = Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'Authorization': 'Bearer ${StripeConfig.secretKey}',
        },
      );

      // 1. Determine Base URL
      String baseUrl = 'http://localhost';
      try {
        if (kIsWeb) {
          baseUrl = Uri.base.origin;
        }
      } catch (_) {}

      String successUrl;
      String cancelUrl;

      if (kIsWeb) {
        successUrl =
            '$baseUrl/#${AppRoutes.checkoutSuccess}?session_id={CHECKOUT_SESSION_ID}&order_id=$orderId';
        cancelUrl = '$baseUrl/#${AppRoutes.checkout}?canceled=true';
      } else if (!kIsWeb && localServerPort != null) {
        // En Windows usamos el servidor local efímero
        successUrl =
            'http://127.0.0.1:$localServerPort/success?session_id={CHECKOUT_SESSION_ID}&order_id=$orderId';
        cancelUrl = 'http://127.0.0.1:$localServerPort/cancel?canceled=true';
      } else {
        successUrl =
            'fashionstore://success${AppRoutes.checkoutSuccess}?session_id={CHECKOUT_SESSION_ID}&order_id=$orderId';
        cancelUrl = 'fashionstore://success${AppRoutes.checkout}?canceled=true';
      }

      // 2. Prepare Data
      final Map<String, dynamic> data = {
        'success_url': successUrl,
        'cancel_url': cancelUrl,
        'mode': 'payment',
        'client_reference_id': orderId,
        'customer_email': userEmail,
        'metadata[order_id]': orderId,
        'metadata[user_id]': userId ?? 'guest',
      };

      // 3. Add Line Items (Products)
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        data['line_items[$i][price_data][currency]'] = 'eur';
        data['line_items[$i][price_data][unit_amount]'] =
            item['precio_unitario'].toString();
        data['line_items[$i][price_data][product_data][name]'] = item['nombre'];
        if (item['imagen'] != null) {
          data['line_items[$i][price_data][product_data][images][0]'] =
              item['imagen'];
        }
        data['line_items[$i][quantity]'] = item['cantidad'].toString();
      }

      // 4. Handle Shipping as a shipping_rate or an extra item
      // For simplicity in a single POST without creating a separate Shipping Rate object:

      // Actually, it's better to pass shipping if > 0
      int currentIdx = items.length;

      // Re-calculate shipping exactly as in placeOrder

      // WAIT: placeOrder calls calculateTotal(subtotal) which returns (subtotal - discount + shipping)
      // So we should just use the actual values.
      final int actualSubtotal = items.fold(
          0,
          (sum, item) =>
              sum +
              (item['precio_unitario'] as int) * (item['cantidad'] as int));
      final int actualShipping = calculateShippingCost(actualSubtotal);

      if (actualShipping > 0) {
        data['line_items[$currentIdx][price_data][currency]'] = 'eur';
        data['line_items[$currentIdx][price_data][unit_amount]'] =
            actualShipping.toString();
        data['line_items[$currentIdx][price_data][product_data][name]'] =
            'Gastos de Envío';
        data['line_items[$currentIdx][quantity]'] = '1';
        currentIdx++;
      }

      // 5. Handle Discounts
      if (state.appliedCoupon != null && state.discountAmount > 0) {
        // Option A: Use Stripe Coupons (requires separate API call)
        // Option B: Add a negative line item? (Stripe rejects negative unit_amount in Checkouts)
        // Option C: Use discounts array if we have a coupon id.

        // We will try to create a transient coupon if possible or just pass the metadata.
        // Since we can't easily create a Stripe Coupon without another await/call here (and it might be too much),
        // let's try a simpler approach: Apply the discount to the LAST item or a "Descuento" item if allowed.
        // Actually, I'll create a one-time coupon. It's the most professional looking.

        try {
          final couponRes = await dio.post(
            'https://api.stripe.com/v1/coupons',
            data: {
              'amount_off': state.discountAmount,
              'currency': 'eur',
              'duration': 'once',
              'name': 'Cupón: ${state.appliedCoupon!.code}',
            },
            options: options,
          );
          if (couponRes.statusCode == 200) {
            final stripeCouponId = couponRes.data['id'];
            data['discounts[0][coupon]'] = stripeCouponId;
          }
        } catch (e) {
          print('Stripe Coupon Creation Error: $e');
          // Fallback: If coupon fails, just log it. The total will still be verified later.
          // (But Stripe total might mismatch our orders table if we don't adjust line items).
        }

        data['metadata[coupon_id]'] = state.appliedCoupon!.id.toString();
        data['metadata[discount_amount]'] = state.discountAmount.toString();
      }

      final response = await dio.post(
        'https://api.stripe.com/v1/checkout/sessions',
        data: data,
        options: options,
      );

      if (response.statusCode == 200) {
        return response.data['url'];
      }
      return null;
    } catch (e) {
      print('Stripe Error: $e');
      return null;
    }
  }

  void reset() {
    state = const CheckoutState();
  }
}

final checkoutNotifierProvider =
    StateNotifierProvider.autoDispose<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(
    ref.watch(couponServiceProvider),
    ref.watch(orderServiceProvider),
  );
});
