import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';

/// Servicio singleton de Supabase
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Cliente de Supabase
  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
          'Supabase no inicializado. Llama a initialize() primero.');
    }
    return _client!;
  }

  /// Inicializar Supabase
  static Future<void> initialize() async {
    if (_client != null) return;

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );

    _client = Supabase.instance.client;
  }

  /// Acceso directo al cliente de autenticación
  GoTrueClient get auth => client.auth;

  /// Usuario actual
  User? get currentUser => auth.currentUser;

  /// Sesión actual
  Session? get currentSession => auth.currentSession;

  /// Está autenticado
  bool get isAuthenticated => currentUser != null;

  /// Stream de cambios de autenticación
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  // ============================================================
  // HELPERS DE QUERIES
  // ============================================================

  /// Query a una tabla
  SupabaseQueryBuilder from(String table) => client.from(table);

  /// Ejecutar RPC (función de Postgres)
  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) {
    return client.rpc(functionName, params: params);
  }

  // ============================================================
  // STORAGE
  // ============================================================

  /// Obtener URL pública de un archivo
  String getPublicUrl(String bucket, String path) {
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Subir archivo
  Future<String?> uploadFile(
    String bucket,
    String path,
    List<int> bytes, {
    String? contentType,
  }) async {
    try {
      await client.storage.from(bucket).uploadBinary(
            path,
            bytes as dynamic,
            fileOptions: FileOptions(contentType: contentType),
          );
      return getPublicUrl(bucket, path);
    } catch (e) {
      print('Error subiendo archivo: $e');
      return null;
    }
  }

  /// Eliminar archivo
  Future<bool> deleteFile(String bucket, String path) async {
    try {
      await client.storage.from(bucket).remove([path]);
      return true;
    } catch (e) {
      print('Error eliminando archivo: $e');
      return false;
    }
  }
}
