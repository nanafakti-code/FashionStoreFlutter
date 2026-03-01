import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'email_service.dart';

/// Servicio de Autenticación — Supabase Auth (plain Dart, no GetX)
class AuthService {
  final _supabase = Supabase.instance.client;
  final _secureStorage = const FlutterSecureStorage();

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => _supabase.auth.currentUser != null;
  String? get userId => _supabase.auth.currentUser?.id;
  String? get userEmail => _supabase.auth.currentUser?.email;
  String get accessToken => _supabase.auth.currentSession?.accessToken ?? '';

  /// Stream of auth state changes — used by authStateProvider
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Login con email y contraseña
  Future<AuthResponse> login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  /// Registro con email y contraseña
  Future<AuthResponse> register({
    required String email,
    required String password,
    String? nombre,
    String? apellidos,
    String? telefono,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email.trim(),
      password: password.trim(),
      data: {
        'nombre': nombre,
        'apellidos': apellidos,
        'telefono': telefono,
      },
    );

    if (response.user != null) {
      await _supabase.from('usuarios').upsert({
        'id': response.user!.id,
        'email': email.trim(),
        'nombre': nombre ?? '',
        'apellidos': apellidos ?? '',
        'telefono': telefono ?? '',
        'activo': true,
        'verificado': false,
      });

      // Enviar correo de bienvenida
      await EmailService().sendWelcomeEmail(
        toEmail: email.trim(),
        nombre: nombre,
      );
    }

    return response;
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await _supabase.auth.signOut();
    await _secureStorage.delete(key: 'admin_token');
  }

  /// Recuperar contraseña
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email.trim());
  }

  /// Actualizar contraseña (usuario logueado)
  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Obtener perfil del usuario actual
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;
    final response = await _supabase
        .from('usuarios')
        .select()
        .eq('email', currentUser!.email!)
        .maybeSingle();
    return response;
  }

  /// Actualizar perfil
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (currentUser == null) return;
    await _supabase
        .from('usuarios')
        .update(data)
        .eq('email', currentUser!.email!);
  }

  /// Login admin
  Future<bool> adminLogin(String email, String password) async {
    try {
      final response = await _supabase
          .from('admin_credentials')
          .select()
          .eq('email', email.trim())
          .eq('password', password.trim())
          .maybeSingle();

      if (response != null) {
        await _secureStorage.write(key: 'admin_token', value: email.trim());
        return true;
      }
      return false;
    } catch (e) {
      print('Error admin login: $e');
      return false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email.trim());
  }
}
