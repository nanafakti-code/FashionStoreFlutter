import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fashion_store_flutter/app/data/models/usuario_model.dart';
import 'package:fashion_store_flutter/app/data/services/auth_service.dart';
import 'package:fashion_store_flutter/app/data/services/order_service.dart';
import 'package:fashion_store_flutter/app/providers/services_providers.dart';

// ── Auth State ─────────────────────────────────────────────────────────────

/// Exposes the raw Supabase auth state stream.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Convenience: current Supabase User (nullable).
final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

/// Whether the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// ── Auth Controller ────────────────────────────────────────────────────────

class AuthState2 {
  final UsuarioModel? user;
  final bool isLoading;
  final String? error;

  const AuthState2({this.user, this.isLoading = false, this.error});

  AuthState2 copyWith({UsuarioModel? user, bool? isLoading, String? error}) {
    return AuthState2(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState2> {
  final AuthService _authService;
  final OrderService _orderService;

  AuthNotifier(this._authService, this._orderService)
      : super(const AuthState2()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final userProfile = await _authService.getUserProfile();
      if (userProfile != null) {
        state = state.copyWith(
            user: UsuarioModel.fromJson(userProfile), isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> adminLogin(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _authService.adminLogin(email, password);
      if (success) {
        // Manually set admin user since we bypass standard auth
        state = state.copyWith(
          isLoading: false,
          user: UsuarioModel(
            id: 'admin-session',
            email: email,
            rol: 'admin',
            nombre: 'Administrador',
          ),
        );
        return true;
      }
      state = state.copyWith(
          isLoading: false, error: 'Credenciales de administrador inválidas');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.login(email, password);
      if (response.user != null) {
        // Fetch full profile after login
        final userProfile = await _authService.getUserProfile();
        if (userProfile != null) {
          // Associate guest orders by email
          await _orderService.associateGuestOrders(userProfile['id'], email);

          state = state.copyWith(
              user: UsuarioModel.fromJson(userProfile), isLoading: false);
          return true;
        }
      }
      state = state.copyWith(isLoading: false, error: 'Login failed');
      return false;
    } on AuthException catch (e) {
      String errorMessage = 'Error al iniciar sesión';
      if (e.message.contains('Invalid login credentials')) {
        errorMessage = 'Correo o contraseña incorrectos.';
      } else {
        errorMessage = e.message;
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          error: 'Ocurrió un error inesperado al iniciar sesión.');
      return false;
    }
  }

  Future<bool> register(String email, String password, String nombre,
      String apellidos, String telefono) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.register(
          email: email,
          password: password,
          nombre: nombre,
          apellidos: apellidos.isNotEmpty ? apellidos : null,
          telefono: telefono.isNotEmpty ? telefono : null);
      if (response.user != null) {
        final userProfile = await _authService.getUserProfile();
        if (userProfile != null) {
          // Associate guest orders by email
          await _orderService.associateGuestOrders(userProfile['id'], email);

          state = state.copyWith(
              user: UsuarioModel.fromJson(userProfile), isLoading: false);
          return true;
        }
      }
      state = state.copyWith(isLoading: false);
      return false;
    } on AuthException catch (e) {
      String errorMessage = 'Error al registrarse';
      if (e.message.contains('User already registered') ||
          e.message.contains('already exists')) {
        errorMessage = 'El correo electrónico ya está asociado a una cuenta.';
      } else if (e.message.contains('Unprocessable')) {
        errorMessage =
            'Datos inválidos. Verifica tu contraseña (min 6 caracteres) o correo.';
      } else {
        errorMessage = e.message;
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          error: 'Ocurrió un error al registrarse. Inténtalo de nuevo.');
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authService.logout();
    state = const AuthState2();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.updateProfile(data);
      // Refresh profile
      final userProfile = await _authService.getUserProfile();
      if (userProfile != null) {
        state = state.copyWith(
            user: UsuarioModel.fromJson(userProfile), isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userEmail = _authService.userEmail;
      if (userEmail == null)
        throw Exception('No se encontró el email del usuario');

      // Intentar login con la contraseña actual para verificarla
      await _authService.login(userEmail, currentPassword);

      // Si el login tiene éxito, procedemos a cambiar la contraseña
      await _authService.updatePassword(newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      String errorMessage = 'Error al cambiar la contraseña';
      if (e.message.contains('Invalid login credentials')) {
        errorMessage = 'La contraseña actual es incorrecta.';
      } else {
        errorMessage = e.message;
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> refreshUser() => _init();
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState2>((ref) {
  return AuthNotifier(
    ref.watch(authServiceProvider),
    ref.watch(orderServiceProvider),
  );
});
