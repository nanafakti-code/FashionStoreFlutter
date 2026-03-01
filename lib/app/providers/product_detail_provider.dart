import 'dart:async';
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fashion_store_flutter/app/data/models/carrito_model.dart';
import 'package:fashion_store_flutter/app/data/models/producto_model.dart';
import 'package:fashion_store_flutter/app/data/models/resena_model.dart';
import 'package:fashion_store_flutter/app/data/services/product_service.dart';
import 'package:fashion_store_flutter/app/data/services/review_service.dart';
import 'package:fashion_store_flutter/app/data/services/wishlist_service.dart';
import 'package:fashion_store_flutter/app/providers/services_providers.dart';
import 'package:fashion_store_flutter/app/providers/cart_provider.dart';

// ── Product Detail State ───────────────────────────────────────────────────

class ProductDetailState {
  final ProductoModel? product;
  final List<ResenaModel> reviews;
  final bool isLoading;
  final String? error;
  final String? selectedTalla;
  final String? selectedColor;
  final String? selectedCapacidad;
  final int quantity;
  final int selectedImageIndex;
  final bool isInWishlist;
  final List<ProductoModel> relatedProducts;
  final List<CartItemModel> cartItems; // Added cart sync
  final List<Map<String, dynamic>> globalReservations; // Added global sync

  const ProductDetailState({
    this.product,
    this.reviews = const [],
    this.isLoading = false,
    this.error,
    this.selectedTalla,
    this.selectedColor,
    this.selectedCapacidad,
    this.quantity = 1,
    this.selectedImageIndex = 0,
    this.isInWishlist = false,
    this.relatedProducts = const [],
    this.cartItems = const [], // Default empty
    this.globalReservations = const [], // Default empty
  });

  ProductDetailState copyWith({
    ProductoModel? product,
    List<ResenaModel>? reviews,
    bool? isLoading,
    String? error,
    String? selectedTalla,
    String? selectedColor,
    String? selectedCapacidad,
    int? quantity,
    int? selectedImageIndex,
    bool? isInWishlist,
    List<ProductoModel>? relatedProducts,
    List<CartItemModel>? cartItems,
    List<Map<String, dynamic>>? globalReservations,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTalla: selectedTalla ?? this.selectedTalla,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedCapacidad: selectedCapacidad ?? this.selectedCapacidad,
      quantity: quantity ?? this.quantity,
      selectedImageIndex: selectedImageIndex ?? this.selectedImageIndex,
      isInWishlist: isInWishlist ?? this.isInWishlist,
      relatedProducts: relatedProducts ?? this.relatedProducts,
      cartItems: cartItems ?? this.cartItems,
      globalReservations: globalReservations ?? this.globalReservations,
    );
  }

  // Helpers
  List<VarianteProductoModel> get variants => product?.variantes ?? [];

  VarianteProductoModel? get selectedVariant {
    if (variants.isEmpty) return null;
    try {
      return variants.firstWhere((v) {
        bool tallaCoin = selectedTalla == null ||
            selectedTalla!.isEmpty ||
            v.talla == selectedTalla;
        bool colorCoin = selectedColor == null ||
            selectedColor!.isEmpty ||
            v.color == selectedColor;
        bool capCoin = selectedCapacidad == null ||
            selectedCapacidad!.isEmpty ||
            v.capacidad == selectedCapacidad;
        return tallaCoin && colorCoin && capCoin;
      });
    } catch (_) {
      return null;
    }
  }

  double get precioMostrado {
    if (product == null) return 0.0;
    if (selectedVariant != null) {
      if (selectedVariant!.precioVenta != null) {
        return selectedVariant!.precioVenta! / 100;
      }
      return (product!.precioVenta + selectedVariant!.precioAdicional) / 100;
    }
    return product!.precioEnEuros;
  }

  double? get precioOriginalMostrado => product?.precioOriginalEnEuros;

  int? get descuentoMostrado {
    final original = precioOriginalMostrado;
    final current = precioMostrado;
    if (original == null || original <= current) return null;
    return (((original - current) / original) * 100).round();
  }

  int get stockMostrado {
    int physicalStock = 0;
    if (selectedVariant != null) {
      physicalStock = selectedVariant!.stock;
    } else {
      physicalStock = product?.stockTotal ?? 0;
    }

    // Sum reservations from OTHER users
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final totalReservedByOthers = globalReservations.where((res) {
      bool sameProduct = res['producto_id'] == product?.id;
      bool sameVariant = res['variant_id'] == selectedVariant?.id;
      bool notMe = res['usuario_id'] != currentUserId;
      return sameProduct && sameVariant && notMe;
    }).fold(0, (sum, res) => sum + (res['cantidad'] as int));

    // Rest quantity already in MY cart (local check for instant response)
    final inCart = cartItems
        .where((item) =>
            item.productId == product?.id &&
            (selectedVariant == null ||
                item.variantId == selectedVariant!.id) &&
            (selectedColor == null || item.color == selectedColor))
        .fold(0, (sum, item) => sum + item.quantity);

    return (physicalStock - totalReservedByOthers - inCart)
        .clamp(0, physicalStock);
  }

  List<String> get tallajesDisponibles {
    if (variants.isEmpty) return [];
    return variants
        .where((v) => v.talla != null && v.talla!.isNotEmpty && v.stock > 0)
        .map((v) => v.talla!)
        .toSet()
        .toList();
  }

  List<String> get coloresDisponibles {
    if (variants.isEmpty) return [];
    return variants
        .where((v) => v.color != null && v.color!.isNotEmpty && v.stock > 0)
        .map((v) => v.color!)
        .toSet()
        .toList();
  }

