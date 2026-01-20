import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/producto.dart';
import '../services/product_service.dart';
import '../widgets/widgets.dart';
import '../config/app_theme.dart';

/// Pantalla principal - Home
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();

  List<Producto> _productosDestacados = [];
  List<Categoria> _categorias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final futures = await Future.wait([
        _productService.getProductosDestacados(limit: 8),
        _productService.getCategorias(),
      ]);

      final productos = futures[0] as List<Producto>;
      final categorias = futures[1] as List<Categoria>;

      setState(() {
        // Si no hay productos de la base de datos, usar datos de ejemplo
        _productosDestacados =
            productos.isNotEmpty ? productos : _getSampleProducts();
        _categorias =
            categorias.isNotEmpty ? categorias : _getSampleCategories();
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos: $e');
      // En caso de error, usar datos de ejemplo
      setState(() {
        _productosDestacados = _getSampleProducts();
        _categorias = _getSampleCategories();
        _isLoading = false;
      });
    }
  }

  // Datos de ejemplo para demostración
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

  List<Categoria> _getSampleCategories() {
    return [
      Categoria(id: '1', nombre: 'Smartphones', slug: 'smartphones'),
      Categoria(id: '2', nombre: 'Laptops', slug: 'laptops'),
      Categoria(id: '3', nombre: 'Tablets', slug: 'tablets'),
      Categoria(id: '4', nombre: 'Audio', slug: 'audio'),
      Categoria(id: '5', nombre: 'Wearables', slug: 'wearables'),
      Categoria(id: '6', nombre: 'Cámaras', slug: 'camaras'),
      Categoria(id: '7', nombre: 'Monitores', slug: 'monitores'),
      Categoria(id: '8', nombre: 'Consolas', slug: 'consolas'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Cargando FashionStore...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // App Bar premium
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              expandedHeight: 60,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'FashionStore',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.search,
                        color: AppColors.text, size: 22),
                  ),
                  onPressed: () {
                    _showSearchDialog();
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shopping_cart_outlined,
                            color: AppColors.text, size: 22),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Hero Section mejorado
            SliverToBoxAdapter(
              child: _buildHeroSection(),
            ),

            // Banner de ofertas
            SliverToBoxAdapter(
              child: _buildPromoBar(),
            ),

            // Categorías mejoradas
            SliverToBoxAdapter(
              child: _buildCategoriasSection(),
            ),

            // Productos destacados header
            SliverToBoxAdapter(
              child: _buildProductosDestacadosHeader(),
            ),

            // Grid de productos
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getPadding(context),
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      ResponsiveHelper.getGridCrossAxisCount(context).toInt(),
                  childAspectRatio: 0.62,
                  crossAxisSpacing: ResponsiveHelper.getPadding(context) / 2,
                  mainAxisSpacing: ResponsiveHelper.getPadding(context) / 2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final producto = _productosDestacados[index];
                    return _buildProductCard(producto);
                  },
                  childCount: _productosDestacados.length,
                ),
              ),
            ),

            // Espaciado inferior
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeroSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Container(
          margin: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
          height: isMobile ? 200 : 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Patrón decorativo
              Positioned(
                right: -30,
                bottom: -30,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                top: 20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),

              // Contenido
              Padding(
                padding: EdgeInsets.all(
                  ResponsiveHelper.getPadding(context),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '🔥 OFERTAS HOY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'TECH\nREACONDICIONADA',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/products');
                            },
                            icon: const Icon(Icons.arrow_forward, size: 16),
                            label: const Text('Comprar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '🔥 OFERTAS ESPECIALES',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'TECNOLOGÍA\nREACONDICIONADA',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Hasta 70% menos que nuevo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/products');
                                  },
                                  icon: const Icon(Icons.arrow_forward,
                                      size: 18),
                                  label: const Text('Ver ofertas'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 22, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://cdsassets.apple.com/live/7WUAS350/images/tech-specs/iphone-16.png',
                                height: 160,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Icon(
                                  Icons.smartphone,
                                  size: 60,
                                  color: Colors.white70,
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.smartphone,
                                  size: 60,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromoBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getPadding(context),
            vertical: ResponsiveHelper.getPadding(context) / 2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getPadding(context) * 0.75,
            vertical: ResponsiveHelper.getPadding(context) * 0.75,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isMobile
              ? Column(
                  children: [
                    _buildPromoItem(Icons.local_shipping_outlined,
                        'Envío gratis +50€'),
                    const SizedBox(height: 10),
                    _buildPromoItem(
                        Icons.verified_outlined, 'Garantía 12 meses'),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPromoItem(Icons.local_shipping_outlined,
                        'Envío gratis en pedidos +50€'),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildPromoItem(
                        Icons.verified_outlined, 'Garantía 12 meses'),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildPromoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCategoriasSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                ResponsiveHelper.getPadding(context),
                ResponsiveHelper.getPadding(context),
                ResponsiveHelper.getPadding(context),
                ResponsiveHelper.getPadding(context) / 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categorías',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explora nuestras categorías',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isMobile || isTablet)
              SizedBox(
                height: isMobile ? 115 : 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getPadding(context),
                  ),
                  itemCount: _categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = _categorias[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildCategoryCard(categoria),
                    );
                  },
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _categorias.length,
                itemBuilder: (context, index) {
                  final categoria = _categorias[index];
                  return _buildCategoryCard(categoria);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(Categoria categoria) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/category/${categoria.slug}',
        );
      },
      child: Container(
        width: 95,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/category/${categoria.slug}',
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getCategoryIcon(categoria.slug),
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    categoria.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductosDestacadosHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Productos destacados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              Text(
                'Los más vendidos esta semana',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/products');
            },
            icon: const Text(
              'Ver todos',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            label: const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ],
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

                // Badge descuento
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

                // Botón favoritos
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: Colors.grey,
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
                  // Categoría
                  if (producto.categoria != null)
                    Text(
                      producto.categoria!.nombre.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),

                  const SizedBox(height: 4),

                  // Nombre
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

                  // Valoración
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

                  // Precios
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
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

                  // Botón añadir
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(producto),
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

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categorías',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cuenta',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/categories');
              break;
            case 2:
              Navigator.pushNamed(context, '/cart');
              break;
            case 3:
              Navigator.pushNamed(context, '/login');
              break;
          }
        },
      ),
    );
  }

  IconData _getCategoryIcon(String slug) {
    final icons = {
      'smartphones': Icons.smartphone,
      'laptops': Icons.laptop,
      'tablets': Icons.tablet,
      'audio': Icons.headphones,
      'wearables': Icons.watch,
      'camaras': Icons.camera_alt,
      'monitores': Icons.monitor,
      'consolas': Icons.sports_esports,
    };
    return icons[slug] ?? Icons.devices;
  }

  void _addToCart(Producto producto) {
    showSnackBar(context, '${producto.nombre} añadido al carrito');
  }

  void _showSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Búsquedas populares',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['iPhone', 'MacBook', 'AirPods', 'iPad', 'Apple Watch']
                  .map((term) => ActionChip(
                        label: Text(term),
                        onPressed: () {
                          Navigator.pop(context);
                          // Buscar término
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
