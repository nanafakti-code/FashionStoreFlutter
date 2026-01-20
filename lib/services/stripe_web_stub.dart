// Stub file for flutter_stripe on web
// This file is used when compiling for web to avoid dart:io errors

class Stripe {
  static String publishableKey = '';
  static Stripe get instance => Stripe._();
  Stripe._();

  Future<void> applySettings() async {}

  Future<void> initPaymentSheet({
    required SetupPaymentSheetParameters paymentSheetParameters,
  }) async {}

  Future<void> presentPaymentSheet() async {}
}

class SetupPaymentSheetParameters {
  final String merchantDisplayName;
  final dynamic style;

  SetupPaymentSheetParameters({
    required this.merchantDisplayName,
    this.style,
  });
}

class StripeException implements Exception {
  final StripeError error;
  StripeException(this.error);
}

class StripeError {
  final String? localizedMessage;
  StripeError({this.localizedMessage});
}
