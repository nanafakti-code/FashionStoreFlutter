import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/return_provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../widgets/custom_app_bar.dart';

class ReturnsScreen extends ConsumerStatefulWidget {
  const ReturnsScreen({super.key});

  @override
  ConsumerState<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends ConsumerState<ReturnsScreen> {
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
        ref.read(returnsProvider.notifier).loadReturns();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.orange;
      case 'Aprobada':
        return Colors.blue;
      case 'Recibida':
        return Colors.teal;
      case 'Reembolsada':
        return AppColors.success;
      case 'Rechazada':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(returnsProvider);
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomFashionAppBar(
        title: 'Mis Devoluciones',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (allReturns) {
                // Filtrar por búsqueda
                final filteredReturns = allReturns.where((dev) {
                  return _searchQuery.isEmpty ||
                      dev.numeroDevolucion
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredReturns.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assignment_return_outlined,
                            size: 80, color: AppColors.greyLight),
                        const SizedBox(height: 16),
                        Text(_searchQuery.isEmpty
                            ? 'No tienes devoluciones en curso'
                            : 'No se encontraron devoluciones'),
                        const SizedBox(height: 16),
                        if (_searchQuery.isNotEmpty)
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
                      await ref.read(returnsProvider.notifier).loadReturns();
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredReturns.length,
                    itemBuilder: (_, i) {
                      final dev = filteredReturns[i];
                      final order = dev.pedido;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: InkWell(
                          onTap: () {
                            context.push('/return/${dev.id}');
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
                                    Text(dev.numeroDevolucion,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    _buildStatusChip(dev.estado),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (order != null) ...[
                                  Text('Pedido: #${order.numeroOrden}',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14)),
                                  const SizedBox(height: 4),
                                ],
                                if (dev.fechaSolicitud != null)
                                  Text(
                                    'Solicitada el ${dev.fechaSolicitud!.day}/${dev.fechaSolicitud!.month}/${dev.fechaSolicitud!.year}',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13),
                                  ),
                                const SizedBox(height: 8),
                                if (dev.importeReembolsoEnEuros != null)
                                  Text(
                                    'Reembolso: ${dev.importeReembolsoEnEuros!.toStringAsFixed(2)}€',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
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
          hintText: 'Buscar por número de devolución...',
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
        status,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
