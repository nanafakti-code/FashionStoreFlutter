import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

import '../../providers/checkout_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../../config/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_router.dart';
import 'dart:io' show Platform;
import 'widgets/windows_payment_server.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _cpController = TextEditingController();
  final _provinciaController = TextEditingController();
  final _notasController = TextEditingController();
  final _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillUserData();
    });

    // Listeners to update state
    _nombreController.addListener(() => ref
        .read(checkoutNotifierProvider.notifier)
        .updateField(nombre: _nombreController.text));
    _apellidosController.addListener(() => ref
        .read(checkoutNotifierProvider.notifier)
        .updateField(apellidos: _apellidosController.text));
    _emailController.addListener(() => ref
        .read(checkoutNotifierProvider.notifier)
        .updateField(email: _emailController.text));
    _telefonoController.addListener(() => ref
        .read(checkoutNotifierProvider.notifier)
        .updateField(telefono: _telefonoController.text));
    _direccionController.addListener(() => ref
        .read(checkoutNotifierProvider.notifier)
        .updateField(direccion: _direccionController.text));
    _ciudadController.addListener(() => ref
        .read(checkoutNotifierProvider.notifier)
        .updateField(ciudad: _ciudadController.text));
    _cpController.addListener(() => ref
        .read(checkoutNotifierProvider.notifier)
        .updateField(codigoPostal: _cpController.text));
    _provinciaController.addListener(() => ref
        .read(checkoutNotifierProvider.notifier)
        .updateField(provincia: _provinciaController.text));
    _notasController.addListener(() => ref
        .read(checkoutNotifierProvider.notifier)
        .updateField(notas: _notasController.text));
  }

  Future<void> _prefillUserData() async {
    final user = ref.read(authNotifierProvider).user;
    debugPrint(
        '🏠 Checkout: Prefilling for user: ${user?.email} (ID: ${user?.id})');
    if (user != null) {
      // Basic data from Auth
      _emailController.text = user.email;
      _nombreController.text = user.nombre ?? '';
      _apellidosController.text = user.apellidos ?? '';
      _telefonoController.text = user.telefono ?? '';

      // Update provider state for auth basics
      ref.read(checkoutNotifierProvider.notifier).updateField(
            email: user.email,
            nombre: user.nombre ?? '',
            apellidos: user.apellidos ?? '',
            telefono: user.telefono ?? '',
          );

      // Try to get address from Profile
      final profileState = ref.read(profileNotifierProvider);
      if (profileState.addresses.isEmpty) {
        debugPrint('🏠 Checkout: Loading addresses for ${user.id}...');
        await ref.read(profileNotifierProvider.notifier).loadAddresses(user.id);
      }

      final addresses = ref.read(profileNotifierProvider).addresses;
      debugPrint('🏠 Checkout: Found ${addresses.length} addresses total');

      if (addresses.isNotEmpty && mounted) {
        // Prioritize type 'Envío' (with or without accent) and 'esPredeterminada'
        final shippingAddresses = addresses.where((a) {
          final t = a.tipo?.toLowerCase() ?? '';
          return t == 'envío' || t == 'envio' || t == 'ambas';
        }).toList();

        debugPrint(
            '🏠 Checkout: Found ${shippingAddresses.length} shipping-compatible addresses');

        if (shippingAddresses.isEmpty && addresses.isNotEmpty) {
          debugPrint(
              '🏠 Checkout: No specific shipping address found, using any available');
        }

        final address = shippingAddresses.firstWhere(
          (a) => a.esPredeterminada,
          orElse: () => shippingAddresses.isNotEmpty
              ? shippingAddresses.first
              : addresses.firstWhere((a) => a.esPredeterminada,
                  orElse: () => addresses.first),
        );

        debugPrint(
            '🏠 Checkout: Selected address: ${address.direccionCompleta}');

        _direccionController.text =
            '${address.calle} ${address.numero}${address.piso != null && address.piso!.isNotEmpty ? ", ${address.piso}" : ""}';
        _ciudadController.text = address.ciudad;
        _cpController.text = address.codigoPostal;
        _provinciaController.text = address.provincia;

        // Update provider state for address
        ref.read(checkoutNotifierProvider.notifier).updateField(
              direccion: _direccionController.text,
              ciudad: address.ciudad,
              codigoPostal: address.codigoPostal,
              provincia: address.provincia,
            );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _cpController.dispose();
    _provinciaController.dispose();
    _notasController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _processOrder() async {
    final notifier = ref.read(checkoutNotifierProvider.notifier);
    final cartState = ref.read(cartNotifierProvider);
    final user = ref.read(authNotifierProvider).user;

    int? localPort;
    if (!kIsWeb && Platform.isWindows) {
      localPort = await WindowsPaymentServer.start();
    }

    final url = await notifier.placeOrder(
      userId: user?.id,
      cartItems: cartState.items,
      subtotal: (cartState.totalEuros * 100).round(),
      localServerPort: localPort,
    );

    if (url != null) {
      if (url.startsWith('android_pi:')) {
        final clientSecret = url.substring('android_pi:'.length);
        try {
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: clientSecret,
              merchantDisplayName: 'Fashion Store',
            ),
          );
          await Stripe.instance.presentPaymentSheet();

          if (mounted) {
            final completedOrder =
                ref.read(checkoutNotifierProvider).completedOrder;
            if (completedOrder != null) {
              context.go(
                  '${AppRoutes.checkoutSuccess}?session_id=pi_success&order_id=${completedOrder.id}');
            }
          }
        } catch (e) {
          if (mounted) {
            String errorMsg = 'Pago cancelado o fallido';
            if (e is StripeException) {
              errorMsg = e.error.localizedMessage ?? errorMsg;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMsg)),
            );
          }
        }
      } else if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: kIsWeb
              ? LaunchMode.platformDefault
              : LaunchMode.externalApplication,
          webOnlyWindowName: kIsWeb ? '_self' : null,
        );

        if (!kIsWeb && Platform.isWindows) {
          // Esperamos a que Stripe redirija al navegador a nuestro localhost
          final redirectUrl = await WindowsPaymentServer.waitForRedirect();

          if (redirectUrl != null) {
            final uri = Uri.parse(redirectUrl);
            if (uri.path.contains('success') && mounted) {
              context.go('${AppRoutes.checkoutSuccess}?${uri.query}');
            } else if (uri.path.contains('cancel') && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pago cancelado')),
              );
            }
          }
        }
      } else {
        WindowsPaymentServer.stop();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No se pudo abrir la pasarela de pago')),
          );
        }
      }
    } else {
      WindowsPaymentServer.stop();
      if (mounted) {
        final error = ref.read(checkoutNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Error al procesar el pedido')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutNotifierProvider);
    // Maintain profile provider alive during checkout to avoid dispose issues
    ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Compra')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 2) {
            _processOrder();
          } else {
            // Validate step 0
            if (_currentStep == 0 && !state.isShippingComplete) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Por favor completa todos los campos obligatorios')),
              );
              return;
            }
            _nextStep();
          }
        },
        onStepCancel: _currentStep > 0 ? _previousStep : null,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: state.isLoading ? null : details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: state.isLoading && _currentStep == 2
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          _currentStep == 2 ? 'Confirmar Pedido' : 'Continuar',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Atrás')),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Datos de Envío'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _buildShippingForm(),
          ),
          Step(
            title: const Text('Cupón de Descuento'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _buildCouponSection(state),
          ),
          Step(
            title: const Text('Resumen'),
            isActive: _currentStep >= 2,
            content: _buildOrderSummary(state),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingForm() {
    return Column(
      children: [
        _buildLabeledTextField(
          controller: _nombreController,
          label: 'Nombre *',
          icon: Icons.person,
        ),
        const SizedBox(height: 12),
        _buildLabeledTextField(
          controller: _apellidosController,
          label: 'Apellidos *',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _buildLabeledTextField(
          controller: _emailController,
          label: 'Email *',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _buildLabeledTextField(
          controller: _telefonoController,
          label: 'Teléfono *',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildLabeledTextField(
          controller: _direccionController,
          label: 'Dirección *',
          icon: Icons.home,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLabeledTextField(
                controller: _ciudadController,
                label: 'Ciudad *',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLabeledTextField(
                controller: _cpController,
                label: 'C.P. *',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildLabeledTextField(
          controller: _provinciaController,
          label: 'Provincia *',
        ),
        const SizedBox(height: 12),
        _buildLabeledTextField(
          controller: _notasController,
          label: 'Notas (opcional)',
          icon: Icons.note,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildLabeledTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.charcoal),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          floatingLabelStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            backgroundColor: Colors.white,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildCouponSection(CheckoutState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return TextEditingValue(
                      text: newValue.text.toUpperCase(),
                      selection: newValue.selection,
                    );
                  }),
                ],
                decoration: const InputDecoration(
                  labelText: 'Código de cupón',
                  prefixIcon: Icon(Icons.discount),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                final user = ref.read(authNotifierProvider).user;
                final cartTotal = ref.read(cartNotifierProvider).totalEuros;

                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Inicia sesión')));
                  return;
                }

                final success = await ref
                    .read(checkoutNotifierProvider.notifier)
                    .applyCoupon(
                      code: _couponController.text,
                      userId: user.id,
                      cartTotal: cartTotal,
                    );

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Cupón aplicado: -${(ref.read(checkoutNotifierProvider).discountAmount / 100).toStringAsFixed(2)}€')));
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ref.read(checkoutNotifierProvider).error ??
                          'Cupón inválido')));
                }
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
        if (state.appliedCoupon != null) ...[
          const SizedBox(height: 12),
          Card(
            color: AppColors.cream,
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: AppColors.success),
              title: Text('Cupón: ${state.appliedCoupon!.code}'),
              subtitle:
                  Text('-${(state.discountAmount / 100).toStringAsFixed(2)}€'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(checkoutNotifierProvider.notifier).removeCoupon();
                  _couponController.clear();
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderSummary(CheckoutState state) {
    final cartState = ref.watch(cartNotifierProvider);
    final subtotal = (cartState.totalEuros * 100).round();
    final notifier = ref.read(checkoutNotifierProvider.notifier);
    final shippingCost = notifier.calculateShippingCost(subtotal);
    final total = notifier.calculateTotal(subtotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Items
        ...cartState.items.map((item) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(item.productName,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('x${item.quantity} ${[
                item.talla,
                item.color
              ].where((e) => e != null && e.isNotEmpty).join(" - ")}'),
              trailing: Text(
                  '${(item.precioUnitario * item.quantity / 100).toStringAsFixed(2)}€'),
            )),
        const Divider(),
        _summaryRow('Subtotal', subtotal),
        if (state.discountAmount > 0)
          _summaryRow('Descuento', -state.discountAmount),
        _summaryRow('Envío', shippingCost,
            note: shippingCost == 0 ? 'Gratis' : null),
        const Divider(thickness: 2),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${(total / 100).toStringAsFixed(2)}€',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ],
          ),
        ),
        // Shipping info
        if (state.isShippingComplete) ...[
          const Divider(),
          const Text('Envío a:', style: TextStyle(fontWeight: FontWeight.w500)),
          Text(
              '${state.nombre} ${state.apellidos}\n${state.direccion}\n${state.codigoPostal} ${state.ciudad}\n${state.email}',
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ],
    );
  }

  Widget _summaryRow(String label, int amountCents, {String? note}) {
    final isNeg = amountCents < 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            note ??
                '${isNeg ? "-" : ""}${(amountCents.abs() / 100).toStringAsFixed(2)}€',
            style: TextStyle(
              color: isNeg ? AppColors.success : null,
              fontWeight: note != null ? FontWeight.w500 : null,
            ),
          ),
        ],
      ),
    );
  }
}
