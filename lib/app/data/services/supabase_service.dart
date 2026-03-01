import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static late final SupabaseClient _client;

  static SupabaseClient get client => _client;

  /// Inicializar Supabase
  static Future<void> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseKey == null) {
      throw Exception('Supabase credentials not found in .env');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );

    _client = Supabase.instance.client;
  }

  /// Obtener tabla
  static SupabaseQueryBuilder from(String table) {
    return _client.from(table);
  }

  /// Obtener usuario autenticado
  static User? get authUser {
    return _client.auth.currentUser;
  }

  /// Stream de autenticación
  static Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  /// Cerrar sesión
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
