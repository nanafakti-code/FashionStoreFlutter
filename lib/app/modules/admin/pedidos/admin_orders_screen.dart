import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import 'admin_orders_controller.dart';
import '../../../data/models/admin_order.dart';
import '../../../providers/services_providers.dart';
import 'widgets/order_card.dart';
import 'widgets/order_detail_dialog.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminOrdersProvider.notifier).loadOrders();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(AdminOrder order) async {
    // Protección: No permitir cambios en pedidos cancelados
    if (order.status.toLowerCase() == 'cancelado') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('No se puede cambiar el estado de un pedido cancelado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final newStatus = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cambiar Estado: ${order.orderNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(ctx, 'Pendiente', Colors.orange),
            _buildStatusOption(ctx, 'Confirmado', Colors.blue),
            _buildStatusOption(ctx, 'Enviado', Colors.indigo),
            _buildStatusOption(ctx, 'Entregado', Colors.green),
            _buildStatusOption(ctx, 'Cancelado', Colors.red),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (newStatus != null && mounted) {
      final success = await ref
          .read(adminOrdersProvider.notifier)
          .updateStatus(order.id, newStatus);

      if (!success && mounted) {
        final error = ref.read(adminOrdersProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Error al actualizar el estado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatusOption(BuildContext ctx, String status, Color color) {
    return ListTile(
      leading: Icon(Icons.circle, color: color, size: 12),
      title: Text(status),
      onTap: () => Navigator.pop(ctx, status),
    );
  }

  void _showDetails(AdminOrder order) {
    showDialog(
      context: context,
      builder: (ctx) => OrderDetailDialog(
        order: order,
        onDownloadInvoice: () => _downloadInvoice(order, ctx),
      ),
    );
  }

  Future<void> _downloadInvoice(AdminOrder order, BuildContext ctx) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generando factura...'),
          duration: Duration(seconds: 2),
        ),
      );

      final orderService = ref.read(orderServiceProvider);
      final invoiceService = ref.read(invoiceServiceProvider);

      // Fetch the full PedidoModel
      final pedido = await orderService.getOrderById(order.id);
      if (pedido == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: No se pudo obtener el pedido.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Generate the PDF
      final pdfFile = await invoiceService.generateInvoicePdf(pedido);

      // Open the PDF
      await Process.run('cmd', ['/c', 'start', '', pdfFile.path]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar factura: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── UI Helpers ─────────────────────────────────────────────────────────────
  Widget _buildHeader(int count, bool isLoading) {
    return Container(
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
          const Icon(Icons.shopping_bag_rounded, color: AppColors.navy),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gestión de Pedidos',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy)),
              Text('$count pedidos',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          if (isLoading)
            const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Buscar por número, cliente o email...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOrdersProvider);

    // Filter
    final filtered = state.orders.where((o) {
      final q = _searchQuery.toLowerCase();
      final num = o.orderNumber.toLowerCase();
      final client = o.clientName?.toLowerCase() ?? '';
      final email = o.clientEmail?.toLowerCase() ?? '';
      return num.contains(q) || client.contains(q) || email.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          _buildHeader(filtered.length, state.isLoading),
          _buildActions(),
          // List
          Expanded(
            child: state.isLoading && state.orders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('No hay pedidos registrados',
                                style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final order = filtered[i];
                          return OrderCard(
                            order: order,
                            onTap: () => _showDetails(order),
                            onStatusChange: () => _updateStatus(order),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
