import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/producto.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../widgets/widgets.dart';
import '../config/app_theme.dart';

/// Pantalla de detalle de producto
class ProductDetailScreen extends StatefulWidget {
  final String productSlug;

  const ProductDetailScreen({
    super.key,
    required this.productSlug,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();

  Producto? _producto;
  List<Producto> _relacionados = [];
  bool _isLoading = true;
  String? _error;

  int _selectedImageIndex = 0;
  String? _selectedTalla;
  String? _selectedColor;
  int _cantidad = 1;

  @override
  void initState() {
    super.initState();
    _loadProducto();
  }

  Future<void> _loadProducto() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final producto =
          await _productService.getProductoBySlug(widget.productSlug);

      if (producto == null) {
        setState(() {
          _error = 'Producto no encontrado';
          _isLoading = false;
        });
        return;
      }

      final relacionados = await _productService.getProductosRelacionados(
        producto.id,
        limit: 4,
      );

      setState(() {
        _producto = producto;
        _relacionados = relacionados;
        _isLoading = false;

        // Seleccionar primera variante por defecto
        if (producto.variantes.isNotEmpty) {
          final firstVariante = producto.variantes.first;
          _selectedTalla = firstVariante.talla;
          _selectedColor = firstVariante.color;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando producto: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Cargando producto...'),
      );
    }

    if (_error != null || _producto == null) {
      return Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: _error ?? 'Producto no encontrado',
          onRetry: _loadProducto,
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return _buildMobileLayout();
    } else {
      return _buildTabletLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.text),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border,
                      color: AppColors.text),
                ),
                onPressed: () {
                  showSnackBar(context, 'Añadido a favoritos',
                      isSuccess: true);
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: AppColors.text),
                ),
                onPressed: () {
                  showSnackBar(context, 'Compartir producto');
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                    ResponsiveHelper.getPadding(context)),
                child: _buildProductDetails(),
              ),
            ),
          ),

          // Productos relacionados
          if (_relacionados.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(
                    ResponsiveHelper.getPadding(context)),
                child: _buildRelatedProducts(),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionBar(),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.text),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border,
                    color: AppColors.text),
                onPressed: () {
                  showSnackBar(context, 'Añadido a favoritos',
                      isSuccess: true);
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.text),
                onPressed: () {
                  showSnackBar(context, 'Compartir producto');
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(
                    ResponsiveHelper.getPadding(context)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _buildImageGallery(),
                      ),
                    ),
                    SizedBox(
                        width: ResponsiveHelper.getPadding(context) * 1.5),
                    // Contenido
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductDetails(),
                          const SizedBox(height: 40),
                          _buildActionBar(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_relacionados.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(
                    ResponsiveHelper.getPadding(context)),
                child: _buildRelatedProducts(),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categoría y valoración
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_producto!.categoria != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _producto!.categoria!.nombre,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            if (_producto!.totalResenas > 0)
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _producto!.valoracionPromedio
                        .toStringAsFixed(1),
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    ' (${_producto!.totalResenas})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Nombre
        Text(
          _producto!.nombre,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 14),

        // Precio
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_producto!.precioEnEuros.toStringAsFixed(2)}€',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (_producto!.enOferta) ...[
              const SizedBox(width: 12),
              Text(
                '${_producto!.precioOriginalEnEuros?.toStringAsFixed(2)}€',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '-${_producto!.descuento}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // Stock
        Row(
          children: [
            Icon(
              _producto!.tieneStock
                  ? Icons.check_circle
                  : Icons.cancel,
              color: _producto!.tieneStock
                  ? AppColors.success
                  : AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _producto!.tieneStock
                  ? 'En stock (${_producto!.stockTotal} disponibles)'
                  : 'Agotado',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _producto!.tieneStock
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Descripción
        if (_producto!.descripcion != null &&
            _producto!.descripcion!.isNotEmpty) ...[
          Text(
            'Descripción',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _producto!.descripcion ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildRelatedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productos relacionados',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                ResponsiveHelper.getGridCrossAxisCount(context).toInt(),
            childAspectRatio: 0.62,
            crossAxisSpacing: ResponsiveHelper.getPadding(context) / 2,
            mainAxisSpacing: ResponsiveHelper.getPadding(context) / 2,
          ),
          itemCount: _relacionados.length,
          itemBuilder: (context, index) {
            final producto = _relacionados[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/product/${producto.slug}',
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          color: Colors.grey[50],
                          child: CachedNetworkImage(
                            imageUrl: producto.imagenPrincipal ??
                                'https://via.placeholder.com/300',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto.nombre,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${producto.precioEnEuros.toStringAsFixed(2)}€',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getPadding(context),
        vertical: ResponsiveHelper.getPadding(context) * 0.75,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _cantidad > 1
                          ? () => setState(() => _cantidad--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 50,
                      child: Center(
                        child: Text(
                          _cantidad.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _cantidad < (_producto?.stockTotal ?? 1)
                          ? () => setState(() => _cantidad++)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _producto!.tieneStock
                      ? () => _addToCart()
                      : null,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Añadir al carrito'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    final imagenes = _producto!.imagenes;
    if (imagenes.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image, size: 64, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: imagenes.length,
          onPageChanged: (index) {
            setState(() => _selectedImageIndex = index);
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: imagenes[index],
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
            );
          },
        ),
        if (imagenes.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imagenes.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedImageIndex == index
                        ? AppColors.primary
                        : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _addToCart() async {
    try {
      final success = await _cartService.addToCart(
        productoId: _producto!.id,
        productoNombre: _producto!.nombre,
        precio: _producto!.precioVenta,
        imagen: _producto!.imagenPrincipal,
        cantidad: _cantidad,
        talla: _selectedTalla,
        color: _selectedColor,
      );

      if (success) {
        showSnackBar(context, '${_producto!.nombre} añadido al carrito',
            isSuccess: true);
      } else {
        showSnackBar(context, 'Error al añadir al carrito', isError: true);
      }
    } catch (e) {
      showSnackBar(context, 'Error: $e', isError: true);
    }
  }
}
