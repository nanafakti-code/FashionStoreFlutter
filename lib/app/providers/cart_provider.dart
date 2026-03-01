import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fashion_store_flutter/app/data/models/carrito_model.dart';
import 'package:fashion_store_flutter/app/data/services/cart_service.dart';
import 'package:fashion_store_flutter/app/providers/services_providers.dart';

// ── Cart State ─────────────────────────────────────────────────────────────

class CartState {
  final List<CartItemModel> items;
  final bool isLoading;
  final String? error;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  CartState copyWith({
    List<CartItemModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalEuros => items.fold(
      0.0, (sum, item) => sum + (item.precioUnitario / 100) * item.quantity);

  double get totalCents =>
      items.fold(0.0, (sum, item) => sum + item.precioUnitario * item.quantity);
}

// ── Cart Notifier ──────────────────────────────────────────────────────────

class CartNotifier extends StateNotifier<CartState> {
  final CartService _cartService;
  final Ref ref;
  final SupabaseClient _supabase;
  Timer? _expirationTimer;

  CartNotifier(this._cartService, this.ref, this._supabase)
      : super(const CartState()) {
    loadCart();
    _startExpirationTimer();
  }

  void _startExpirationTimer() {
    _expirationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.items.isEmpty) return;

      final now = DateTime.now();
      final expiredItems = state.items
          .where((item) => item.expireAt != null && now.isAfter(item.expireAt!))
          .toList();

      for (final item in expiredItems) {
        removeItem(item.id);
        state = state.copyWith(
            error: 'La reserva temporal de ${item.productName} ha expirado.');
      }
    });
  }

  @override
  void dispose() {
    _expirationTimer?.cancel();
    super.dispose();
  }

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      state = state.copyWith(
          items: await _cartService.loadCart(), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addItem({
    required String productId,
    required String productName,
    required int price,
    required int quantity,
    String? image,
    String? talla,
    String? color,
    String? capacidad,
    String? variantId,
    int? maxStock,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Revalidar stock en el backend al momento
      final currentCartItem = state.items
          .where((i) =>
              i.productId == productId &&
              i.variantId == variantId &&
              i.capacidad == capacidad)
          .firstOrNull;
      final requestedQuantity = (currentCartItem?.quantity ?? 0) + quantity;

      final dynamic hasStock =
          await _supabase.rpc('check_stock_available', params: {
        'p_producto_id': productId,
        'p_variant_id': variantId,
        'p_cantidad': requestedQuantity,
      });

      if (hasStock != true) {
        state = state.copyWith(
            isLoading: false, error: 'Stock insuficiente para $productName');
        return false;
      }

      final items = await _cartService.addToCart(
        currentItems: state.items,
        productId: productId,
        productName: productName,
        precio: price,
        quantity: quantity,
        imageUrl: image,
        variantName: talla,
        color: color,
        capacidad: capacidad,
        variantId: variantId,
        maxStock: maxStock ?? 99,
      );

      // Sync reservation (Global)
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final updatedItem = items.firstWhere(
          (item) =>
              item.productId == productId &&
              item.variantId == variantId &&
              item.color == color &&
              item.capacidad == capacidad,
          orElse: () => items.last,
        );
        _syncReservation(user.id, updatedItem);
      }

      state = state.copyWith(items: items, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _cartService.updateQuantity(
        currentItems: state.items,
        cartItemId: cartItemId,
        newQuantity: newQuantity,
      );

      // Sync reservation
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final idx = items.indexWhere((item) => item.id == cartItemId);
        if (idx != -1) {
          _syncReservation(user.id, items[idx]);
        }
      }

      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> removeItem(String cartItemId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final itemToRemove =
          state.items.firstWhere((item) => item.id == cartItemId);
      final items = await _cartService.removeItem(
        currentItems: state.items,
        cartItemId: cartItemId,
      );

      // Sync reservation (Delete)
      final user = _supabase.auth.currentUser;
      if (user != null) {
        ref.read(productServiceProvider).syncReservation(
              userId: user.id,
              productId: itemToRemove.productId,
              variantId: itemToRemove.variantId,
              quantity: 0,
            );
      }

      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> clearCart() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _cartService.clearCart(currentItems: state.items);
      final user = _supabase.auth.currentUser;
      if (user != null) {
        ref.read(productServiceProvider).clearUserReservations(user.id);
      }
      state = const CartState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _syncReservation(String userId, CartItemModel item) {
    ref.read(productServiceProvider).syncReservation(
          userId: userId,
          productId: item.productId,
          variantId: item.variantId,
          quantity: item.quantity,
        );
  }
}

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(
      ref.watch(cartServiceProvider), ref, Supabase.instance.client);
});
