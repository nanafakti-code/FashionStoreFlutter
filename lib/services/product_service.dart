import '../models/producto.dart';
import '../config/constants.dart';
import 'supabase_service.dart';

/// Servicio de productos
class ProductService {
  final SupabaseService _supabase = SupabaseService.instance;

  // ============================================================
  // CONSULTAS DE PRODUCTOS
  // ============================================================

  /// Obtener todos los productos activos
  Future<List<Producto>> getProductos({
    int limit = 20,
    int offset = 0,
    String? categoriaId,
    String? marcaId,
    String? busqueda,
    bool? destacados,
    String? ordenarPor,
    bool ascendente = true,
  }) async {
    try {
      // Construir query base
      final baseQuery = _supabase.from(AppConstants.tableProductos).select('''
            *,
            categorias:categoria_id(id, nombre, slug),
            marcas:marca_id(id, nombre, slug),
            imagenes_producto(url, es_principal, orden),
            variantes_producto(id, talla, color, stock, precio_adicional)
          ''').eq('activo', true);

      // Aplicar filtros opcionales
      dynamic query = baseQuery;

      if (categoriaId != null) {
        query = query.eq('categoria_id', categoriaId);
      }
      if (marcaId != null) {
        query = query.eq('marca_id', marcaId);
      }
      if (destacados == true) {
        query = query.eq('destacado', true);
      }
      if (busqueda != null && busqueda.isNotEmpty) {
        query =
            query.or('nombre.ilike.%$busqueda%,descripcion.ilike.%$busqueda%');
      }

      // Ordenación y paginación
      final orderColumn = ordenarPor ?? 'creado_en';
      final response = await query
          .order(orderColumn, ascending: ascendente)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) => Producto.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo productos: $e');
      return [];
    }
  }

  /// Obtener producto por ID
  Future<Producto?> getProductoById(String id) async {
    try {
      final response =
          await _supabase.from(AppConstants.tableProductos).select('''
            *,
            categorias:categoria_id(id, nombre, slug),
            marcas:marca_id(id, nombre, slug),
            imagenes_producto(url, es_principal, orden),
            variantes_producto(id, talla, color, stock, precio_adicional)
          ''').eq('id', id).single();

      return Producto.fromJson(response);
    } catch (e) {
      print('Error obteniendo producto: $e');
      return null;
    }
  }

  /// Obtener producto por slug
  Future<Producto?> getProductoBySlug(String slug) async {
    try {
      final response =
          await _supabase.from(AppConstants.tableProductos).select('''
            *,
            categorias:categoria_id(id, nombre, slug),
            marcas:marca_id(id, nombre, slug),
            imagenes_producto(url, es_principal, orden),
            variantes_producto(id, talla, color, stock, precio_adicional)
          ''').eq('slug', slug).single();

      return Producto.fromJson(response);
    } catch (e) {
      print('Error obteniendo producto por slug: $e');
      return null;
    }
  }

  /// Obtener productos destacados
  Future<List<Producto>> getProductosDestacados({int limit = 8}) async {
    return getProductos(limit: limit, destacados: true);
  }

  /// Obtener productos por categoría
  Future<List<Producto>> getProductosPorCategoria(
    String categoriaId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return getProductos(
      limit: limit,
      offset: offset,
      categoriaId: categoriaId,
    );
  }

  /// Buscar productos
  Future<List<Producto>> buscarProductos(String query, {int limit = 20}) async {
    return getProductos(limit: limit, busqueda: query);
  }

  /// Obtener productos relacionados
  Future<List<Producto>> getProductosRelacionados(
    String productoId, {
    int limit = 4,
  }) async {
    try {
      // Primero obtener el producto actual
      final producto = await getProductoById(productoId);
      if (producto == null) return [];

      // Buscar productos de la misma categoría
      dynamic query = _supabase.from(AppConstants.tableProductos).select('''
            *,
            imagenes_producto(url, es_principal, orden)
          ''').eq('activo', true).neq('id', productoId);

      if (producto.categoriaId != null) {
        query = query.eq('categoria_id', producto.categoriaId!);
      }

      final response = await query.limit(limit);

      return (response as List).map((json) => Producto.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo productos relacionados: $e');
      return [];
    }
  }

  // ============================================================
  // CATEGORÍAS
  // ============================================================

  /// Obtener todas las categorías activas
  Future<List<Categoria>> getCategorias() async {
    try {
      final response = await _supabase
          .from(AppConstants.tableCategorias)
          .select()
          .eq('activa', true)
          .order('orden', ascending: true);

      return (response as List)
          .map((json) => Categoria.fromJson(json))
          .toList();
    } catch (e) {
      print('Error obteniendo categorías: $e');
      return [];
    }
  }

  /// Obtener categoría por slug
  Future<Categoria?> getCategoriaBySlug(String slug) async {
    try {
      final response = await _supabase
          .from(AppConstants.tableCategorias)
          .select()
          .eq('slug', slug)
          .single();

      return Categoria.fromJson(response);
    } catch (e) {
      print('Error obteniendo categoría: $e');
      return null;
    }
  }

  // ============================================================
  // MARCAS
  // ============================================================

  /// Obtener todas las marcas activas
  Future<List<Marca>> getMarcas() async {
    try {
      final response = await _supabase
          .from(AppConstants.tableMarcas)
          .select()
          .eq('activa', true)
          .order('nombre', ascending: true);

      return (response as List).map((json) => Marca.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo marcas: $e');
      return [];
    }
  }

  // ============================================================
  // ADMIN: CRUD DE PRODUCTOS
  // ============================================================

  /// Crear producto
  Future<Producto?> crearProducto(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(AppConstants.tableProductos)
          .insert(data)
          .select()
          .single();

      return Producto.fromJson(response);
    } catch (e) {
      print('Error creando producto: $e');
      return null;
    }
  }

  /// Actualizar producto
  Future<bool> actualizarProducto(String id, Map<String, dynamic> data) async {
    try {
      data['actualizado_en'] = DateTime.now().toIso8601String();

      await _supabase
          .from(AppConstants.tableProductos)
          .update(data)
          .eq('id', id);

      return true;
    } catch (e) {
      print('Error actualizando producto: $e');
      return false;
    }
  }

  /// Eliminar producto (soft delete)
  Future<bool> eliminarProducto(String id) async {
    try {
      await _supabase.from(AppConstants.tableProductos).update({
        'activo': false,
        'actualizado_en': DateTime.now().toIso8601String(),
      }).eq('id', id);

      return true;
    } catch (e) {
      print('Error eliminando producto: $e');
      return false;
    }
  }

  /// Actualizar stock
  Future<bool> actualizarStock(String productoId, int nuevoStock) async {
    try {
      await _supabase.from(AppConstants.tableProductos).update({
        'stock_total': nuevoStock,
        'actualizado_en': DateTime.now().toIso8601String(),
      }).eq('id', productoId);

      return true;
    } catch (e) {
      print('Error actualizando stock: $e');
      return false;
    }
  }

  // ============================================================
  // ADMIN: CRUD DE CATEGORÍAS
  // ============================================================

  /// Crear categoría
  Future<Categoria?> crearCategoria(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(AppConstants.tableCategorias)
          .insert(data)
          .select()
          .single();

      return Categoria.fromJson(response);
    } catch (e) {
      print('Error creando categoría: $e');
      return null;
    }
  }

  /// Actualizar categoría
  Future<bool> actualizarCategoria(String id, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from(AppConstants.tableCategorias)
          .update(data)
          .eq('id', id);

      return true;
    } catch (e) {
      print('Error actualizando categoría: $e');
      return false;
    }
  }

  /// Eliminar categoría
  Future<bool> eliminarCategoria(String id) async {
    try {
      await _supabase
          .from(AppConstants.tableCategorias)
          .update({'activa': false}).eq('id', id);

      return true;
    } catch (e) {
      print('Error eliminando categoría: $e');
      return false;
    }
  }
}
