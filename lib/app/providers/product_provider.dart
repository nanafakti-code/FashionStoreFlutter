import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_store_flutter/app/data/models/producto_model.dart';
import 'package:fashion_store_flutter/app/data/services/product_service.dart';
import 'package:fashion_store_flutter/app/providers/services_providers.dart';

// ── Product List State ─────────────────────────────────────────────────────

const _sentinel = Object();

class ProductState {
  final List<ProductoModel> products;
  final List<ProductoModel> featuredProducts;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? selectedCategory;
  final List<CategoriaModel> categories;

  const ProductState({
    this.products = const [],
    this.featuredProducts = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategory,
    this.categories = const [],
  });

  ProductState copyWith({
    List<ProductoModel>? products,
    List<ProductoModel>? featuredProducts,
    bool? isLoading,
    String? error,
    String? searchQuery,
    Object? selectedCategory = _sentinel,
    List<CategoriaModel>? categories,
  }) {
    return ProductState(
      products: products ?? this.products,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory == _sentinel
          ? this.selectedCategory
          : selectedCategory as String?,
      categories: categories ?? this.categories,
    );
  }

  List<ProductoModel> get filteredProducts {
    var result = products;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where((p) =>
              p.nombre.toLowerCase().contains(q) ||
              (p.descripcion?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    if (selectedCategory == 'OFERTAS') {
      result = result.where((p) => p.enOferta).toList();
    } else if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      result = result.where((p) => p.categoriaId == selectedCategory).toList();
    }
    return result;
  }
}

// ── Product Notifier ───────────────────────────────────────────────────────

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductService _productService;

  ProductNotifier(this._productService) : super(const ProductState());

  Future<void> loadProducts({String? category, String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _productService.getProducts(
        category: category,
        search: search,
      );
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadFeaturedProducts() async {
    try {
      final featured = await _productService.getFeaturedProducts();
      state = state.copyWith(featuredProducts: featured);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _productService.getCategories();
      state = state.copyWith(categories: categories);
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String? categoryId) {
    state = state.copyWith(selectedCategory: categoryId);
  }

  void clearFilters() {
    state = state.copyWith(searchQuery: '', selectedCategory: null);
  }
}

final productNotifierProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier(ref.watch(productServiceProvider));
});

// ── Product Detail ─────────────────────────────────────────────────────────

final productDetailProvider =
    FutureProvider.family<ProductoModel?, String>((ref, productId) async {
  final service = ref.watch(productServiceProvider);
  return service.getProductById(productId);
});
