import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBrand {
  final String id;
  final String nombre;
  final String slug;
  final String? descripcion;
  final String? sitioWeb;
  final String? logoUrl;
  final bool activa;

  AdminBrand({
    required this.id,
    required this.nombre,
    required this.slug,
    this.descripcion,
    this.sitioWeb,
    this.logoUrl,
    required this.activa,
  });

  factory AdminBrand.fromJson(Map<String, dynamic> json) {
    return AdminBrand(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      slug: json['slug'] ?? '',
      descripcion: json['descripcion'],
      sitioWeb: json['sitio_web'],
      logoUrl: json['logo_url'] ??
          json['logo'] ??
          json['imagen'] ??
          json['image'] ??
          json['url'],
      activa: json['activa'] ?? json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'slug': slug,
        'descripcion': descripcion,
        'sitio_web': sitioWeb,
        'logo_url': logoUrl,
        'activa': activa,
      };
}

class AdminBrandsState {
  final bool isLoading;
  final bool isSaving;
  final List<AdminBrand> brands;
  final String? error;
  final String? successMessage;

  const AdminBrandsState({
    this.isLoading = false,
    this.isSaving = false,
    this.brands = const [],
    this.error,
    this.successMessage,
  });

  AdminBrandsState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<AdminBrand>? brands,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminBrandsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      brands: brands ?? this.brands,
      error: clearError ? null : error ?? this.error,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }
}

class AdminBrandsNotifier extends StateNotifier<AdminBrandsState> {
  final _db = Supabase.instance.client;

  AdminBrandsNotifier() : super(const AdminBrandsState());

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data =
          await _db.from('marcas').select().order('nombre', ascending: true);

      final brands = (data as List).map((e) => AdminBrand.fromJson(e)).toList();

      state = state.copyWith(isLoading: false, brands: brands);
    } catch (e) {
      state =
          state.copyWith(isLoading: false, error: 'Error cargando marcas: $e');
    }
  }

  Future<bool> saveBrand(String? id, Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      if (id == null) {
        // Create
        await _db.from('marcas').insert(data);
      } else {
        // Update
        await _db.from('marcas').update(data).eq('id', id);
      }

      state = state.copyWith(
          isSaving: false,
          successMessage: id == null ? 'Marca creada' : 'Marca actualizada');
      await loadAll();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: 'Error al guardar: $e');
      return false;
    }
  }

  Future<bool> deleteBrand(String id) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _db.from('marcas').delete().eq('id', id);
      state =
          state.copyWith(isSaving: false, successMessage: 'Marca eliminada');
      await loadAll();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: 'Error al eliminar: $e');
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

final adminBrandsProvider =
    StateNotifierProvider<AdminBrandsNotifier, AdminBrandsState>((ref) {
  return AdminBrandsNotifier();
});
