import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../providers/admin_provider.dart';
import '../../../data/models/resena_model.dart';

class AdminReviewsScreen extends ConsumerStatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  ConsumerState<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends ConsumerState<AdminReviewsScreen> {
  String _selectedFilter = 'Todas';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminNotifierProvider.notifier).loadReviews();
    });
  }

  void _onStatusToggle(ResenaModel review, String newStatus) async {
    final success = await ref
        .read(adminNotifierProvider.notifier)
        .updateReviewStatus(review.id, newStatus);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reseña marcada como $newStatus')),
      );
    }
  }

  void _onDelete(ResenaModel review) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Reseña'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar esta reseña? Esta acción no se puede deshacer.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(adminNotifierProvider.notifier)
                  .deleteReview(review.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reseña eliminada')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ['Todas', 'Pendientes', 'Aprobadas'].map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  )),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = filter);
                }
              },
              selectedColor: AppColors.green,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.green : Colors.grey.shade300,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewCard(ResenaModel review) {
    Color statusColor;
    String statusText = review.estado.toUpperCase();
    if (review.estado == 'Aprobada') {
      statusColor = AppColors.green;
    } else if (review.estado == 'Rechazada') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.calificacion
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (review.verificadaCompra)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.green, size: 14),
                    const SizedBox(width: 4),
                    Text('Compra Verificada',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.green.withOpacity(0.8))),
                  ],
                ),
              ),
            if (review.titulo != null && review.titulo!.isNotEmpty)
              Text(
                review.titulo!,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.navy,
                ),
              ),
            const SizedBox(height: 4),
            if (review.comentario != null && review.comentario!.isNotEmpty)
              Text(
                review.comentario!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.inventory_2_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review.nombreProducto ?? 'Producto Desconocido',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  review.creadaEn != null
                      ? DateFormat('dd/MM/yyyy').format(review.creadaEn!)
                      : 'Fecha Desconocida',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // If it's NOT Approved, show Approve button
                if (review.estado != 'Aprobada') ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _onStatusToggle(review, 'Aprobada'),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Aprobar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.green,
                        side:
                            BorderSide(color: AppColors.green.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // If it's NOT Rejected, show Reject button
                if (review.estado != 'Rechazada') ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _onStatusToggle(review, 'Rechazada'),
                      icon: const Icon(Icons.block, size: 16),
                      label: const Text('Denegar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: BorderSide(color: Colors.orange.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Always show Delete button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _onDelete(review),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminNotifierProvider);
    final reviews = state.reviews;

    final filteredReviews = reviews.where((r) {
      if (_selectedFilter == 'Todas') return true;
      if (_selectedFilter == 'Pendientes') return r.estado == 'Pendiente';
      if (_selectedFilter == 'Aprobadas') return r.estado == 'Aprobada';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.navy),
                const SizedBox(width: 10),
                const Text('Reseñas de Productos',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy)),
                const Spacer(),
                if (state.isLoading)
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
          ),

          _buildFilterChips(),

          Expanded(
            child: state.isLoading && reviews.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredReviews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_outline,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('No hay reseñas registradas',
                                style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredReviews.length,
                        itemBuilder: (context, index) {
                          return _buildReviewCard(filteredReviews[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
