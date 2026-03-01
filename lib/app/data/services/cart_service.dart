import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/carrito_model.dart';

/// Servicio de Carrito — Hive local storage (plain Dart, no GetX)
class CartService {
  final _box = Hive.box('cart_box');

  List<CartItemModel> loadCart() {
    try {
      final List<dynamic> data = _box.values.toList();
      return data.map((json) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(json as Map);
        return CartItemModel.fromJson(map);
      }).toList();
    } catch (e) {
      print('❌ Error loading cart from Hive: $e');
      return [];
    }
  }

  Future<List<CartItemModel>> addToCart({
    required List<CartItemModel> currentItems,
    required String productId,
    required String productName,
    required int precio,
    int quantity = 1,
    String? variantId,
    String? variantName,
    String? color,
    String? capacidad,
    String? imageUrl,
    required int maxStock,
  }) async {
    final existingIndex = currentItems.indexWhere((item) =>
        item.productId == productId &&
        item.variantId == variantId &&
        item.color == color &&
        item.capacidad == capacidad);

    if (existingIndex != -1) {
      final existing = currentItems[existingIndex];
      return updateQuantity(
        currentItems: currentItems,
        cartItemId: existing.id,
        newQuantity: existing.quantity + quantity,
      );
    }

    final id = const Uuid().v4();
    final newItem = CartItemModel(
      id: id,
      productId: productId,
      productName: productName,
      quantity: quantity,
      precioUnitario: precio,
      productImage: imageUrl,
      variantId: variantId,
      talla: variantName,
      color: color,
      capacidad: capacidad,
      maxStock: maxStock,
      expireAt: DateTime.now().add(const Duration(minutes: 15)),
    );

    await _box.put(id, newItem.toJson());
    return [...currentItems, newItem];
  }

  Future<List<CartItemModel>> updateQuantity({
    required List<CartItemModel> currentItems,
    required String cartItemId,
    required int newQuantity,
  }) async {
    if (newQuantity < 1) {
      return removeItem(currentItems: currentItems, cartItemId: cartItemId);
    }

    final index = currentItems.indexWhere((item) => item.id == cartItemId);
    if (index == -1) return currentItems;

    final updatedItem = currentItems[index].copyWith(quantity: newQuantity);
    await _box.put(cartItemId, updatedItem.toJson());

    final newList = [...currentItems];
    newList[index] = updatedItem;
    return newList;
  }

  Future<List<CartItemModel>> removeItem({
    required List<CartItemModel> currentItems,
    required String cartItemId,
  }) async {
    await _box.delete(cartItemId);
    return currentItems.where((item) => item.id != cartItemId).toList();
  }

  Future<List<CartItemModel>> clearCart(
      {required List<CartItemModel> currentItems}) async {
    await _box.clear();
    return [];
  }
}
