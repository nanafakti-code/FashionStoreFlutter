import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fashion_store_flutter/app/data/models/extra_models.dart';
import 'package:fashion_store_flutter/app/providers/auth_provider.dart';

// ── Profile State ──────────────────────────────────────────────────────────

class ProfileState {
  final bool isLoading;
  final String? error;
  final bool isEditing;
  final List<DireccionModel> addresses;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.isEditing = false,
    this.addresses = const [],
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    bool? isEditing,
    List<DireccionModel>? addresses,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isEditing: isEditing ?? this.isEditing,
      addresses: addresses ?? this.addresses,
    );
  }
}

// ── Profile Notifier ───────────────────────────────────────────────────────

class ProfileNotifier extends StateNotifier<ProfileState> {
  final AuthNotifier _authNotifier;

  ProfileNotifier(this._authNotifier) : super(const ProfileState());

  final _supabase = Supabase.instance.client;

  Future<void> loadAddresses(String userId) async {
    // Prevent fetching addresses for admin session
    if (userId == 'admin-session') {
      state = state.copyWith(isLoading: false, addresses: []);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _supabase
          .from('direcciones')
          .select()
          .eq('usuario_id', userId)
          .order('es_predeterminada', ascending: false);

      if (!mounted) return;

      final addresses =
          (response as List).map((d) => DireccionModel.fromJson(d)).toList();

      state = state.copyWith(isLoading: false, addresses: addresses);
      print(
          '📋 ProfileProvider: Loaded ${addresses.length} addresses for user');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleEditing() {
    state = state.copyWith(isEditing: !state.isEditing);
  }

  Future<bool> updateProfile({
    required String userId,
    required String nombre,
    String? apellidos,
    required String telefono,
    String? genero,
    DateTime? fechaNacimiento,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Create updates map
      final updates = <String, dynamic>{};
      if (nombre.isNotEmpty) updates['nombre'] = nombre;
      if (apellidos != null) updates['apellidos'] = apellidos;
      if (telefono.isNotEmpty) updates['telefono'] = telefono;
      if (genero != null) updates['genero'] = genero;
      if (fechaNacimiento != null) {
        updates['fecha_nacimiento'] = fechaNacimiento.toIso8601String();
      }

      if (updates.isEmpty) {
        state = state.copyWith(isLoading: false, isEditing: false);
        return true;
      }

      await _supabase.from('usuarios').update(updates).eq('id', userId);

      if (!mounted) return true;

      // Refresh auth profile
      await _authNotifier.refreshUser();

      if (!mounted) return true;

      state = state.copyWith(isLoading: false, isEditing: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> addAddress(
      String userId, Map<String, dynamic> addressData) async {
    if (userId == 'admin-session') return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final isPredeterminada = addressData['es_predeterminada'] ?? false;

      // Si se marca como predeterminada, primero quitamos la marca de las otras
      if (isPredeterminada) {
        await _supabase
            .from('direcciones')
            .update({'es_predeterminada': false}).eq('usuario_id', userId);
      }

      addressData['usuario_id'] = userId;
      await _supabase.from('direcciones').insert(addressData);

      if (!mounted) return true;

      // Reload addresses
      await loadAddresses(userId);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> setAddressAsDefault(String userId, String addressId) async {
    if (userId == 'admin-session') return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Quitar predeterminada de todas las del usuario
      await _supabase
          .from('direcciones')
          .update({'es_predeterminada': false}).eq('usuario_id', userId);

      // 2. Marcar la seleccionada como predeterminada
      await _supabase
          .from('direcciones')
          .update({'es_predeterminada': true}).eq('id', addressId);

      if (!mounted) return;

      // 3. Recargar
      await loadAddresses(userId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteAddress(String userId, String addressId) async {
    if (userId == 'admin-session') return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('direcciones').delete().eq('id', addressId);
      await loadAddresses(userId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final profileNotifierProvider =
    StateNotifierProvider.autoDispose<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.watch(authNotifierProvider.notifier));
});
