import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../data/services/dashboard_service.dart';
import 'models/dashboard_models.dart' as model;
import 'widgets/dashboard_stat_card.dart';
import 'widgets/dashboard_section.dart';
import 'productos/admin_productos_screen.dart';
import 'marcas/admin_brands_screen.dart';
import 'categorias/admin_categorias_screen.dart';
import 'pedidos/admin_orders_screen.dart';
import 'devoluciones/admin_returns_screen.dart';
import 'cupones/admin_coupons_screen.dart';
import 'ofertas/admin_ofertas_screen.dart';
import 'usuarios/admin_users_screen.dart';
import 'resenas/admin_reviews_screen.dart';
import 'marketing/admin_marketing_screen.dart';
import 'widgets/sales_performance_chart.dart';

/// Formatea un número con formato europeo: 1.000.000,59
String _formatEuro(double value) {
  final formatter = NumberFormat('#,##0.00', 'es_ES');
  return '${formatter.format(value)}€';
}

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedTab = 0;
  final DashboardService _dashboardService = DashboardService();
  Future<Map<String, dynamic>>? _dashboardData;
  String _productsFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _dashboardData = _dashboardService.getDashboardData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTabData(0);
    });
  }

  void _loadTabData(int index) {
    setState(() => _selectedTab = index);
    final notifier = ref.read(adminNotifierProvider.notifier);
    switch (index) {
      case 1:
        notifier.loadProducts();
        notifier.loadCategories();
        notifier.loadBrands();
        break;
      case 2:
        notifier.loadBrands();
        break;
      case 3:
        notifier.loadOrders();
        break;
      case 4:
        notifier.loadUsers();
        break;
      case 5:
        notifier.loadReviews();
        break;
      case 6:
        notifier.loadCoupons();
        break;
      case 7:
        notifier.loadReturns();
        break;
      case 8:
        notifier.loadCampaigns();
        notifier.loadSubscribers();
        break;
      case 9:
        notifier.loadCategories();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminNotifierProvider);
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: null,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              fontSize: 24,
            ),
            children: [
              TextSpan(
                text: 'Fashion',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Store',
                style: TextStyle(color: AppColors.green),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.cream,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _dashboardData = _dashboardService.getDashboardData();
              });
              _loadTabData(_selectedTab);
            },
            tooltip: 'Refrescar datos',
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.cream),
              onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
              tooltip: 'Salir',
            ),
          ),
        ],
      ),
      drawer: isWide ? null : _buildDrawer(),
      body: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 260,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(right: BorderSide(color: AppColors.border)),
                  ),
                  child: _buildNavRail(),
                ),
                Expanded(child: _buildContent(context, state)),
              ],
            )
          : _buildContent(context, state),
    );
  }

  // ──────────────────────────────────── Navigation ────────────────────────
  Widget _buildNavRail() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _navItem(Icons.dashboard_rounded, 'Dashboard', 0),
              const Divider(height: 24, thickness: 1),
              _navItem(Icons.inventory_2_rounded, 'Productos', 1),
              _navItem(Icons.local_offer_rounded, 'Ofertas', 10),
              _navItem(Icons.branding_watermark_rounded, 'Marcas', 2),
              _navItem(Icons.category_rounded, 'Categorías', 9),
              const Divider(height: 24, thickness: 1),
              _navItem(Icons.shopping_cart_rounded, 'Pedidos', 3),
              _navItem(Icons.assignment_return_rounded, 'Devoluciones', 7),
              const Divider(height: 24, thickness: 1),
              _navItem(Icons.people_alt_rounded, 'Usuarios', 4),
              _navItem(Icons.star_rounded, 'Reseñas', 5),
              _navItem(Icons.confirmation_number_rounded, 'Cupones', 6),
              _navItem(Icons.campaign_rounded, 'Marketing', 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _selectedTab == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.green : AppColors.grey500,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.navy : AppColors.grey700,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isSelected,
        selectedTileColor: AppColors.green.withOpacity(0.08),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        dense: true,
        onTap: () {
          _loadTabData(index);
          if (MediaQuery.of(context).size.width <= 900) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            color: AppColors.navy,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store_rounded,
                      size: 24, color: AppColors.green),
                ),
                const SizedBox(width: 12),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: null,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      fontSize: 22,
                    ),
                    children: [
                      TextSpan(
                        text: 'Fashion',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'Store',
                        style: TextStyle(color: AppColors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildNavRail()),
        ],
      ),
    );
  }

  // ──────────────────────────────────── Content Router ────────────────────
  Widget _buildContent(BuildContext context, AdminState state) {
    switch (_selectedTab) {
      case 0:
        return _buildDashboardTab(context);
      case 1:
        return const AdminProductosScreen();
      case 2:
        return const AdminBrandsScreen();
      case 3:
        return const AdminOrdersScreen();
      case 4:
        return const AdminUsersScreen();
      case 5:
        return const AdminReviewsScreen();
      case 6:
        return const AdminCouponsScreen();
      case 7:
        return const AdminReturnsScreen();
      case 8:
        return const AdminMarketingScreen();
      case 9:
        return const AdminCategoriasScreen();
      case 10:
        return const AdminOfertasScreen();
      default:
        return Center(
          child: Text(
            'Sección en construcción',
            style: TextStyle(color: AppColors.grey500),
          ),
        );
    }
  }

  // ──────────────────────────────────── Dashboard Tab ─────────────────────
  Widget _buildDashboardTab(BuildContext context) {
    _dashboardData ??= _dashboardService.getDashboardData();

    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.green),
                SizedBox(height: 16),
                Text('Cargando datos del panel...',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error cargando datos:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  onPressed: () => setState(() {
                    _dashboardData = _dashboardService.getDashboardData();
                  }),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;

        final stats = data['stats'] as model.DashboardStats? ??
            model.DashboardStats.empty();
        final recentOrders =
            (data['recentOrders'] as List?)?.cast<model.Order>() ?? [];
        final recentProducts =
            (data['recentProducts'] as List?)?.cast<model.Product>() ?? [];
        final recentUsers =
            (data['recentUsers'] as List?)?.cast<model.DashboardUser>() ?? [];
        final categories =
            (data['categories'] as List?)?.cast<model.DashboardCategory>() ??
                [];
        final brands =
            (data['brands'] as List?)?.cast<model.DashboardBrand>() ?? [];
        final coupons =
            (data['coupons'] as List?)?.cast<model.DashboardCoupon>() ?? [];
        final rawOrders = (data['rawOrders'] as List?) ?? [];

        final isDesktop = MediaQuery.of(context).size.width > 1200;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Dashboard General',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Resumen en tiempo real de tu tienda',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 28),

              // Stats Grid
              _buildStatsGrid(context, stats, isDesktop),
              const SizedBox(height: 24),

              // Sales Performance Chart
              SalesPerformanceChart(rawOrders: rawOrders),
              const SizedBox(height: 32),

              // Row 1: Last Orders + Last Products
              _buildRow(
                isDesktop,
                _buildOrdersTable(recentOrders),
                _buildProductsTable(recentProducts),
              ),
              const SizedBox(height: 24),

              // Row 2: Users + Coupons
              _buildRow(
                isDesktop,
                _buildUsersTable(recentUsers),
                _buildCouponsTable(coupons),
              ),
              const SizedBox(height: 24),

              // Row 3: Categories + Brands
              _buildRow(
                isDesktop,
                _buildCategoriesTable(categories),
                _buildBrandsTable(brands),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(bool isDesktop, Widget left, Widget right) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 24),
          Expanded(child: right),
        ],
      );
    }
    return Column(children: [left, const SizedBox(height: 24), right]);
  }

  // ──────────────────────────────────── Stats Grid ─────────────────────────
  // ──────────────────────────────────── Stats Grid ─────────────────────────
  Widget _buildStatsGrid(
      BuildContext context, model.DashboardStats s, bool isDesktop) {
    final cards = [
      DashboardStatCard(
        title: 'Total Productos',
        value: s.totalProductos.toString(),
        icon: Icons.inventory_2_outlined,
        color: AppColors.navy,
        subtitle: '${s.totalStock} uds en stock',
      ),
      DashboardStatCard(
        title: 'Valor Inventario',
        value: _formatEuro(s.valorInventario),
        icon: Icons.attach_money_outlined,
        color: AppColors.navy,
      ),
      DashboardStatCard(
        title: 'Ventas Hoy',
        value: _formatEuro(s.ventasHoy),
        icon: Icons.today_outlined,
        color: AppColors.navy,
      ),
      DashboardStatCard(
        title: 'Ventas Este Mes',
        value: _formatEuro(s.ventasMes),
        icon: Icons.calendar_today_outlined,
        color: AppColors.navy,
      ),
      DashboardStatCard(
        title: 'Total Pedidos',
        value: s.totalPedidos.toString(),
        icon: Icons.shopping_cart_outlined,
        color: AppColors.navy,
      ),
      DashboardStatCard(
        title: 'En Proceso',
        value: s.ordenesEnProceso.toString(),
        icon: Icons.pending_actions_outlined,
        color: AppColors.navy,
      ),
      DashboardStatCard(
        title: 'Clientes Activos',
        value: s.clientesActivos.toString(),
        icon: Icons.people_outline,
        color: AppColors.navy,
      ),
      DashboardStatCard(
        title: 'Devoluciones',
        value: s.devolucionesActivas.toString(),
        icon: Icons.assignment_return_outlined,
        color: AppColors.navy,
      ),
    ];

    if (isDesktop) {
      return GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.6,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: cards,
      );
    }
    return Column(
      children: cards
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: c,
              ))
          .toList(),
    );
  }

  // ──────────────────────────────────── Table Builders ────────────────────
  Widget _buildOrdersTable(List<model.Order> orders) {
    return DashboardSection(
      title: 'Últimos Pedidos Pagados',
      icon: Icons.receipt_long_outlined,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orders.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.grey200),
        itemBuilder: (_, i) {
          final o = orders[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.numeroOrden,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(o.nombreCliente,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.grey500)),
                    ],
                  ),
                ),
                Text(
                  '${o.total.toStringAsFixed(2)}€',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.navy),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsTable(List<model.Product> products) {
    return DashboardSection(
      title: 'Últimos Productos',
      icon: Icons.inventory_outlined,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.grey200),
        itemBuilder: (_, i) {
          final p = products[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(p.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                _stockBadge(p.stockTotal),
                const SizedBox(width: 12),
                Text('${p.precioVenta.toStringAsFixed(2)}€',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.navy)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsersTable(List<model.DashboardUser> users) {
    return DashboardSection(
      title: 'Últimos Usuarios Activos',
      icon: Icons.people_outline,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.grey200),
        itemBuilder: (_, i) {
          final u = users[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.indigo.withOpacity(0.1),
                  child: Text(
                    u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.nombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(u.email,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.grey500)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCouponsTable(List<model.DashboardCoupon> coupons) {
    return DashboardSection(
      title: 'Cupones Activos',
      icon: Icons.confirmation_number_outlined,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: coupons.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.grey200),
        itemBuilder: (_, i) {
          final c = coupons[i];
          final discount = c.descuentoPorcentaje > 0
              ? '${c.descuentoPorcentaje.toStringAsFixed(0)}%'
              : '${c.montoFijo.toStringAsFixed(2)}€';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Text(c.codigo,
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.orange)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(discount,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.navy)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesTable(List<model.DashboardCategory> cats) {
    return DashboardSection(
      title: 'Categorías',
      icon: Icons.category_outlined,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cats.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.grey200),
        itemBuilder: (_, i) {
          final c = cats[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(c.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                Text(c.slug,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey500,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrandsTable(List<model.DashboardBrand> brands) {
    return DashboardSection(
      title: 'Marcas',
      icon: Icons.branding_watermark_outlined,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: brands.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.grey200),
        itemBuilder: (_, i) {
          final b = brands[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Text(b.nombre,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────── Helpers ────────────────────────────
  Widget _stockBadge(int stock) {
    final isLow = stock < 20;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isLow ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isLow
                ? Colors.red.withOpacity(0.3)
                : Colors.green.withOpacity(0.3)),
      ),
      child: Text(
        '$stock uds',
        style: TextStyle(
          color: isLow ? Colors.red[700] : Colors.green[700],
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
