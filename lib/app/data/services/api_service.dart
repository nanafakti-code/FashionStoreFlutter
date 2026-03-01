import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../config/api_config.dart';

class ApiService {
  late Dio _dio;
  final _storage = const FlutterSecureStorage();
  final _uuid = const Uuid();

  ApiService() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor: Estrategia de Sesión (Guest + Auth)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 1. SIEMPRE enviar x-guest-session-id (UUID persistente)
        final guestId = await _getGuestSessionId();
        options.headers['x-guest-session-id'] = guestId;

        // 2. Lógica de Autenticación Selectiva para evitar problemas de CORS en peticiones públicas
        if (options.path.contains('/admin')) {
          if (!options.path.contains('/login')) {
            final adminToken = await _storage.read(key: 'admin_token');
            if (adminToken != null) {
              options.headers['Authorization'] = 'Bearer $adminToken';
            }
          }
        } else if (!options.path.contains('/productos')) {
          // Solo enviamos Auth en cliente si NO es una petición de productos (que son públicas)
          // Esto ayuda a evitar que el pre-vuelo de CORS falle innecesariamente
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
        }

        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Log básico de error
        print(
            '❌ API Error [${e.response?.statusCode}]: ${e.requestOptions.path}');
        if (e.response != null) {
          print('Data: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
  }

  /// Obtiene o genera y persiste el ID de sesión de invitado (UUID v4)
  Future<String> _getGuestSessionId() async {
    String? guestId = await _storage.read(key: 'x-guest-session-id');
    if (guestId == null) {
      guestId = _uuid.v4(); // Generar UUID v4
      await _storage.write(key: 'x-guest-session-id', value: guestId);
    }
    return guestId;
  }

  // Métodos HTTP
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await _dio.delete(path, data: data);
  }
}
