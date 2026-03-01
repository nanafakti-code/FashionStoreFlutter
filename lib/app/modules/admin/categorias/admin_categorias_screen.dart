import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../config/theme/app_colors.dart';
import 'admin_categorias_controller.dart';
import '../../../data/models/admin_category.dart';
import 'widgets/category_card.dart';

class AdminCategoriasScreen extends ConsumerStatefulWidget {
  const AdminCategoriasScreen({super.key});

  @override
  ConsumerState<AdminCategoriasScreen> createState() =>
      _AdminCategoriasScreenState();
}

class _AdminCategoriasScreenState extends ConsumerState<AdminCategoriasScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _activa = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(adminCategoriasProvider.notifier).loadCategories());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nombreCtrl.dispose();
    _slugCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _openForm(AdminCategory? category) {
    if (category != null) {
      _nombreCtrl.text = category.nombre;
      _slugCtrl.text = category.slug;
      _descCtrl.text = category.descripcion ?? '';
      _activa = category.active;
    } else {
      _nombreCtrl.clear();
      _slugCtrl.clear();
      _descCtrl.clear();
      _activa = true;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category == null ? 'Nueva Categoría' : 'Editar Categoría'),
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
                  onChanged: (val) {
                    if (category == null) {
                      _slugCtrl.text = val
                          .toLowerCase()
                          .replaceAll(RegExp(r'\s+'), '-')
                          .replaceAll(RegExp(r'[^a-z0-9-]'), '');
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _slugCtrl,
                  decoration: const InputDecoration(labelText: 'Slug *'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final success = await ref
                    .read(adminCategoriasProvider.notifier)
                    .saveCategory(
                      id: category?.id,
                      nombre: _nombreCtrl.text.trim(),
                      slug: _slugCtrl.text.trim(),
                      descripcion: _descCtrl.text.trim(),
                      activa: _activa,
                    );
                if (success && mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar categoría?'),
        content: const Text(
            'Esta acción no se puede deshacer. Los productos en esta categoría podrían quedar huérfanos.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(adminCategoriasProvider.notifier)
                  .deleteCategory(id);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count, bool isSaving) {
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
          const Icon(Icons.category_rounded, color: AppColors.navy),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gestión de Categorías',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy)),
              Text('$count categorías',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          if (isSaving)
            const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCategoriasProvider);

    // Filter
    final filtered = state.categories.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.nombre.toLowerCase().contains(q) ||
          c.slug.toLowerCase().contains(q);
    }).toList();

    ref.listen(adminCategoriasProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.error!), backgroundColor: Colors.red));
        ref.read(adminCategoriasProvider.notifier).clearMessages();
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.green));
        ref.read(adminCategoriasProvider.notifier).clearMessages();
      }
    });

    return Column(
      children: [
        // Header
        _buildHeader(filtered.length, state.isSaving),

        // New Category Button + Search
        Padding(
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
                  icon: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 28),
                  label: const Text('Nueva Categoría',
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
        ),

        // List
        Expanded(
          child: state.isLoading && state.categories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No hay categorías',
                              style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => CategoryCard(
                        category: filtered[i],
                        onEdit: () => _openForm(filtered[i]),
                        onDelete: () => _deleteCategory(filtered[i].id),
                      ),
                    ),
        ),
      ],
    );
  }
}
