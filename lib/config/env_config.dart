import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de variables de entorno
class EnvConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get appUrl => dotenv.env['APP_URL'] ?? 'http://localhost:4321';

  /// Valida que las variables críticas estén configuradas
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      stripePublishableKey.isNotEmpty;

  /// Carga las variables de entorno
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }
}
