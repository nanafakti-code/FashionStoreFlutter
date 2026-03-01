import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_brands_controller.dart';
import '../../../../config/theme/app_colors.dart';
import 'widgets/brand_card.dart';

class AdminBrandsScreen extends ConsumerStatefulWidget {
  const AdminBrandsScreen({super.key});

  @override
  ConsumerState<AdminBrandsScreen> createState() => _AdminBrandsScreenState();
}

class _AdminBrandsScreenState extends ConsumerState<AdminBrandsScreen> {
  // Form State
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _activo = true;

  // Search State
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  AdminBrand? _editingBrand;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminBrandsProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _slugCtrl.dispose();
    _descCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  void _openForm(AdminBrand? brand) {
    _editingBrand = brand;
    if (brand != null) {
      _nombreCtrl.text = brand.nombre;
      _slugCtrl.text = brand.slug;
      _descCtrl.text = brand.descripcion ?? '';
      _activo = brand.activa;
    } else {
      _nombreCtrl.clear();
      _slugCtrl.clear();
      _descCtrl.clear();
      _activo = true;
    }

    showDialog(context: context, builder: (_) => _buildDialog());
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'nombre': _nombreCtrl.text.trim(),
      'slug': _slugCtrl.text.trim().isEmpty
          ? _nombreCtrl.text.trim().toLowerCase().replaceAll(' ', '-')
          : _slugCtrl.text.trim(),
      'descripcion':
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'activa': _activo,
    };

    final success = await ref
        .read(adminBrandsProvider.notifier)
        .saveBrand(_editingBrand?.id, data);

    if (success && mounted) {
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Guardado correctamente'),
            backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _delete(AdminBrand brand) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content:
            Text('¿Seguro que quieres eliminar la marca "${brand.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(adminBrandsProvider.notifier).deleteBrand(brand.id);
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
          const Icon(Icons.branding_watermark_rounded, color: AppColors.navy),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gestión de Marcas',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy)),
              Text('$count marcas',
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
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.indigo],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _openForm(null),
              icon:
                  const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              label: const Text('Nueva Marca',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 56), // Full width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o slug...',
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
        ],
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminBrandsProvider);

    // Filter
    final filtered = state.brands.where((b) {
      final q = _searchQuery.toLowerCase();
      return b.nombre.toLowerCase().contains(q) ||
          b.slug.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          _buildHeader(filtered.length, state.isLoading),

          // Actions
          _buildActions(),

          // List
          Expanded(
            child: state.isLoading && state.brands.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.branding_watermark_outlined,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('No hay marcas registradas',
                                style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final brand = filtered[i];
                          return BrandCard(
                            brand: brand,
                            onEdit: () => _openForm(brand),
                            onDelete: () => _delete(brand),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialog() {
    return AlertDialog(
      title: Text(_editingBrand == null ? 'Nueva Marca' : 'Editar Marca'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre *'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _slugCtrl,
                decoration: const InputDecoration(labelText: 'Slug (opcional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        ElevatedButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}
