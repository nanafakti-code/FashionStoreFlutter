import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/producto.dart';
import '../services/product_service.dart';
import '../config/app_theme.dart';

/// Pantalla de lista de productos
class ProductListScreen extends StatefulWidget {
  final String? categorySlug;
  final String? brandSlug;
  final String? searchQuery;

  const ProductListScreen({
    super.key,
    this.categorySlug,
    this.brandSlug,
    this.searchQuery,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();

  List<Producto> _productos = [];
  bool _isLoading = true;
  String _sortBy = 'creado_en';
  bool _sortAsc = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      final productos = await _productService.getProductos(
        categoriaId: widget.categorySlug,
        marcaId: widget.brandSlug,
        busqueda: widget.searchQuery,
        ordenarPor: _sortBy,
        ascendente: _sortAsc,
        limit: 50,
      );

      setState(() {
        _productos = productos.isNotEmpty ? productos : _getSampleProducts();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _productos = _getSampleProducts();
        _isLoading = false;
      });
    }
  }

  List<Producto> _getSampleProducts() {
    return [
      Producto(
        id: '1',
        nombre: 'iPhone 15 Pro Max 256GB',
        slug: 'iphone-15-pro-max',
        descripcion: 'Como nuevo, garantía 12 meses',
        precioVenta: 109900,
        precioOriginal: 149900,
        stockTotal: 5,
        activo: true,
        destacado: true,
        imagenes: [
          'https://cdsassets.apple.com/live/7WUAS350/images/tech-specs/iphone-15-pro-max.png'
        ],
        valoracionPromedio: 4.8,
        totalResenas: 127,
        categoria:
            Categoria(id: '1', nombre: 'Smartphones', slug: 'smartphones'),
      ),
      Producto(
        id: '2',
        nombre: 'MacBook Air M2 13"',
        slug: 'macbook-air-m2',
        descripcion: 'Excelente estado, batería al 95%',
        precioVenta: 89900,
        precioOriginal: 119900,
        stockTotal: 3,
        activo: true,
        destacado: true,
        imagenes: [
          'https://cdsassets.apple.com/live/7WUAS350/images/tech-specs/16-mbp.png'
        ],
        valoracionPromedio: 4.9,
        totalResenas: 89,
        categoria: Categoria(id: '2', nombre: 'Laptops', slug: 'laptops'),
      ),
      Producto(
        id: '3',
        nombre: 'iPad Pro 12.9" M2',
        slug: 'ipad-pro-m2',
        descripcion: 'Perfecto estado, incluye estuche',
        precioVenta: 79900,
        precioOriginal: 99900,
        stockTotal: 4,
        activo: true,
        destacado: true,
        imagenes: [
          'https://cdsassets.apple.com/live/7WUAS350/images/tech-specs/ipad-pro-12-9-in.png'
        ],
        valoracionPromedio: 4.7,
        totalResenas: 56,
        categoria: Categoria(id: '3', nombre: 'Tablets', slug: 'tablets'),
      ),
      Producto(
        id: '4',
        nombre: 'AirPods Pro 2ª Gen',
        slug: 'airpods-pro-2',
        descripcion: 'Cancelación de ruido activa',
        precioVenta: 19900,
        precioOriginal: 27900,
        stockTotal: 12,
        activo: true,
        destacado: true,
        imagenes: [
          'https://cdsassets.apple.com/live/7WUAS350/images/tech-specs/airpods-pro-2.png'
        ],
        valoracionPromedio: 4.6,
        totalResenas: 234,
        categoria: Categoria(id: '4', nombre: 'Audio', slug: 'audio'),
      ),
      Producto(
        id: '5',
        nombre: 'Apple Watch Ultra 2',
        slug: 'apple-watch-ultra-2',
        descripcion: 'Nuevo, precintado',
        precioVenta: 69900,
        precioOriginal: 89900,
        stockTotal: 2,
        activo: true,
        destacado: true,
        imagenes: [
          'https://cdsassets.apple.com/live/7WUAS350/images/tech-specs/apple-watch-ultra-2.png'
        ],
        valoracionPromedio: 4.9,
        totalResenas: 45,
        categoria: Categoria(id: '5', nombre: 'Wearables', slug: 'wearables'),
      ),
      Producto(
        id: '6',
        nombre: 'Samsung Galaxy S24 Ultra',
        slug: 'samsung-s24-ultra',
        descripcion: 'Como nuevo, garantía 12 meses',
        precioVenta: 89900,
        precioOriginal: 139900,
        stockTotal: 6,
        activo: true,
        destacado: true,
        imagenes: [
          'https://images.samsung.com/es/smartphones/galaxy-s24-ultra/images/galaxy-s24-ultra-highlights-color-titanium-gray-back-mo.jpg'
        ],
        valoracionPromedio: 4.7,
        totalResenas: 98,
        categoria:
            Categoria(id: '1', nombre: 'Smartphones', slug: 'smartphones'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.searchQuery != null
              ? 'Buscar: ${widget.searchQuery}'
              : widget.categorySlug != null
                  ? 'Categoría'
                  : 'Todos los productos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showSortOptions,
            tooltip: 'Ordenar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadProducts,
              child: GridView.builder(
                padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      ResponsiveHelper.getGridCrossAxisCount(context).toInt(),
                  childAspectRatio: 0.62,
                  crossAxisSpacing: ResponsiveHelper.getPadding(context) / 2,
                  mainAxisSpacing: ResponsiveHelper.getPadding(context) / 2,
                ),
                itemCount: _productos.length,
                itemBuilder: (context, index) =>
                    _buildProductCard(_productos[index]),
              ),
            ),
    );
  }

  Widget _buildProductCard(Producto producto) {
    final hasDiscount = producto.precioOriginal != null &&
        producto.precioOriginal! > producto.precioVenta;
    final discountPercent = hasDiscount
        ? ((producto.precioOriginal! - producto.precioVenta) /
                producto.precioOriginal! *
                100)
            .round()
        : 0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product/${producto.slug}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      color: Colors.grey[50],
                      child: producto.imagenes.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: producto.imagenes.first,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                                size: 40,
                              ),
                            )
                          : Icon(
                              Icons.image,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                    ),
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-$discountPercent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (producto.totalResenas > 0)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          producto.valoracionPromedio.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${producto.totalResenas})',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${producto.precioEnEuros.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${producto.precioOriginalEnEuros!.toStringAsFixed(2)}€',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${producto.nombre} añadido')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_shopping_cart, size: 16),
                          SizedBox(width: 6),
                          Text('Añadir', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ordenar por',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Más recientes'),
              onTap: () {
                setState(() {
                  _sortBy = 'creado_en';
                  _sortAsc = false;
                });
                Navigator.pop(context);
                _loadProducts();
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('Precio: menor a mayor'),
              onTap: () {
                setState(() {
                  _sortBy = 'precio_venta';
                  _sortAsc = true;
                });
                Navigator.pop(context);
                _loadProducts();
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('Precio: mayor a menor'),
              onTap: () {
                setState(() {
                  _sortBy = 'precio_venta';
                  _sortAsc = false;
                });
                Navigator.pop(context);
                _loadProducts();
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Mejor valorados'),
              onTap: () {
                setState(() {
                  _sortBy = 'valoracion_promedio';
                  _sortAsc = false;
                });
                Navigator.pop(context);
                _loadProducts();
              },
            ),
          ],
        ),
      ),
    );
  }
}
