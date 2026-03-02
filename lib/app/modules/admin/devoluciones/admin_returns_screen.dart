import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/services_providers.dart';
import '../../../data/models/devolucion_model.dart';
import 'widgets/return_card.dart';
import 'widgets/return_detail_dialog.dart';

class AdminReturnsScreen extends ConsumerStatefulWidget {
  const AdminReturnsScreen({super.key});

  @override
  ConsumerState<AdminReturnsScreen> createState() => _AdminReturnsScreenState();
}

class _AdminReturnsScreenState extends ConsumerState<AdminReturnsScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminNotifierProvider.notifier).loadReturns();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(DevolucionModel dev) async {
    // Protección: no permitir cambios en devoluciones con estado final
    final s = dev.estado.toLowerCase();
    if (s == 'reembolsada' || s == 'rechazada') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'No se puede cambiar el estado de una devolución ${dev.estado.toLowerCase()}.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final newStatus = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cambiar Estado: ${dev.numeroDevolucion}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(ctx, 'Pendiente', Colors.orange),
            _buildStatusOption(ctx, 'Aprobada', Colors.blue),
            _buildStatusOption(ctx, 'Recibida', Colors.indigo),
            _buildStatusOption(ctx, 'Reembolsada', Colors.green),
            _buildStatusOption(ctx, 'Rechazada', Colors.red),
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
      await ref
          .read(adminNotifierProvider.notifier)
          .updateReturnStatus(dev.id, newStatus);
    }
  }

  Widget _buildStatusOption(BuildContext ctx, String status, Color color) {
    return ListTile(
      leading: Icon(Icons.circle, color: color, size: 12),
      title: Text(status),
      onTap: () => Navigator.pop(ctx, status),
    );
  }

  void _showDetails(DevolucionModel dev) {
    showDialog(
      context: context,
      builder: (ctx) => ReturnDetailDialog(
        devolucion: dev,
        onDownloadInvoice: () => _downloadRefundInvoice(dev, ctx),
      ),
    );
  }

  Future<void> _downloadRefundInvoice(
      DevolucionModel dev, BuildContext ctx) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generando factura de reembolso...'),
          duration: Duration(seconds: 2),
        ),
      );

      final orderService = ref.read(orderServiceProvider);
      final invoiceService = ref.read(invoiceServiceProvider);

      // Fetch the full PedidoModel using ordenId
      final pedido = await orderService.getOrderById(dev.ordenId);
      if (pedido == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: No se pudo obtener el pedido original.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Ensure the refund details are attached
      final devolucionConPedido = dev.copyWith(pedido: pedido);

      // Generate the refund PDF (Factura rectificativa)
      final pdfFile =
          await invoiceService.generateRefundPdf(pedido, devolucionConPedido);

      // Open the PDF with the system viewer (works on Android, iOS, Windows, macOS)
      await OpenFile.open(pdfFile.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar factura de reembolso: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildHeader(
      int count, bool isLoading, List<DevolucionModel> allReturns) {
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
          const Icon(Icons.assignment_return_rounded, color: AppColors.navy),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gestión de Devoluciones',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy)),
              Text('$count devoluciones',
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
          if (!isLoading && allReturns.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: () => _showDownloadOptions(context, allReturns),
                icon: const Icon(Icons.picture_as_pdf_outlined,
                    color: AppColors.primary),
                tooltip: 'Descargar Resumen Devoluciones',
              ),
            ),
        ],
      ),
    );
  }

  void _showDownloadOptions(
      BuildContext context, List<DevolucionModel> allReturns) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Descargar Resumen Devoluciones',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy)),
              ),
              ListTile(
                leading: const Icon(Icons.today, color: AppColors.primary),
                title: const Text('Del día de hoy'),
                onTap: () {
                  Navigator.pop(context);
                  final now = DateTime.now();
                  final start = DateTime(now.year, now.month, now.day);
                  final end = start.add(const Duration(days: 1));
                  _downloadReturnsSummary(
                      allReturns, start, end, 'Devoluciones del día de hoy');
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_month,
                    color: AppColors.primary),
                title: const Text('De este mes'),
                onTap: () {
                  Navigator.pop(context);
                  final now = DateTime.now();
                  final start = DateTime(now.year, now.month, 1);
                  final end = DateTime(now.year, now.month + 1, 1);
                  _downloadReturnsSummary(
                      allReturns, start, end, 'Devoluciones de este mes');
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_week,
                    color: AppColors.primary),
                title: const Text('De este año'),
                onTap: () {
                  Navigator.pop(context);
                  final now = DateTime.now();
                  final start = DateTime(now.year, 1, 1);
                  final end = DateTime(now.year + 1, 1, 1);
                  _downloadReturnsSummary(
                      allReturns, start, end, 'Devoluciones del año');
                },
              ),
              ListTile(
                leading: const Icon(Icons.date_range, color: AppColors.primary),
                title: const Text('Filtrar por fecha...'),
                onTap: () async {
                  Navigator.pop(context);
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            onSurface: AppColors.navy,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    final end = picked.end.add(const Duration(days: 1));
                    _downloadReturnsSummary(allReturns, picked.start, end,
                        'Devoluciones Filtradas');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _downloadReturnsSummary(List<DevolucionModel> allReturns,
      DateTime start, DateTime end, String reportTitle) async {
    final filtered = allReturns.where((d) {
      final date = d.fechaSolicitud;
      if (date == null) return false;
      return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
          date.isBefore(end);
    }).toList();

    if (filtered.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No hay devoluciones en el rango seleccionado'),
              backgroundColor: Colors.orange),
        );
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(
                  child: Text(
                      'Generando informe para ${filtered.length} devoluciones...')),
            ],
          ),
        ),
      );
    }

    try {
      final invoiceService = ref.read(invoiceServiceProvider);
      final pdfFile =
          await invoiceService.generateReturnsSummaryPdf(filtered, reportTitle);

      if (mounted) {
        Navigator.pop(context); // close dialog
      }

      await OpenFile.open(pdfFile.path);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Buscar por número de devolución o pedido...',
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

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(adminNotifierProvider);
    var devoluciones = state.returns;

    final filtered = devoluciones.where((d) {
      final q = _searchQuery.toLowerCase();
      return d.numeroDevolucion.toLowerCase().contains(q) ||
          d.ordenId.toLowerCase().contains(q) ||
          d.motivo.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          _buildHeader(filtered.length, state.isLoading, devoluciones),
          _buildActions(),
          Expanded(
            child: state.isLoading && devoluciones.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_return_outlined,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('No hay devoluciones registradas',
                                style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final dev = filtered[i];
                          return ReturnCard(
                            devolucion: dev,
                            onTap: () => _showDetails(dev),
                            onStatusChange: () => _updateStatus(dev),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
