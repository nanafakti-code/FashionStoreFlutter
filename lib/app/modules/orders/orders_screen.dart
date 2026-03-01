import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../routes/app_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref.read(orderNotifierProvider.notifier).loadUserOrders(user.id);
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pagado':
        return Colors.blue;
      case 'Enviado':
        return Colors.orange;
      case 'Entregado':
        return AppColors.success;
      case 'Cancelado':
        return AppColors.error;
      case 'Solicitud Pendiente':
      case 'Devolución_Solicitada':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Pagado':
        return 'Pagado';
      case 'Enviado':
        return 'Enviado';
      case 'Entregado':
        return 'Entregado';
      case 'Cancelado':
        return 'Cancelado';
      case 'Solicitud Pendiente':
      case 'Devolución_Solicitada':
        return 'Solicitud Pendiente';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;

    // Filtrar pedidos que no estén en proceso de devolución y coincidan con la búsqueda
    final orders = state.orders.where((o) {
      final isNotReturned = o.estado != 'Solicitud Pendiente' &&
          o.estado != 'Devolución_Solicitada' &&
          o.estado != 'Reembolsado';

      final matchesSearch = _searchQuery.isEmpty ||
          o.numeroOrden.toLowerCase().contains(_searchQuery.toLowerCase());

      return isNotReturned && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomFashionAppBar(
        title: 'Mis Pedidos',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Builder(builder: (context) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long,
                          size: 80, color: AppColors.greyLight),
                      const SizedBox(height: 16),
                      Text(_searchQuery.isEmpty
                          ? 'No tienes pedidos aún'
                          : 'No se encontraron pedidos'),
                      const SizedBox(height: 16),
                      if (_searchQuery.isEmpty)
                        ElevatedButton(
                          onPressed: () => context.go(AppRoutes.products),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary),
                          child: const Text('Explorar Productos',
                              style: TextStyle(color: Colors.white)),
                        )
                      else
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Text('Limpiar búsqueda'),
                        ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  if (user != null) {
                    await ref
                        .read(orderNotifierProvider.notifier)
                        .loadUserOrders(user.id);
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (_, i) {
                    final order = orders[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: InkWell(
                        onTap: () {
                          context.push('/order/${order.id}');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '#${order.numeroOrden}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatusChip(order.estado),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${(order.total / 100).toStringAsFixed(2)}€',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                              const SizedBox(height: 4),
                              Text(
                                order.fechaCreacion != null
                                    ? '${order.fechaCreacion!.day}/${order.fechaCreacion!.month}/${order.fechaCreacion!.year}'
                                    : '',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13),
                              ),
                              if (order.items.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('${order.items.length} artículo(s)',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Buscar por número de pedido...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getStatusLabel(status),
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
