import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../data/models/admin_product.dart';
import '../../../data/models/admin_variant.dart';
import 'admin_productos_controller.dart';

class AdminProductosScreen extends ConsumerStatefulWidget {
  const AdminProductosScreen({super.key});

  @override
  ConsumerState<AdminProductosScreen> createState() =>
      _AdminProductosScreenState();
}

class _AdminProductosScreenState extends ConsumerState<AdminProductosScreen> {
  // ── Search ─────────────────────────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // ── Form state ─────────────────────────────────────────────────────────────
  AdminProduct? _editingProduct;
  bool _showForm = false;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _costoCtrl = TextEditingController();
  final _imagenCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedCatId;
  String? _selectedBrandId;
  bool _activo = true;

  // ── Variants ───────────────────────────────────────────────────────────────
  List<AdminVariant> _editingVariants = [];
  bool _hasCapacity = false;
  bool _hasColor = false;

  // New variant form fields
  final _varCapCtrl = TextEditingController();
  final _varColorCtrl = TextEditingController();
  final _varColorImgCtrl = TextEditingController();
  final _varSobreprecioCtrl = TextEditingController();
  final _varStockCtrl = TextEditingController();

  // Variants with pending delete (ids)
  final List<String> _variantsToDelete = [];

  // ── Toast ──────────────────────────────────────────────────────────────────
  String? _toastMessage;
  bool _toastIsError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProductosProvider.notifier).loadAll();
    });
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _costoCtrl.dispose();
    _imagenCtrl.dispose();
    _descCtrl.dispose();
    _varCapCtrl.dispose();
    _varColorCtrl.dispose();
    _varColorImgCtrl.dispose();
    _varSobreprecioCtrl.dispose();
    _varStockCtrl.dispose();
    super.dispose();
  }

  // ── Computed ───────────────────────────────────────────────────────────────
  int get _calculatedStock => _editingVariants
      .where((v) => !v.pendingDelete)
      .fold(0, (sum, v) => sum + v.stock);

  List<AdminProduct> _filteredProducts(List<AdminProduct> all) {
    if (_searchQuery.isEmpty) return all;
    return all.where((p) {
      final name = p.nombre.toLowerCase();
      final sku = (p.sku ?? '').toLowerCase();
      return name.contains(_searchQuery) || sku.contains(_searchQuery);
    }).toList();
  }

  // ── Open form ──────────────────────────────────────────────────────────────
  Future<void> _openForm(AdminProduct? product) async {
    _editingProduct = product;
    _editingVariants = [];
    _variantsToDelete.clear();

    if (product != null) {
      _nombreCtrl.text = product.nombre;
      _precioCtrl.text = product.precioEnEuros.toStringAsFixed(2);
      _costoCtrl.text = product.costoEnEuros?.toStringAsFixed(2) ?? '';
      _imagenCtrl.text = product.imagenUrl ?? '';
      _descCtrl.text = product.descripcion ?? '';
      _selectedCatId = product.categoriaId;
      _selectedBrandId = product.marcaId;
      _activo = product.activo;
      // Load variants
      final variants = await ref
          .read(adminProductosProvider.notifier)
          .loadVariants(product.id);
      _editingVariants = variants;
      _hasCapacity = variants.any((v) => (v.capacidad ?? '').isNotEmpty);
      _hasColor = variants.any((v) => (v.color ?? '').isNotEmpty);
    } else {
      _nombreCtrl.clear();
      _precioCtrl.clear();
      _costoCtrl.clear();
      _imagenCtrl.clear();
      _descCtrl.clear();
      _selectedCatId = null;
      _selectedBrandId = null;
      _activo = true;
      _hasCapacity = false;
      _hasColor = false;
    }

    setState(() => _showForm = true);
  }

  void _closeForm() => setState(() {
        _showForm = false;
        _editingProduct = null;
      });

  // ── Add variant ────────────────────────────────────────────────────────────
  void _addVariant() {
    final cap = _hasCapacity ? (_varCapCtrl.text.trim()) : '';
    final color = _hasColor ? (_varColorCtrl.text.trim()) : '';
    final colorImg = _hasColor ? (_varColorImgCtrl.text.trim()) : null;
    final stock = int.tryParse(_varStockCtrl.text.trim()) ?? 0;
    final sobreprecio =
        ((double.tryParse(_varSobreprecioCtrl.text.trim()) ?? 0) * 100).round();

    // Check for duplicate: same cap+color combination
    final existingIdx = _editingVariants.indexWhere(
        (v) => v.capacidad == cap && v.color == color && !v.pendingDelete);

    if (existingIdx >= 0) {
      // Update stock
      setState(() {
        _editingVariants[existingIdx].stock += stock;
      });
    } else {
      setState(() {
        _editingVariants.add(AdminVariant(
          id: 'new_${DateTime.now().millisecondsSinceEpoch}',
          productoId: _editingProduct?.id ?? '',
          talla: '',
          color: color.isEmpty ? null : color,
          capacidad: cap.isEmpty ? null : cap,
          stock: stock,
          imagenUrl: colorImg?.isEmpty == true ? null : colorImg,
          precioAdicional: sobreprecio,
        ));
      });
    }
    // Sync image url across same color variants
    if (colorImg != null && colorImg.isNotEmpty && color.isNotEmpty) {
      setState(() {
        for (var v in _editingVariants) {
          if (v.color == color && !v.pendingDelete) {
            v.imagenUrl == null;
          }
        }
      });
    }

    _varCapCtrl.clear();
    _varColorCtrl.clear();
    _varColorImgCtrl.clear();
    _varSobreprecioCtrl.clear();
    _varStockCtrl.clear();
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final precioEuros =
        double.tryParse(_precioCtrl.text.replaceAll(',', '.')) ?? 0;
    final costoEuros = double.tryParse(_costoCtrl.text.replaceAll(',', '.'));

    // Generate slug from nombre
    final nombre = _nombreCtrl.text.trim();
    final slug = nombre
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    final data = {
      'nombre': nombre,
      'descripcion': _descCtrl.text.trim(),
      'precio_venta': (precioEuros * 100).round(),
      'costo': costoEuros != null ? (costoEuros * 100).round() : null,
      'categoria_id': _selectedCatId,
      'marca_id': _selectedBrandId,
      'activo': _activo,
      'slug': slug,
      'imagen_url':
          _imagenCtrl.text.trim().isEmpty ? null : _imagenCtrl.text.trim(),
    };

    final success = await ref.read(adminProductosProvider.notifier).saveProduct(
          id: _editingProduct?.id,
          data: data,
          variants: _editingVariants,
          variantsToDelete: _variantsToDelete,
        );

    _showToast(
      success
          ? 'Producto guardado correctamente'
          : (ref.read(adminProductosProvider).error ?? 'Error al guardar'),
      isError: !success,
    );

    if (success) _closeForm();
  }

  // ── Delete ─────────────────────────────────────────────────────────────────
  Future<void> _deleteProduct(AdminProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
            '¿Estás seguro de que deseas eliminar "${product.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await ref
        .read(adminProductosProvider.notifier)
        .deleteProduct(product.id);
    _showToast(
      success
          ? 'Producto eliminado correctamente'
          : (ref.read(adminProductosProvider).error ?? 'Error'),
      isError: !success,
    );
  }

  // ── Toast ──────────────────────────────────────────────────────────────────
  void _showToast(String message, {bool isError = false}) {
    setState(() {
      _toastMessage = message;
      _toastIsError = isError;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProductosProvider);
    final filtered = _filteredProducts(state.products);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Stack(
      children: [
        if (isDesktop)
          // ── Desktop Layout (Side by Side) ───────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: _showForm ? 1 : 2,
                child: _buildListPanel(state, filtered),
              ),
              if (_showForm) ...[
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 2,
                  child: _buildFormPanel(state),
                ),
              ],
            ],
          )
        else
          // ── Mobile Layout (Switch) ──────────────────────────────────────
          _showForm ? _buildFormPanel(state) : _buildListPanel(state, filtered),

        // ── Toast ──────────────────────────────────────────────────────────
        if (_toastMessage != null)
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Center(
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: _toastIsError ? Colors.red[700] : Colors.green[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _toastIsError
                            ? Icons.error_outline
                            : Icons.check_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          _toastMessage!,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ──────────────────────────────── List Panel ─────────────────────────────
  Widget _buildListPanel(
      AdminProductosState state, List<AdminProduct> filtered) {
    return Column(
      children: [
        _buildHeader(state, filtered.length),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.indigo],
              ),
              borderRadius:
                  BorderRadius.circular(12), // Match SearchBar radius?
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
              label: const Text('Nuevo Producto',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size(
                    double.infinity, 56), // Ensure full width & height
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        _buildSearchBar(),
        Expanded(
          child: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.green))
              : filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) =>
                          _buildProductTile(filtered[i], state),
                    ),
        ),
      ],
    );
  }

  // ──────────────────────────────── Header ─────────────────────────────────
  Widget _buildHeader(AdminProductosState state, int count) {
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
          const Icon(Icons.inventory_2_rounded, color: AppColors.navy),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gestión de Productos',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy)),
              Text('$count productos',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          if (state.isSaving)
            const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }

  // ──────────────────────────────── Search ────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o SKU...',
          prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchCtrl.clear(),
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────── Empty ─────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(_searchQuery.isEmpty ? 'No hay productos aún' : 'Sin resultados',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }

  // ──────────────────────────────── Product Tile ──────────────────────────
  Widget _buildProductTile(AdminProduct p, AdminProductosState state) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 72,
                height: 72,
                child: p.imagenUrl != null
                    ? Tooltip(
                        message: p.imagenUrl!,
                        child: Container(
                          color: Colors.white,
                          child: Image.network(
                            p.imagenUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.broken_image_rounded,
                                  color: Colors.red, size: 32),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.image_not_supported_rounded,
                            color: Colors.grey, size: 32),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.navy)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _statusChip(p.activo),
                      const SizedBox(width: 6),
                      _stockChip(p.stockTotal),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (p.sku != null)
                    Text(p.sku!,
                        style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.grey.shade500)),
                  const SizedBox(height: 6),
                  Text(
                    '${p.precioEnEuros.toStringAsFixed(2)}€',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy),
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: Colors.blue, size: 20),
                  tooltip: 'Editar',
                  onPressed: () => _openForm(p),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  tooltip: 'Eliminar',
                  onPressed: () => _deleteProduct(p),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stockChip(int stock) {
    final empty = stock == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: empty ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: empty ? Colors.red.shade200 : Colors.green.shade200),
      ),
      child: Text(
        '$stock uds',
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: empty ? Colors.red.shade700 : Colors.green.shade700),
      ),
    );
  }

  Widget _statusChip(bool activo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: activo ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: activo ? Colors.green.shade200 : Colors.grey.shade300),
      ),
      child: Text(
        activo ? 'Activo' : 'Inactivo',
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: activo ? Colors.green.shade700 : Colors.grey.shade600),
      ),
    );
  }

  // ──────────────────────────────── Form Panel ────────────────────────────
  Widget _buildFormPanel(AdminProductosState state) {
    return Container(
      color: Colors.blue.shade50,
      child: Column(
        children: [
          // Panel header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Icon(
                    _editingProduct == null
                        ? Icons.add_circle_outline
                        : Icons.edit_outlined,
                    color: AppColors.navy),
                const SizedBox(width: 10),
                Text(
                  _editingProduct == null
                      ? 'Nuevo Producto'
                      : 'Editar: ${_editingProduct!.nombre}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _closeForm,
                  tooltip: 'Cerrar',
                ),
              ],
            ),
          ),
          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFormFields(state),
                    const SizedBox(height: 24),
                    _buildVariantsSection(),
                    const SizedBox(height: 24),
                    _buildFormActions(state),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(AdminProductosState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Nombre
        _label('Nombre del Producto *'),
        TextFormField(
          controller: _nombreCtrl,
          decoration: _inputDecor('ej: Nike Air Max 270'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
        ),
        const SizedBox(height: 16),

        // Categoría & Marca
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Categoría'),
                  DropdownButtonFormField<String>(
                    value: _selectedCatId,
                    decoration: _inputDecor('Seleccionar'),
                    items: state.categories
                        .map((c) => DropdownMenuItem(
                            value: c.id, child: Text(c.nombre)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCatId = v),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Marca'),
                  DropdownButtonFormField<String>(
                    value: _selectedBrandId,
                    decoration: _inputDecor('Seleccionar'),
                    items: state.brands
                        .map((b) => DropdownMenuItem(
                            value: b.id, child: Text(b.nombre)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedBrandId = v),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // SKU (read-only for edits)
        if (_editingProduct?.sku != null) ...[
          _label('SKU (solo lectura)'),
          TextFormField(
            initialValue: _editingProduct!.sku,
            enabled: false,
            style: const TextStyle(fontFamily: 'monospace'),
            decoration: _inputDecor(''),
          ),
          const SizedBox(height: 16),
        ],

        // Precio & Costo
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Precio Venta (€) *'),
                  TextFormField(
                    controller: _precioCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecor('0.00'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Obligatorio';
                      }
                      if (double.tryParse(v.replaceAll(',', '.')) == null) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Precio Costo (€)'),
                  TextFormField(
                    controller: _costoCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecor('0.00'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Stock total (read-only calculated)
        _label('Stock Total (calculado)'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '$_calculatedStock unidades',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),

        // Image URL
        _label('URL Imagen'),
        TextFormField(
          controller: _imagenCtrl,
          decoration: _inputDecor('https://...'),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),

        // Descripción
        _label('Descripción *'),
        TextFormField(
          controller: _descCtrl,
          minLines: 4,
          maxLines: 6,
          decoration: _inputDecor('Descripción del producto...'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ──────────────────────────────── Variants ──────────────────────────────
  Widget _buildVariantsSection() {
    final grouped = <String, List<AdminVariant>>{};
    for (final v in _editingVariants.where((v) => !v.pendingDelete)) {
      final key = v.capacidad ?? 'Sin capacidad';
      grouped.putIfAbsent(key, () => []).add(v);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gestión de Variantes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),

          // Config checkboxes
          Row(
            children: [
              Checkbox(
                value: _hasCapacity,
                onChanged: (v) => setState(() => _hasCapacity = v ?? false),
                activeColor: Colors.blue,
              ),
              const Text('Tiene Capacidades (ej: 64GB, 128GB)',
                  style: TextStyle(fontSize: 13)),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: _hasColor,
                onChanged: (v) => setState(() => _hasColor = v ?? false),
                activeColor: Colors.blue,
              ),
              const Text('Tiene Colores', style: TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),

          // Add variant form
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Añadir Variante',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 10),
                if (_hasCapacity) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _varCapCtrl,
                          decoration: _inputDecor('Capacidad (ej: 128GB)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _varSobreprecioCtrl,
                          decoration: _inputDecor('Sobreprecio +€'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (_hasColor) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _varColorCtrl,
                          decoration: _inputDecor('Color'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _varColorImgCtrl,
                          decoration: _inputDecor('URL imagen color'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _varStockCtrl,
                        decoration: _inputDecor('Stock'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addVariant,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Añadir'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Existing variants grouped by capacity
          if (_editingVariants.where((v) => !v.pendingDelete).isEmpty)
            Text('Sin variantes', style: TextStyle(color: Colors.grey.shade500))
          else
            ...grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasCapacity) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(entry.key,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.blue)),
                    ),
                  ],
                  ...entry.value.map((v) => _buildVariantRow(v)),
                  const SizedBox(height: 8),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildVariantRow(AdminVariant v) {
    final isEmpty = v.stock == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isEmpty ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isEmpty ? Colors.red.shade200 : Colors.green.shade200),
      ),
      child: Row(
        children: [
          if (_hasColor && v.color != null)
            Expanded(
                child: Text(v.color!,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
          if (_hasCapacity && v.capacidad != null && !_hasColor)
            Expanded(
                child: Text(v.capacidad!,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
          if (v.precioAdicional > 0)
            Text('+${v.precioAdicionalEuros.toStringAsFixed(2)}€  ',
                style: const TextStyle(fontSize: 12, color: Colors.indigo)),
          // Inline stock edit
          SizedBox(
            width: 70,
            child: TextFormField(
              initialValue: v.stock.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onChanged: (val) {
                final parsed = int.tryParse(val);
                if (parsed != null) {
                  setState(() => v.stock = parsed);
                }
              },
            ),
          ),
          const SizedBox(width: 4),
          const Text('uds', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              setState(() {
                v.pendingDelete = true;
                if (!v.id.startsWith('new_')) {
                  _variantsToDelete.add(v.id);
                }
              });
            },
            child: const Icon(Icons.close, size: 18, color: Colors.red),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────── Form Footer ───────────────────────────
  Widget _buildFormActions(AdminProductosState state) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _closeForm,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: state.isSaving ? null : _save,
            icon: state.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded),
            label: Text(state.isSaving ? 'Guardando...' : 'Guardar Producto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────── Helpers ───────────────────────────────
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.navy)),
      );

  InputDecoration _inputDecor(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
      );
}
