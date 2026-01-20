import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario.dart';
import 'supabase_service.dart';

/// Servicio de autenticación
class AuthService {
  final SupabaseService _supabase = SupabaseService.instance;

  // ============================================================
  // ESTADO DE AUTENTICACIÓN
  // ============================================================

  /// Usuario actual
  User? get currentUser => _supabase.currentUser;

  /// Está autenticado
  bool get isAuthenticated => _supabase.isAuthenticated;

  /// ID del usuario actual
  String? get currentUserId => currentUser?.id;

  /// Email del usuario actual
  String? get currentUserEmail => currentUser?.email;

  /// Stream de cambios de autenticación
  Stream<AuthState> get authStateChanges => _supabase.authStateChanges;

  // ============================================================
  // LOGIN / REGISTRO
  // ============================================================

  /// Login con email y contraseña
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.error('No se pudo iniciar sesión');
      }

      // Actualizar último acceso
      await _updateLastAccess(response.user!.id);

      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      return AuthResult.error(_translateAuthError(e.message));
    } catch (e) {
      return AuthResult.error('Error inesperado: $e');
    }
  }

  /// Registro con email y contraseña
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String nombre,
    String? apellidos,
    String? telefono,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nombre': nombre,
          'apellidos': apellidos,
          'telefono': telefono,
        },
      );

      if (response.user == null) {
        return AuthResult.error('No se pudo crear la cuenta');
      }

      // Crear perfil en tabla usuarios
      await _createUserProfile(
        userId: response.user!.id,
        email: email,
        nombre: nombre,
        apellidos: apellidos,
        telefono: telefono,
      );

      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      return AuthResult.error(_translateAuthError(e.message));
    } catch (e) {
      return AuthResult.error('Error inesperado: $e');
    }
  }

  /// Login con Google
  Future<bool> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.fashionstore://login-callback/',
      );
      return true;
    } catch (e) {
      print('Error Google Sign In: $e');
      return false;
    }
  }

  /// Login con Apple
  Future<bool> signInWithApple() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.fashionstore://login-callback/',
      );
      return true;
    } catch (e) {
      print('Error Apple Sign In: $e');
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ============================================================
  // RECUPERACIÓN DE CONTRASEÑA
  // ============================================================

  /// Enviar email de recuperación
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      print('Error enviando email de recuperación: $e');
      return false;
    }
  }

  /// Cambiar contraseña
  Future<bool> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      print('Error cambiando contraseña: $e');
      return false;
    }
  }

  // ============================================================
  // PERFIL DE USUARIO
  // ============================================================

  /// Obtener perfil del usuario actual
  Future<Usuario?> getCurrentUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final response = await _supabase
          .from('usuarios')
          .select()
          .eq('id', currentUserId!)
          .maybeSingle();

      if (response == null) return null;
      return Usuario.fromJson(response);
    } catch (e) {
      print('Error obteniendo perfil: $e');
      return null;
    }
  }

  /// Actualizar perfil
  Future<bool> updateProfile({
    String? nombre,
    String? apellidos,
    String? telefono,
    String? genero,
    DateTime? fechaNacimiento,
  }) async {
    if (!isAuthenticated) return false;

    try {
      final updates = <String, dynamic>{
        'actualizado_en': DateTime.now().toIso8601String(),
      };

      if (nombre != null) updates['nombre'] = nombre;
      if (apellidos != null) updates['apellidos'] = apellidos;
      if (telefono != null) updates['telefono'] = telefono;
      if (genero != null) updates['genero'] = genero;
      if (fechaNacimiento != null) {
        updates['fecha_nacimiento'] = fechaNacimiento.toIso8601String();
      }

      await _supabase.from('usuarios').update(updates).eq('id', currentUserId!);

      return true;
    } catch (e) {
      print('Error actualizando perfil: $e');
      return false;
    }
  }

  // ============================================================
  // HELPERS PRIVADOS
  // ============================================================

  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String nombre,
    String? apellidos,
    String? telefono,
  }) async {
    try {
      await _supabase.from('usuarios').insert({
        'id': userId,
        'email': email,
        'nombre': nombre,
        'apellidos': apellidos,
        'telefono': telefono,
        'activo': true,
        'verificado': false,
        'fecha_registro': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Si el usuario ya existe, ignorar el error
      print('Error creando perfil (puede que ya exista): $e');
    }
  }

  Future<void> _updateLastAccess(String userId) async {
    try {
      await _supabase.from('usuarios').update({
        'ultimo_acceso': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      print('Error actualizando último acceso: $e');
    }
  }

  String _translateAuthError(String message) {
    final translations = {
      'Invalid login credentials': 'Email o contraseña incorrectos',
      'Email not confirmed': 'Confirma tu email antes de iniciar sesión',
      'User already registered': 'Este email ya está registrado',
      'Password should be at least 6 characters':
          'La contraseña debe tener al menos 6 caracteres',
      'Unable to validate email address: invalid format':
          'El formato del email no es válido',
    };

    return translations[message] ?? message;
  }
}

/// Resultado de autenticación
class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult._({required this.success, this.user, this.error});

  factory AuthResult.success(User user) {
    return AuthResult._(success: true, user: user);
  }

  factory AuthResult.error(String message) {
    return AuthResult._(success: false, error: message);
  }
}
