import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/carrito.dart';
import '../config/constants.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

/// Servicio de carrito
/// Soporta carrito autenticado (Supabase) y carrito invitado (SharedPreferences)
class CartService {
  final SupabaseService _supabase = SupabaseService.instance;
  final AuthService _auth = AuthService();

  // ============================================================
  // DETECCIÓN DE MODO
  // ============================================================

  /// Está autenticado el usuario
  bool get isAuthenticated => _auth.isAuthenticated;

  /// ID del usuario actual
  String? get currentUserId => _auth.currentUserId;

  // ============================================================
  // CARRITO INTELIGENTE (AUTO-DETECTA AUTENTICACIÓN)
  // ============================================================

  /// Obtener carrito (autenticado o invitado)
  Future<List<CarritoItem>> getCart() async {
    if (isAuthenticated) {
      return await _getAuthenticatedCart();
    } else {
      return _getGuestCart();
    }
  }

  /// Añadir al carrito
  Future<bool> addToCart({
    required String productoId,
    required String productoNombre,
    required int precio,
    String? imagen,
    int cantidad = 1,
    String? talla,
    String? color,
  }) async {
    if (isAuthenticated) {
      return await _addToAuthenticatedCart(
        productoId: productoId,
        precio: precio,
        cantidad: cantidad,
        talla: talla,
        color: color,
      );
    } else {
      return _addToGuestCart(
        productoId: productoId,
        productoNombre: productoNombre,
        precio: precio,
        imagen: imagen,
        cantidad: cantidad,
        talla: talla,
        color: color,
      );
    }
  }

  /// Actualizar cantidad de item
  Future<bool> updateCartItem(String itemId, int cantidad) async {
    if (cantidad <= 0) {
      return removeFromCart(itemId);
    }

    if (isAuthenticated) {
      return await _updateAuthenticatedCartItem(itemId, cantidad);
    } else {
      return _updateGuestCartItem(itemId, cantidad);
    }
  }

  /// Eliminar item del carrito
  Future<bool> removeFromCart(String itemId) async {
    if (isAuthenticated) {
      return await _removeFromAuthenticatedCart(itemId);
    } else {
      return _removeFromGuestCart(itemId);
    }
  }

  /// Vaciar carrito
  Future<bool> clearCart() async {
    if (isAuthenticated) {
      return await _clearAuthenticatedCart();
    } else {
      return _clearGuestCart();
    }
  }

  /// Obtener resumen del carrito
  Future<CarritoResumen> getCartSummary(
      {int descuento = 0, int envio = 0}) async {
    final items = await getCart();
    return CarritoResumen.fromItems(items, descuento: descuento, envio: envio);
  }

  /// Obtener cantidad total de items
  Future<int> getCartItemCount() async {
    final items = await getCart();
    int total = 0;
    for (final item in items) {
      total += item.cantidad;
    }
    return total;
  }

  // ============================================================
  // CARRITO AUTENTICADO (SUPABASE)
  // ============================================================

  Future<List<CarritoItem>> _getAuthenticatedCart() async {
    try {
      // Primero obtener o crear el carrito del usuario
      final carritoId = await _getOrCreateCarrito();
      if (carritoId == null) return [];

      final response =
          await _supabase.from(AppConstants.tableCarritoItems).select('''
            *,
            productos:producto_id(
              id, nombre, stock_total,
              imagenes_producto(url, es_principal)
            )
          ''').eq('carrito_id', carritoId);

      return (response as List)
          .map((json) => CarritoItem.fromSupabaseJson(json))
          .toList();
    } catch (e) {
      print('Error obteniendo carrito autenticado: $e');
      return [];
    }
  }

  Future<String?> _getOrCreateCarrito() async {
    if (!isAuthenticated) return null;

    try {
      // Buscar carrito existente
      final existing = await _supabase
          .from(AppConstants.tableCarrito)
          .select('id')
          .eq('usuario_id', currentUserId!)
          .maybeSingle();

      if (existing != null) {
        return existing['id'] as String;
      }

      // Crear nuevo carrito
      final created = await _supabase
          .from(AppConstants.tableCarrito)
          .insert({'usuario_id': currentUserId})
          .select('id')
          .single();

      return created['id'] as String;
    } catch (e) {
      print('Error obteniendo/creando carrito: $e');
      return null;
    }
  }

  Future<bool> _addToAuthenticatedCart({
    required String productoId,
    required int precio,
    int cantidad = 1,
    String? talla,
    String? color,
  }) async {
    try {
      final carritoId = await _getOrCreateCarrito();
      if (carritoId == null) return false;

      // Verificar si el item ya existe
      var query = _supabase
          .from(AppConstants.tableCarritoItems)
          .select('id, cantidad')
          .eq('carrito_id', carritoId)
          .eq('producto_id', productoId);

      if (talla != null) {
        query = query.eq('talla', talla);
      }
      if (color != null) {
        query = query.eq('color', color);
      }

      final existing = await query.maybeSingle();

      if (existing != null) {
        // Actualizar cantidad
        final nuevaCantidad = (existing['cantidad'] as int) + cantidad;
        await _supabase
            .from(AppConstants.tableCarritoItems)
            .update({'cantidad': nuevaCantidad}).eq('id', existing['id']);
      } else {
        // Insertar nuevo item
        await _supabase.from(AppConstants.tableCarritoItems).insert({
          'carrito_id': carritoId,
          'producto_id': productoId,
          'cantidad': cantidad,
          'talla': talla,
          'color': color,
          'precio_unitario': precio,
        });
      }

      return true;
    } catch (e) {
      print('Error añadiendo al carrito autenticado: $e');
      return false;
    }
  }

