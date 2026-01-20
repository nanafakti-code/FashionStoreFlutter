import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/screens.dart';

/// Router de la aplicación usando GoRouter
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Home
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    // Productos
    GoRoute(
      path: '/products',
      name: 'products',
      builder: (context, state) => const ProductListScreen(),
    ),

    // Detalle de producto
    GoRoute(
      path: '/product/:slug',
      name: 'product-detail',
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return ProductDetailScreen(productSlug: slug);
      },
    ),

    // Categorías
    GoRoute(
      path: '/categories',
      name: 'categories',
      builder: (context, state) => const CategoriesScreen(),
    ),

    // Categoría específica
    GoRoute(
      path: '/category/:slug',
      name: 'category',
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return ProductListScreen(categorySlug: slug);
      },
    ),

    // Carrito
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),

    // Checkout
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) => const CartScreen(), // TODO: CheckoutScreen
    ),

    // Login
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Registro
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const LoginScreen(), // TODO: RegisterScreen
    ),

    // Perfil
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const LoginScreen(), // TODO: ProfileScreen
    ),

    // Mis pedidos
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) => const HomeScreen(), // TODO: OrdersScreen
    ),

    // Búsqueda
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        return ProductListScreen(searchQuery: query);
      },
    ),

    // Admin
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) =>
          const HomeScreen(), // TODO: AdminDashboardScreen
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFFF5F5F7),
    appBar: AppBar(
      backgroundColor: Colors.white,
      title: const Text('Página no encontrada'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.search_off, size: 48, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Text(
            'Oops! No encontramos la página',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            state.uri.toString(),
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            label: const Text('Ir al inicio'),
          ),
        ],
      ),
    ),
  ),
);
