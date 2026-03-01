import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_store_flutter/app/data/models/producto_model.dart';
import 'package:fashion_store_flutter/app/data/models/resena_model.dart';
import 'package:fashion_store_flutter/app/data/models/extra_models.dart';
import 'package:fashion_store_flutter/app/data/models/devolucion_model.dart';
import 'package:fashion_store_flutter/app/data/models/coupon_model.dart';
import 'package:fashion_store_flutter/app/data/services/admin_service.dart';
import 'package:fashion_store_flutter/app/data/services/order_service.dart';
import 'package:fashion_store_flutter/app/data/services/invoice_service.dart';
import 'package:fashion_store_flutter/app/providers/services_providers.dart';

// ── Admin State ────────────────────────────────────────────────────────────

class AdminState {
  final Map<String, dynamic> dashboardStats;
  final List<ProductoModel> products;
  final List<ResenaModel> reviews;
  final List<CouponModel> coupons;
  final List<DevolucionModel> returns;
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> users;
  final List<CampanaModel> campaigns;
  final List<NewsletterModel> subscribers;
  final List<CategoriaModel> categories;
  final List<MarcaModel> brands;
  final bool isLoading;
  final String? error;

  const AdminState({
    this.dashboardStats = const {},
    this.products = const [],
    this.reviews = const [],
    this.coupons = const [],
    this.returns = const [],
    this.orders = const [],
    this.users = const [],
    this.campaigns = const [],
    this.subscribers = const [],
    this.categories = const [],
    this.brands = const [],
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    Map<String, dynamic>? dashboardStats,
    List<ProductoModel>? products,
    List<ResenaModel>? reviews,
    List<CouponModel>? coupons,
    List<DevolucionModel>? returns,
    List<Map<String, dynamic>>? orders,
    List<Map<String, dynamic>>? users,
    List<CampanaModel>? campaigns,
    List<NewsletterModel>? subscribers,
    List<CategoriaModel>? categories,
    List<MarcaModel>? brands,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      dashboardStats: dashboardStats ?? this.dashboardStats,
      products: products ?? this.products,
      reviews: reviews ?? this.reviews,
      coupons: coupons ?? this.coupons,
      returns: returns ?? this.returns,
      orders: orders ?? this.orders,
      users: users ?? this.users,
      campaigns: campaigns ?? this.campaigns,
      subscribers: subscribers ?? this.subscribers,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── Admin Notifier ─────────────────────────────────────────────────────────

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminService _adminService;
  final OrderService _orderService;
  final InvoiceService _invoiceService;

  AdminNotifier(this._adminService, this._orderService, this._invoiceService)
      : super(const AdminState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stats = await _adminService.getDashboardStats();
      state = state.copyWith(dashboardStats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadProducts({bool? activo}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _adminService.getProducts(activo: activo);
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createProduct(Map<String, dynamic> data,
      {List<Map<String, dynamic>>? variants}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success =
          await _adminService.createProduct(data, variants: variants);
      if (success) await loadProducts();
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _adminService.updateProduct(id, data);
      if (success) await loadProducts();
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _adminService.deleteProduct(id);
      if (success) {
        state = state.copyWith(
          products: state.products.where((p) => p.id != id).toList(),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> toggleProductActive(String id, bool active) async {
    try {
      final success = await _adminService.toggleProductActive(id, active);
      if (success) await loadProducts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadOrders({String? estado}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // NOTE: Using getAllOrders from OrderService which returns PedidoModel
      // but AdminState stores List<Map> for dashboard compatibility.
      final orders = await _orderService.getAllOrders(estado: estado);
      state = state.copyWith(
        orders: orders.map((o) => o.toJson()).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final success = await _orderService.updateOrderStatus(orderId, status);
      if (success) {
        // Enviar notificación al usuario
        final pedido = await _orderService.getOrderById(orderId);
        if (pedido != null) {
          await _invoiceService.sendOrderStatusUpdateEmail(pedido, status);
        }
        await loadOrders();
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> loadReviews({String? estado}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reviews = await _adminService.getReviews(estado: estado);
      state = state.copyWith(reviews: reviews, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> deleteReview(String id) async {
    try {
      final success = await _adminService.deleteReview(id);
      if (success) await loadReviews();
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateReviewStatus(String id, String status) async {
    try {
      final success = await _adminService.updateReviewStatus(id, status);
      if (success) await loadReviews();
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> loadCoupons() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final coupons = await _adminService.getCoupons();
      state = state.copyWith(coupons: coupons, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createCoupon(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _adminService.createCoupon(data);
      if (success) await loadCoupons();
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateCoupon(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _adminService.updateCoupon(id, data);
      if (success) await loadCoupons();
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> deleteCoupon(String id) async {
    try {
      final success = await _adminService.deleteCoupon(id);
      if (success) await loadCoupons();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final users = await _adminService.getUsers();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadReturns({String? estado}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final returns = await _adminService.getReturns(estado: estado);
      state = state.copyWith(returns: returns, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateReturnStatus(String id, String status) async {
    try {
      final success = await _adminService.updateReturnStatus(id, status);
      if (success) {
        final ret = state.returns.firstWhere((r) => r.id == id);
        final p = await _orderService.getOrderById(ret.ordenId);

        // Si se reembolsa, actualizar también el estado del pedido
        if (status == 'Reembolsada') {
          await _orderService.updateOrderStatus(ret.ordenId, 'Reembolsada');
        }

        if (p != null) {
          if (status == 'Reembolsada') {
            final pdf = await _invoiceService.generateRefundPdf(p, ret);
            await _invoiceService.sendRefundEmail(p, ret, pdf);
          } else {
            // Notificación general de cambio de estado para otros estados
            await _invoiceService.sendReturnStatusUpdateEmail(p, ret, status);
          }
        }
        await loadReturns();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ─── Campaigns ───
  Future<void> loadCampaigns() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final campaigns = await _adminService.getCampaigns();
      state = state.copyWith(campaigns: campaigns, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createCampaign(Map<String, dynamic> data) async {
    try {
      final success = await _adminService.createCampaign(data);
      if (success) await loadCampaigns();
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateCampaign(String id, Map<String, dynamic> data) async {
    try {
      final success = await _adminService.updateCampaign(id, data);
      if (success) await loadCampaigns();
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> deleteCampaign(String id) async {
    try {
      final success = await _adminService.deleteCampaign(id);
      if (success) await loadCampaigns();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> sendCampaign(String id) async {
    try {
      final success = await _adminService.sendCampaign(id);
      if (success) await loadCampaigns();
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> duplicateCampaign(String id) async {
    try {
      final success = await _adminService.duplicateCampaign(id);
      if (success) await loadCampaigns();
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> loadSubscribers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final subs = await _adminService.getNewsletterSubscribers();
      state = state.copyWith(subscribers: subs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ─── Categories ───
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await _adminService.getCategories();
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createCategory(Map<String, dynamic> data) async {
    try {
      final success = await _adminService.createCategory(data);
      if (success) await loadCategories();
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      final success = await _adminService.updateCategory(id, data);
      if (success) await loadCategories();
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final success = await _adminService.deleteCategory(id);
      if (success) await loadCategories();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ─── Brands ───
  Future<void> loadBrands() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final brands = await _adminService.getBrands();
      state = state.copyWith(brands: brands, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createBrand(Map<String, dynamic> data) async {
    try {
      final success = await _adminService.createBrand(data);
      if (success) await loadBrands();
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateBrand(String id, Map<String, dynamic> data) async {
    try {
      final success = await _adminService.updateBrand(id, data);
      if (success) await loadBrands();
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> deleteBrand(String id) async {
    try {
      final success = await _adminService.deleteBrand(id);
      if (success) await loadBrands();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ─── Helpers ───
  Future<List<Map<String, dynamic>>> getProductVariants(
      String productId) async {
    return await _adminService.getProductVariants(productId);
  }

  Future<String?> uploadImage(String fileName, List<int> bytes) async {
    // Logic for upload is in service, but we might want to track loading here?
    // Since it's usually inside a dialog, local loading state might be better.
    // But we can return the result.
    return await _adminService.uploadProductImage(fileName, bytes);
  }
}

final adminNotifierProvider =
    StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(
    ref.watch(adminServiceProvider),
    ref.watch(orderServiceProvider),
    ref.watch(invoiceServiceProvider),
  );
});
