import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../data/services/admin_service.dart';

class AdminOfertasScreen extends ConsumerStatefulWidget {
  const AdminOfertasScreen({super.key});

  @override
  ConsumerState<AdminOfertasScreen> createState() => _AdminOfertasScreenState();
}

class _AdminOfertasScreenState extends ConsumerState<AdminOfertasScreen> {
  final _adminService = AdminService();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  bool _showOnlyOffers = false;
  bool _showWithoutOffers = false;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
        _applyFilters();
      });
    });
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await _adminService.getProductsForOffers();
    setState(() {
      _products = products;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    var list = List<Map<String, dynamic>>.from(_products);
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) => (p['nombre'] as String? ?? '')
              .toLowerCase()
              .contains(_searchQuery))
          .toList();
    }
    if (_showOnlyOffers) {
      list = list.where((p) => _isOnOffer(p)).toList();
    } else if (_showWithoutOffers) {
      list = list.where((p) => !_isOnOffer(p)).toList();
    }
    _filtered = list;
  }

  String? _getProductImage(Map<String, dynamic> product) {
    if (product['variantes_producto'] != null &&
        product['variantes_producto'] is List) {
      final vars = product['variantes_producto'] as List;
      for (var v in vars) {
        if (v['imagen_url'] != null) return v['imagen_url'] as String;
      }
    }
    if (product['imagenes_producto'] != null &&
        product['imagenes_producto'] is List) {
      final imgs = product['imagenes_producto'] as List;
      if (imgs.isNotEmpty && imgs.first['url'] != null) {
        return imgs.first['url'] as String;
      }
    }
    return null;
  }

  bool _isOnOffer(Map<String, dynamic> product) {
    final precioOriginal = product['precio_original'] as int?;
    final precioVenta = product['precio_venta'] as int? ?? 0;
    return precioOriginal != null && precioOriginal > precioVenta;
  }

  int _getDiscountPercent(Map<String, dynamic> product) {
    final precioOriginal = product['precio_original'] as int?;
    final precioVenta = product['precio_venta'] as int? ?? 0;
    if (precioOriginal == null || precioOriginal <= precioVenta) return 0;
    return (((precioOriginal - precioVenta) / precioOriginal) * 100).round();
  }

  // ─────────────────────────────── Offer Dialog ────────────────────────────
  Future<void> _showOfferDialog(Map<String, dynamic> product) async {
    final nombre = product['nombre'] as String? ?? 'Producto';
    final precioVenta = product['precio_venta'] as int? ?? 0;
    final precioOriginal = product['precio_original'] as int?;
    final isCurrentlyOnOffer = _isOnOffer(product);
    final imageUrl = _getProductImage(product);

    // The "real" base price is precio_original if on offer, otherwise precio_venta
    final precioBase = isCurrentlyOnOffer ? precioOriginal! : precioVenta;

    final priceController = TextEditingController(
      text: isCurrentlyOnOffer ? (precioVenta / 100).toStringAsFixed(2) : '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        int selectedPct = 0;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final currentText = priceController.text.replaceAll(',', '.');
            final currentPrice = double.tryParse(currentText);
            final previewPct = currentPrice != null &&
                    currentPrice > 0 &&
                    currentPrice < precioBase / 100
                ? (((precioBase / 100 - currentPrice) / (precioBase / 100)) *
                        100)
                    .round()
                : 0;

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Title ──
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isCurrentlyOnOffer
                                    ? Icons.edit_rounded
                                    : Icons.discount_rounded,
                                color: AppColors.green,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isCurrentlyOnOffer
                                  ? 'Editar Oferta'
                                  : 'Nueva Oferta',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navy),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Product card ──
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 52,
                                  height: 52,
                                  child: imageUrl != null
                                      ? Image.network(imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                  color: Colors.grey.shade100,
                                                  child: const Icon(
                                                      Icons.broken_image,
                                                      size: 20)))
                                      : Container(
                                          color: Colors.grey.shade100,
                                          child: const Icon(
                                              Icons.image_not_supported,
                                              size: 20,
                                              color: Colors.grey)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nombre,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.navy)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${(precioBase / 100).toStringAsFixed(2)}€',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.navy),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Discount grid ──
                        const Text('Seleccionar descuento',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.navy)),
                        const SizedBox(height: 10),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.6,
                          children: [5, 10, 15, 20, 25, 50].map((pct) {
                            final newPrice =
                                (precioBase * (100 - pct) / 100).round();
                            final isSelected = selectedPct == pct;
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedPct = pct;
                                  priceController.text =
                                      (newPrice / 100).toStringAsFixed(2);
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            Colors.green.shade600,
                                            Colors.green.shade400,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.green.shade400
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.green.withOpacity(0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '-$pct%',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${(newPrice / 100).toStringAsFixed(2)}€',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.85)
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // ── Divider ──
                        Row(
                          children: [
                            Expanded(
                                child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('o introduce el precio',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500)),
                            ),
                            Expanded(
                                child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Price input ──
                        TextField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (_) =>
                              setDialogState(() => selectedPct = 0),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.euro_rounded,
                                color: AppColors.green),
                            hintText:
                                (precioBase * 0.8 / 100).toStringAsFixed(2),
                            hintStyle: TextStyle(color: Colors.grey.shade300),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.green, width: 2),
                            ),
                          ),
                        ),

                        // ── Savings preview ──
                        if (previewPct > 0) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_downward_rounded,
                                    size: 14, color: Colors.green.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  '-$previewPct% · Ahorro ${((precioBase / 100) - currentPrice!).toStringAsFixed(2)}€',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green.shade700),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // ── Apply button ──
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(ctx, priceController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Aplicar Oferta',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        const SizedBox(height: 8),
                        if (isCurrentlyOnOffer) ...[
                          OutlinedButton(
                            onPressed: () => Navigator.pop(ctx, 'REMOVE'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Quitar Oferta',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 8),
                        ],
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Cancelar',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) return;

    if (result == 'REMOVE') {
      final success = await _adminService.removeProductOffer(
          product['id'] as String, precioOriginal!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Oferta eliminada — precio restaurado'),
              backgroundColor: Colors.orange),
        );
        _loadProducts();
      }
      return;
    }

    final price = double.tryParse(result.replaceAll(',', '.'));
    if (price == null || price <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Precio inválido'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final newPriceInCents = (price * 100).round();
    if (newPriceInCents >= precioBase) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'El precio de oferta debe ser menor que ${(precioBase / 100).toStringAsFixed(2)}€'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final success = await _adminService.setProductOffer(
        product['id'] as String, newPriceInCents, precioBase);
    if (success && mounted) {
      final pct = (((precioBase - newPriceInCents) / precioBase) * 100).round();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Oferta aplicada: -$pct% descuento'),
            backgroundColor: Colors.green),
      );
      _loadProducts();
    }
  }

  // ─────── Deactivate all offers ───────────────────────────────────────────
  Future<void> _confirmDeactivateAll(int offersCount) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text('Desactivar todas',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar las $offersCount ofertas activas?\n\nTodos los precios se restaurarán a su valor original.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sí, desactivar todas'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);
    final count = await _adminService.removeAllOffers();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count ofertas eliminadas — precios restaurados'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadProducts();
    }
  }

  // ─────── Bulk discount dialog ───────────────────────────────────────────
  Future<void> _showBulkDiscountDialog() async {
    int selectedPct = 0;
    final productsWithoutOffer = _products.where((p) => !_isOnOffer(p)).length;

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.flash_on_rounded,
                              color: Colors.green.shade700, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('Descuento Global',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.navy)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Se aplicará a $productsWithoutOffer productos sin oferta',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    const Text('Seleccionar descuento',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.navy)),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.8,
                      children: [5, 10, 15, 20, 25, 50].map((pct) {
                        final isSelected = selectedPct == pct;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedPct = pct),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(colors: [
                                      Colors.green.shade600,
                                      Colors.green.shade400,
                                    ])
                                  : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.green.shade400
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '-$pct%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: selectedPct > 0
                          ? () => Navigator.pop(ctx, selectedPct)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade200,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        selectedPct > 0
                            ? 'Aplicar -$selectedPct% a $productsWithoutOffer productos'
                            : 'Selecciona un descuento',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancelar',
                          style: TextStyle(color: Colors.grey.shade500)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) return;

    setState(() => _isLoading = true);
    final count = await _adminService.applyBulkDiscount(result);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('-$result% aplicado a $count productos'),
          backgroundColor: Colors.green,
        ),
      );
      _loadProducts();
    }
  }

  // ─────────────────────────────────────────────────────────────── BUILD
  @override
  Widget build(BuildContext context) {
    final offersCount = _products.where((p) => _isOnOffer(p)).length;

    return Column(
      children: [
        // ── Header ──
        _buildHeader(offersCount),
        // ── Filter chip row ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              FilterChip(
                avatar: Icon(Icons.local_offer_rounded,
                    size: 16,
                    color: _showOnlyOffers
                        ? AppColors.green
                        : Colors.grey.shade500),
                label: Text('Con oferta ($offersCount)'),
                selected: _showOnlyOffers,
                onSelected: (val) {
                  setState(() {
                    _showOnlyOffers = val;
                    if (val) _showWithoutOffers = false;
                    _applyFilters();
                  });
                },
                selectedColor: AppColors.green.withOpacity(0.12),
                checkmarkColor: AppColors.green,
                labelStyle: TextStyle(
                  color:
                      _showOnlyOffers ? AppColors.green : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                side: BorderSide(
                    color: _showOnlyOffers
                        ? AppColors.green.withOpacity(0.4)
                        : Colors.grey.shade300),
              ),
              const SizedBox(width: 8),
              FilterChip(
                avatar: Icon(Icons.local_offer_outlined,
                    size: 16,
                    color: _showWithoutOffers
                        ? Colors.orange
                        : Colors.grey.shade500),
                label: Text('Sin oferta (${_products.length - offersCount})'),
                selected: _showWithoutOffers,
                onSelected: (val) {
                  setState(() {
                    _showWithoutOffers = val;
                    if (val) _showOnlyOffers = false;
                    _applyFilters();
                  });
                },
                selectedColor: Colors.orange.withOpacity(0.12),
                checkmarkColor: Colors.orange,
                labelStyle: TextStyle(
                  color:
                      _showWithoutOffers ? Colors.orange : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                side: BorderSide(
                    color: _showWithoutOffers
                        ? Colors.orange.withOpacity(0.4)
                        : Colors.grey.shade300),
              ),
            ],
          ),
        ),
        // ── Search bar ──
        _buildSearchBar(),
        // ── List ──
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.green))
              : _filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _buildProductTile(_filtered[i]),
                    ),
        ),
      ],
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(int offersCount) {
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
          const Icon(Icons.local_offer_rounded, color: AppColors.navy),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gestión de Ofertas',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy)),
              Text('$offersCount productos en oferta',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.navy),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'deactivate_all') {
                _confirmDeactivateAll(offersCount);
              } else if (value == 'activate_all') {
                _showBulkDiscountDialog();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'activate_all',
                child: Row(
                  children: [
                    Icon(Icons.flash_on_rounded,
                        size: 20, color: Colors.green.shade700),
                    const SizedBox(width: 10),
                    const Text('Aplicar descuento global',
                        style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              if (offersCount > 0)
                PopupMenuItem(
                  value: 'deactivate_all',
                  child: Row(
                    children: [
                      Icon(Icons.remove_circle_outline,
                          size: 20, color: Colors.red.shade700),
                      const SizedBox(width: 10),
                      const Text('Desactivar todas',
                          style: TextStyle(fontSize: 14, color: Colors.red)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre de producto...',
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

  // ── Empty state ──────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_offer_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(_searchQuery.isEmpty ? 'No hay productos aún' : 'Sin resultados',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }

  // ── Product Tile ────────────────────────────────────────────────────────
  Widget _buildProductTile(Map<String, dynamic> product) {
    final nombre = product['nombre'] as String? ?? 'Producto';
    final precioVenta = product['precio_venta'] as int? ?? 0;
    final isOnOffer = _isOnOffer(product);
    final precioOriginal = product['precio_original'] as int?;
    final discountPercent = _getDiscountPercent(product);
    final imageUrl = _getProductImage(product);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOnOffer ? Colors.green.withOpacity(0.4) : AppColors.border,
        ),
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
                child: imageUrl != null
                    ? Container(
                        color: Colors.white,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.broken_image_rounded,
                                color: Colors.red, size: 32),
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
                  Text(nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.navy)),
                  const SizedBox(height: 4),
                  // Status chips
                  Row(
                    children: [
                      _offerChip(isOnOffer),
                      if (isOnOffer) ...[
                        const SizedBox(width: 6),
                        _discountChip(discountPercent),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Prices
                  Row(
                    children: [
                      if (isOnOffer) ...[
                        Text(
                          '${(precioOriginal! / 100).toStringAsFixed(2)}€',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${(precioVenta / 100).toStringAsFixed(2)}€',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isOnOffer ? Colors.green : AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    isOnOffer ? Icons.edit_outlined : Icons.add_circle_outline,
                    color: isOnOffer ? Colors.blue : AppColors.green,
                    size: 20,
                  ),
                  tooltip: isOnOffer ? 'Editar oferta' : 'Añadir oferta',
                  onPressed: () => _showOfferDialog(product),
                ),
                if (isOnOffer)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    tooltip: 'Quitar oferta',
                    onPressed: () async {
                      final success = await _adminService.removeProductOffer(
                          product['id'] as String, precioOriginal!);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Oferta eliminada — precio restaurado'),
                              backgroundColor: Colors.orange),
                        );
                        _loadProducts();
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _offerChip(bool isOnOffer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOnOffer ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isOnOffer ? Colors.green.shade200 : Colors.grey.shade300),
      ),
      child: Text(
        isOnOffer ? 'En oferta' : 'Sin oferta',
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isOnOffer ? Colors.green.shade700 : Colors.grey.shade600),
      ),
    );
  }

  Widget _discountChip(int percent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        '-$percent%',
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.red.shade700),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
