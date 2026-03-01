import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../modules/home/home_screen.dart';
import '../modules/products/products_screen.dart';
import '../modules/cart/cart_screen.dart';
import '../modules/product_detail/product_detail_screen.dart';
import '../modules/auth/login_screen.dart';
import '../modules/auth/register_screen.dart';
import '../modules/checkout/checkout_screen.dart';
import '../modules/checkout/checkout_success_screen.dart';
import '../modules/profile/profile_screen.dart';
import '../modules/orders/orders_screen.dart';
import '../modules/orders/order_detail_screen.dart';
import '../modules/search/search_screen.dart';
import '../modules/profile/views/addresses_screen.dart';
import '../modules/profile/views/reviews_screen.dart';
import '../modules/profile/views/coupons_screen.dart';
import '../modules/profile/views/change_password_screen.dart';
import '../modules/profile/views/returns_screen.dart';
import '../modules/profile/views/return_detail_screen.dart';
import '../modules/profile/views/personal_info_screen.dart';
import '../modules/admin/admin_login_screen.dart';
import '../modules/admin/admin_dashboard_screen.dart';
import '../providers/auth_provider.dart';

// ── Route names (constants) ────────────────────────────────────────────────

abstract class AppRoutes {
  static const home = '/home';
  static const products = '/products';
  static const productDetail = '/product/:id';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const checkoutSuccess = '/checkout/success';
  static const login = '/login';
  static const register = '/register';
  static const profile = '/profile';
  static const wishlist = '/wishlist';
  static const orders = '/orders';
  static const orderDetail = '/order/:id';
  static const search = '/search';
  static const addresses = '/profile/addresses';
  static const reviews = '/profile/reviews';
  static const coupons = '/profile/coupons';
  static const personalInfo = '/profile/personal-info';
  static const changePassword = '/profile/change-password';
  static const returns = '/profile/returns';
  static const returnDetail = '/return/:id';
  static const adminLogin = '/admin/login';
  static const adminDashboard = '/admin/dashboard';
}

// ── Router Notifier ────────────────────────────────────────────────────────

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState2>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

// ── Router provider ────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authNotifierProvider);
      final isLoggedIn = authState.user != null;
      final isLoggingIn = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      debugPrint(
          '🔗 Router Redirect: path=${state.matchedLocation} isLoggedIn=$isLoggedIn isLoading=${authState.isLoading}');

      // If still initializing auth, stay where we are (let GoRouter handle initial URL)
      if (authState.isLoading) {
        debugPrint('🔗 Router: Auth is loading, staying at current path');
        return null;
      }

      // Protected routes
      final protectedRoutes = [
        AppRoutes.profile,
        AppRoutes.orders,
        AppRoutes.addresses,
        AppRoutes.reviews,
        AppRoutes.coupons,
        AppRoutes.changePassword,
        AppRoutes.personalInfo,
      ];

      // Special check: success page should be accessible if we just came from payment
      // OR it will be protected if we use startsWith(AppRoutes.checkout)
      final isProtected =
          protectedRoutes.any((r) => state.matchedLocation.startsWith(r));

      // Admin dashboard requiere login
      final isAdminRoute =
          state.matchedLocation.startsWith(AppRoutes.adminDashboard);

      if (isAdminRoute && !isLoggedIn) {
        debugPrint('🔗 Router: Admin route and NOT logged in -> Admin Login');
        return AppRoutes.adminLogin;
      }

      if (isProtected && !isLoggedIn) {
        debugPrint('🔗 Router: Protected route and NOT logged in -> Login');
        return AppRoutes.login;
      }

      if (isLoggedIn && isLoggingIn) {
        debugPrint('🔗 Router: Logged in and on Login/Register -> Home');
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.products,
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkoutSuccess,
        builder: (context, state) => const CheckoutSuccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/order/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.addresses,
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: AppRoutes.reviews,
        builder: (context, state) => const ReviewsScreen(),
      ),
      GoRoute(
        path: AppRoutes.coupons,
        builder: (context, state) => const CouponsScreen(),
      ),
      GoRoute(
        path: AppRoutes.personalInfo,
        builder: (context, state) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.returns,
        builder: (context, state) => const ReturnsScreen(),
      ),
      GoRoute(
        path: '/return/:id',
        builder: (context, state) {
          final returnId = state.pathParameters['id']!;
          return ReturnDetailScreen(returnId: returnId);
        },
      ),
      GoRoute(
        path: AppRoutes.adminLogin,
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Ruta no encontrada: ${state.uri}'),
      ),
    ),
  );
});
