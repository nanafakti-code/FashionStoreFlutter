import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../models/carrito.dart';
import 'auth_service.dart';

// Importar flutter_stripe solo en plataformas móviles
import 'package:flutter_stripe/flutter_stripe.dart'
    if (dart.library.html) 'stripe_web_stub.dart';

/// Servicio de pagos con Stripe
class StripeService {
  final AuthService _auth = AuthService();

  /// Inicializar Stripe (solo en móvil)
  static Future<void> initialize() async {
    // flutter_stripe no soporta web, solo inicializar en móvil
    if (kIsWeb) {
      print(
          'Stripe: Web platform detected, skipping native SDK initialization');
      return;
    }

    try {
      Stripe.publishableKey = EnvConfig.stripePublishableKey;
      await Stripe.instance.applySettings();
      print('Stripe: Mobile SDK initialized');
    } catch (e) {
      print('Stripe: Error initializing mobile SDK: $e');
    }
  }

  /// Crear sesión de checkout
  /// Llama al endpoint de Astro existente
  Future<CheckoutResult> createCheckoutSession({
    required List<CarritoItem> items,
    required int totalAmount,
    required String email,
    required String nombre,
    String? telefono,
    Map<String, String>? direccion,
    int descuento = 0,
    String? cuponId,
  }) async {
    try {
      // Preparar items para el API
      final itemsData = items
          .map((item) => {
                'producto_id': item.productoId,
                'nombre': item.productoNombre,
                'imagen': item.productoImagen,
                'cantidad': item.cantidad,
                'talla': item.talla,
                'color': item.color,
                'precio_unitario': item.precioUnitario,
              })
          .toList();

      // Llamar al endpoint de Astro
      final response = await http.post(
        Uri.parse('${EnvConfig.appUrl}/api/stripe/create-session'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'totalAmount': totalAmount,
          'userEmail': email,
          'nombre': nombre,
          'telefono': telefono,
          'direccion': direccion,
          'descuento': descuento,
          'cuponId': cuponId,
          'items': itemsData,
          'userId': _auth.currentUserId,
          'isGuest': !_auth.isAuthenticated,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        return CheckoutResult.error(
            error['error'] ?? 'Error al crear la sesión');
      }

      final data = jsonDecode(response.body);

      return CheckoutResult.success(
        sessionId: data['sessionId'],
        url: data['url'],
        orderId: data['orderId'],
        orderNumber: data['orderNumber'],
      );
    } catch (e) {
      print('Error creando sesión de checkout: $e');
      return CheckoutResult.error('Error de conexión: $e');
    }
  }

  /// Abrir Stripe Checkout en navegador/WebView
  Future<bool> openCheckoutUrl(String url) async {
    try {
      // En una app real, abrirías esto en un WebView o navegador
      print('Abriendo URL de Stripe: $url');
      return true;
    } catch (e) {
      print('Error abriendo checkout: $e');
      return false;
    }
  }

  /// Procesar pago con tarjeta (Payment Sheet) - Solo móvil
  Future<PaymentResult> processPayment({
    required int amount,
    required String currency,
    String? customerId,
  }) async {
    // Payment Sheet solo funciona en móvil
    if (kIsWeb) {
      return PaymentResult.error(
        'Payment Sheet no disponible en web. Usa Stripe Checkout URL.',
      );
    }

    try {
      // 1. Configurar Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'FashionStore',
          style: ThemeMode.system,
        ),
      );

      // 2. Mostrar Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      return PaymentResult.success();
    } on StripeException catch (e) {
      return PaymentResult.error(e.error.localizedMessage ?? 'Error de pago');
    } catch (e) {
      return PaymentResult.error('Error inesperado: $e');
    }
  }

  /// Confirmar pago exitoso (callback desde success URL)
  Future<bool> confirmPayment(String sessionId) async {
    try {
      // Verificar el estado del pago con el backend
      final response = await http.get(
        Uri.parse('${EnvConfig.appUrl}/api/stripe/session/$sessionId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'complete' || data['status'] == 'paid';
      }

      return false;
    } catch (e) {
      print('Error confirmando pago: $e');
      return false;
    }
  }
}

/// Resultado de crear checkout
class CheckoutResult {
  final bool success;
  final String? sessionId;
  final String? url;
  final String? orderId;
  final String? orderNumber;
  final String? error;

  CheckoutResult._({
    required this.success,
    this.sessionId,
    this.url,
    this.orderId,
    this.orderNumber,
    this.error,
  });

  factory CheckoutResult.success({
    required String sessionId,
    required String url,
    String? orderId,
    String? orderNumber,
  }) {
    return CheckoutResult._(
      success: true,
      sessionId: sessionId,
      url: url,
      orderId: orderId,
      orderNumber: orderNumber,
    );
  }

  factory CheckoutResult.error(String message) {
    return CheckoutResult._(success: false, error: message);
  }
}

/// Resultado de pago
class PaymentResult {
  final bool success;
  final String? error;
  final String? paymentIntentId;

  PaymentResult._({
    required this.success,
    this.error,
    this.paymentIntentId,
  });

  factory PaymentResult.success({String? paymentIntentId}) {
    return PaymentResult._(
      success: true,
      paymentIntentId: paymentIntentId,
    );
  }

  factory PaymentResult.error(String message) {
    return PaymentResult._(success: false, error: message);
  }
}
