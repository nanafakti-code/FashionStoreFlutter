import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_store_flutter/app/data/models/producto_model.dart';
import 'package:fashion_store_flutter/app/data/services/wishlist_service.dart';
import 'package:fashion_store_flutter/app/providers/services_providers.dart';

// ── Wishlist State ─────────────────────────────────────────────────────────

class WishlistState {
  final List<ProductoModel> items;
  final bool isLoading;
  final String? error;

  const WishlistState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  WishlistState copyWith({
    List<ProductoModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return WishlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── Wishlist Notifier ──────────────────────────────────────────────────────

class WishlistNotifier extends StateNotifier<WishlistState> {
  final WishlistService _wishlistService;

  WishlistNotifier(this._wishlistService) : super(const WishlistState());

  Future<void> loadWishlist(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final rawItems = await _wishlistService.getWishlist(userId);
      // Each item has a 'productos' nested object
      final products = rawItems
          .where((item) => item['productos'] != null)
          .map((item) => ProductoModel.fromJson(item['productos']))
          .toList();
      state = state.copyWith(items: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleItem(String userId, String productId) async {
    await _wishlistService.toggleWishlist(userId, productId);
    await loadWishlist(userId);
  }

  Future<void> removeItem(String userId, String productId) async {
    await _wishlistService.removeFromWishlist(userId, productId);
    state = state.copyWith(
      items: state.items.where((p) => p.id != productId).toList(),
    );
  }
}

final wishlistNotifierProvider =
    StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  return WishlistNotifier(ref.watch(wishlistServiceProvider));
});