  Future<bool> _updateAuthenticatedCartItem(String itemId, int cantidad) async {
    try {
      await _supabase
          .from(AppConstants.tableCarritoItems)
          .update({'cantidad': cantidad}).eq('id', itemId);

      return true;
    } catch (e) {
      print('Error actualizando item del carrito: $e');
      return false;
    }
  }

  Future<bool> _removeFromAuthenticatedCart(String itemId) async {
    try {
      await _supabase
          .from(AppConstants.tableCarritoItems)
          .delete()
          .eq('id', itemId);

      return true;
    } catch (e) {
      print('Error eliminando item del carrito: $e');
      return false;
    }
  }

  Future<bool> _clearAuthenticatedCart() async {
    try {
      final carritoId = await _getOrCreateCarrito();
      if (carritoId == null) return false;

      await _supabase
          .from(AppConstants.tableCarritoItems)
          .delete()
          .eq('carrito_id', carritoId);

      return true;
    } catch (e) {
      print('Error vaciando carrito: $e');
      return false;
    }
  }

  // ============================================================
  // CARRITO INVITADO (SHARED PREFERENCES)
  // ============================================================

  List<CarritoItem> _getGuestCart() {
    try {
      final prefs = _getPrefsSync();
      if (prefs == null) return [];

      final jsonString = prefs.getString(AppConstants.guestCartKey);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => GuestCarritoItem.fromJson(json).toCarritoItem())
          .toList();
    } catch (e) {
      print('Error obteniendo carrito invitado: $e');
      return [];
    }
  }

  Future<List<GuestCarritoItem>> _getGuestCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(AppConstants.guestCartKey);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => GuestCarritoItem.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo items del carrito invitado: $e');
      return [];
    }
  }

  Future<bool> _saveGuestCart(List<GuestCarritoItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(items.map((i) => i.toJson()).toList());
      await prefs.setString(AppConstants.guestCartKey, jsonString);
      return true;
    } catch (e) {
      print('Error guardando carrito invitado: $e');
      return false;
    }
  }

  bool _addToGuestCart({
    required String productoId,
    required String productoNombre,
    required int precio,
    String? imagen,
    int cantidad = 1,
    String? talla,
    String? color,
  }) {
    try {
      // Usar versión async internamente
      _addToGuestCartAsync(
        productoId: productoId,
        productoNombre: productoNombre,
        precio: precio,
        imagen: imagen,
        cantidad: cantidad,
        talla: talla,
        color: color,
      );
      return true;
    } catch (e) {
      print('Error añadiendo al carrito invitado: $e');
      return false;
    }
  }

  Future<void> _addToGuestCartAsync({
    required String productoId,
    required String productoNombre,
    required int precio,
    String? imagen,
    int cantidad = 1,
    String? talla,
    String? color,
  }) async {
    final items = await _getGuestCartItems();

    // Buscar item existente
    final existingIndex = items.indexWhere((item) =>
        item.productoId == productoId &&
        item.talla == talla &&
        item.color == color);

    if (existingIndex >= 0) {
      // Actualizar cantidad
      items[existingIndex] = items[existingIndex].copyWith(
        cantidad: items[existingIndex].cantidad + cantidad,
      );
    } else {
      // Añadir nuevo
      items.add(GuestCarritoItem(
        productoId: productoId,
        productoNombre: productoNombre,
        cantidad: cantidad,
        talla: talla,
        color: color,
        precioUnitario: precio,
        productoImagen: imagen,
      ));
    }

    await _saveGuestCart(items);
  }

  bool _updateGuestCartItem(String itemId, int cantidad) {
    try {
      _updateGuestCartItemAsync(itemId, cantidad);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateGuestCartItemAsync(String itemId, int cantidad) async {
    final items = await _getGuestCartItems();
    final index = items.indexWhere((item) => item.id == itemId);

    if (index >= 0) {
      items[index] = items[index].copyWith(cantidad: cantidad);
      await _saveGuestCart(items);
    }
  }

  bool _removeFromGuestCart(String itemId) {
    try {
      _removeFromGuestCartAsync(itemId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _removeFromGuestCartAsync(String itemId) async {
    final items = await _getGuestCartItems();
    items.removeWhere((item) => item.id == itemId);
    await _saveGuestCart(items);
  }

  bool _clearGuestCart() {
    try {
      _clearGuestCartAsync();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _clearGuestCartAsync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.guestCartKey);
  }

  // ============================================================
  // MIGRACIÓN DE CARRITO (INVITADO → AUTENTICADO)
  // ============================================================

  /// Migrar carrito de invitado a autenticado
  Future<void> migrateGuestCartToAuthenticated() async {
    if (!isAuthenticated) return;

    try {
      final guestItems = await _getGuestCartItems();
      if (guestItems.isEmpty) return;

      // Añadir cada item al carrito autenticado
      for (final item in guestItems) {
        await _addToAuthenticatedCart(
          productoId: item.productoId,
          precio: item.precioUnitario,
          cantidad: item.cantidad,
          talla: item.talla,
          color: item.color,
        );
      }

      // Limpiar carrito de invitado
      await _clearGuestCartAsync();

      print('Carrito migrado: ${guestItems.length} items');
    } catch (e) {
      print('Error migrando carrito: $e');
    }
  }

  // Helper para acceso síncrono a SharedPreferences
  SharedPreferences? _prefsInstance;

  SharedPreferences? _getPrefsSync() {
    return _prefsInstance;
  }

  Future<void> initPrefs() async {
    _prefsInstance = await SharedPreferences.getInstance();
  }
}