  List<String> get capacidadesDisponibles {
    if (variants.isEmpty) return [];
    return variants
        .where((v) =>
            v.capacidad != null && v.capacidad!.isNotEmpty && v.stock > 0)
        .map((v) => v.capacidad!)
        .toSet()
        .toList();
  }
}

// ── Product Detail Notifier ────────────────────────────────────────────────

class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  final ProductService _productService;
  final ReviewService _reviewService;
  final WishlistService _wishlistService;

  StreamSubscription? _productSub;
  StreamSubscription? _variantsSub;
  StreamSubscription? _reservationsSub;

  ProductDetailNotifier(
    this._productService,
    this._reviewService,
    this._wishlistService,
  ) : super(const ProductDetailState());

  @override
  void dispose() {
    _productSub?.cancel();
    _variantsSub?.cancel();
    _reservationsSub?.cancel();
    super.dispose();
  }

  void updateCartItems(List<CartItemModel> items) {
    state = state.copyWith(cartItems: items);
  }

  Future<void> loadProduct(String productId, {String? userId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final product = await _productService.getProductById(productId);
      final reviews = await _reviewService.getProductReviews(productId);

      bool inWishlist = false;
      if (userId != null) {
        inWishlist = await _wishlistService.isInWishlist(userId, productId);
      }

      // Pre-select first available talla/color/capacidad
      String? firstTalla;
      String? firstColor;
      String? firstCap;
      if (product != null && product.variantes.isNotEmpty) {
        // Try to find first variant with stock
        final firstVar = product.variantes.firstWhere((v) => v.stock > 0,
            orElse: () => product.variantes.first);
        firstTalla = firstVar.talla;
        firstColor = firstVar.color;
        firstCap = firstVar.capacidad;
      }

      // Load related products
      List<ProductoModel> related = [];
      if (product?.categoriaId != null) {
        final allRelated = await _productService.getProducts(
          category: product!.categoriaId,
          limit: 6,
        );
        related = allRelated.where((p) => p.id != productId).take(4).toList();
      }

      state = state.copyWith(
        product: product,
        reviews: reviews,
        isLoading: false,
        selectedTalla: firstTalla,
        selectedColor: firstColor,
        selectedCapacidad: firstCap,
        isInWishlist: inWishlist,
        relatedProducts: related,
      );

      // Setup Realtime Subscriptions
      _setupSubscriptions(productId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _setupSubscriptions(String productId) {
    _productSub?.cancel();
    _productSub = _productService.getProductStream(productId).listen((_) {
      _reloadStock(productId);
    });

    _variantsSub?.cancel();
    _variantsSub = _productService.getVariantsStream(productId).listen((_) {
      _reloadStock(productId);
    });

    _reservationsSub?.cancel();
    _reservationsSub =
        _productService.getGlobalReservationsStream().listen((reservations) {
      state = state.copyWith(globalReservations: reservations);
    }, onError: (e) {
      debugPrint('❌ Error en el stream de reservas: $e');
      // Si la tabla no existe o hay error, continuamos con lista vacía para no romper la UI
      state = state.copyWith(globalReservations: []);
    });
  }

  Future<void> _reloadStock(String productId) async {
    try {
      final updatedProduct = await _productService.getProductById(productId);
      if (updatedProduct != null) {
        state = state.copyWith(product: updatedProduct);
      }
    } catch (e) {
      print('Error reloading stock via Realtime: $e');
    }
  }

  void selectTalla(String talla) {
    state = state.copyWith(selectedTalla: talla);
    // Logic to select generic variant or reset color could go here if needed
  }

  void selectColor(String color) {
    state = state.copyWith(selectedColor: color);
  }

  void selectCapacidad(String capacidad) {
    state = state.copyWith(selectedCapacidad: capacidad);
  }

  void selectImage(int index) =>
      state = state.copyWith(selectedImageIndex: index);

  void incrementQuantity() {
    final maxStock = state.stockMostrado > 0 ? state.stockMostrado : 10;
    if (state.quantity < maxStock) {
      state = state.copyWith(quantity: state.quantity + 1);
    }
  }

  void decrementQuantity() {
    if (state.quantity > 1) {
      state = state.copyWith(quantity: state.quantity - 1);
    }
  }

  Future<void> toggleWishlist(String userId) async {
    final productId = state.product?.id;
    if (productId == null) return;
    final newValue = !state.isInWishlist;
    state = state.copyWith(isInWishlist: newValue);
    await _wishlistService.toggleWishlist(userId, productId);
  }

  Future<void> submitReview({
    required String userId,
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final success = await _reviewService.submitReview(
        userId: userId,
        productId: productId,
        ordenId:
            '00000000-0000-0000-0000-000000000000', // Las reseñas desde la página de detalles pueden no estar vinculadas si no se sabe la orden, aunque la BD pide UUID válido.
        rating: rating,
        comment: comment,
      );
      // Reload reviews
      final reviews = await _reviewService.getProductReviews(productId);
      state = state.copyWith(reviews: reviews);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final productDetailNotifierProvider = StateNotifierProvider.autoDispose<
    ProductDetailNotifier, ProductDetailState>((ref) {
  final notifier = ProductDetailNotifier(
    ref.watch(productServiceProvider),
    ref.watch(reviewServiceProvider),
    ref.watch(wishlistServiceProvider),
  );

  // Initial sync
  final initialCart = ref.read(cartNotifierProvider).items;
  notifier.updateCartItems(initialCart);

  // Reactive sync without recreating the notifier
  ref.listen<CartState>(cartNotifierProvider, (previous, next) {
    notifier.updateCartItems(next.items);
  });

  return notifier;
});
