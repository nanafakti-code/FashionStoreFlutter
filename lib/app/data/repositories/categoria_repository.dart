import '../models/producto_model.dart';
import '../services/supabase_service.dart';

class CategoriaRepository {
  /// Obtener todas las categorías
  static Future<List<CategoriaModel>> getCategorias() async {
    try {
      final response = await SupabaseService.from('categorias')
          .select('*')
          .order('nombre', ascending: true);

      return (response as List)
          .map((json) => CategoriaModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error obteniendo categorías: $e');
      return [];
    }
  }

  /// Obtener categoría por ID
  static Future<CategoriaModel?> getCategoriaById(String id) async {
    try {
      final response = await SupabaseService.from('categorias')
          .select('*')
          .eq('id', id)
          .single();

      return CategoriaModel.fromJson(response);
    } catch (e) {
      print('Error obteniendo categoría: $e');
      return null;
    }
  }

  /// Obtener categoría por slug
  static Future<CategoriaModel?> getCategoriaBySlug(String slug) async {
    try {
      final response = await SupabaseService.from('categorias')
          .select('*')
          .eq('slug', slug)
          .single();

      return CategoriaModel.fromJson(response);
    } catch (e) {
      print('Error obteniendo categoría por slug: $e');
      return null;
    }
  }
}
