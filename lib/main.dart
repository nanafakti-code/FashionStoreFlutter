import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/env_config.dart';
import 'config/app_theme.dart';
import 'config/routes.dart';
import 'services/supabase_service.dart';
import 'services/stripe_service.dart';
import 'services/cart_service.dart';

void main() async {
  // Asegurar inicialización de widgets
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    // Cargar variables de entorno
    await EnvConfig.load();
    print('EnvConfig loaded. Supabase URL: ${EnvConfig.supabaseUrl}');

    // Inicializar servicios
    await SupabaseService.initialize();
    print('Supabase initialized');

    await StripeService.initialize();
    print('Stripe initialized');

    // Inicializar SharedPreferences para carrito de invitados
    final cartService = CartService();
    await cartService.initPrefs();
    print('CartService initialized');

    runApp(const FashionStoreApp());
  } catch (e, stackTrace) {
    print('Error durante inicialización: $e');
    print('Stack trace: $stackTrace');
    // Mostrar app de error
    runApp(ErrorApp(error: e.toString()));
  }
}

class FashionStoreApp extends StatelessWidget {
  const FashionStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FashionStore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}

/// App de error para mostrar cuando falla la inicialización
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Error de Inicialización',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
