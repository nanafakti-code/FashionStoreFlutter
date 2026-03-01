import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/admin_category.dart';

class AdminCategoriasState {
  final bool isLoading;
  final bool isSaving;
  final List<AdminCategory> categories;
  final String? error;
  final String? successMessage;

  const AdminCategoriasState({
    this.isLoading = false,
    this.isSaving = false,
    this.categories = const [],
    this.error,
    this.successMessage,
  });

  AdminCategoriasState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<AdminCategory>? categories,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminCategoriasState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      categories: categories ?? this.categories,
      error: clearError ? null : error ?? this.error,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }
}

class AdminCategoriasNotifier extends StateNotifier<AdminCategoriasState> {
  final _db = Supabase.instance.client;

  AdminCategoriasNotifier() : super(const AdminCategoriasState());

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _db
          .from('categorias')
          .select()
          .order('nombre', ascending: true);

      final categories = (response as List)
          .map((json) => AdminCategory.fromJson(json))
          .toList();

      state = state.copyWith(isLoading: false, categories: categories);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> saveCategory({
    String? id,
    required String nombre,
    required String slug,
    String? descripcion,
    bool activa = true,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final data = {
        'nombre': nombre,
        'slug': slug,
        'descripcion': descripcion,
        'activa': activa,
        'actualizada_en': DateTime.now().toIso8601String(),
      };

      if (id == null) {
        // Create
        await _db.from('categorias').insert(data);
      } else {
        // Update
        await _db.from('categorias').update(data).eq('id', id);
      }

      state = state.copyWith(
        isSaving: false,
        successMessage:
            'Categoría ${id == null ? 'creada' : 'actualizada'} correctamente',
      );
      await loadCategories();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: 'Error al guardar: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _db.from('categorias').delete().eq('id', id);
      state = state.copyWith(
          isSaving: false, successMessage: 'Categoría eliminada correctamente');
      await loadCategories();
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

final adminCategoriasProvider =
    StateNotifierProvider<AdminCategoriasNotifier, AdminCategoriasState>((ref) {
  return AdminCategoriasNotifier();
});
