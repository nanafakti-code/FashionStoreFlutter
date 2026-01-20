import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/product_service.dart';
import '../config/app_theme.dart';

/// Pantalla de categorías
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ProductService _productService = ProductService();

  List<Categoria> _categorias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    try {
      final categorias = await _productService.getCategorias();
      setState(() {
        _categorias =
            categorias.isNotEmpty ? categorias : _getSampleCategories();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _categorias = _getSampleCategories();
        _isLoading = false;
      });
    }
  }

  List<Categoria> _getSampleCategories() {
    return [
      Categoria(
          id: '1',
          nombre: 'Smartphones',
          slug: 'smartphones',
          descripcion: 'Los mejores móviles reacondicionados'),
      Categoria(
          id: '2',
          nombre: 'Laptops',
          slug: 'laptops',
          descripcion: 'MacBooks, ultrabooks y más'),
      Categoria(
          id: '3',
          nombre: 'Tablets',
          slug: 'tablets',
          descripcion: 'iPads y tablets Android'),
      Categoria(
          id: '4',
          nombre: 'Audio',
          slug: 'audio',
          descripcion: 'AirPods, auriculares y altavoces'),
      Categoria(
          id: '5',
          nombre: 'Wearables',
          slug: 'wearables',
          descripcion: 'Apple Watch, smartbands y más'),
      Categoria(
          id: '6',
          nombre: 'Cámaras',
          slug: 'camaras',
          descripcion: 'Cámaras digitales y accesorios'),
      Categoria(
          id: '7',
          nombre: 'Monitores',
          slug: 'monitores',
          descripcion: 'Pantallas para trabajo y gaming'),
      Categoria(
          id: '8',
          nombre: 'Consolas',
          slug: 'consolas',
          descripcion: 'PlayStation, Xbox y Nintendo'),
    ];
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

  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFF00AA45), // Verde
      const Color(0xFF3B82F6), // Azul
      const Color(0xFFF59E0B), // Naranja
      const Color(0xFFEF4444), // Rojo
      const Color(0xFF8B5CF6), // Púrpura
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEC4899), // Rosa
      const Color(0xFF10B981), // Esmeralda
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Categorías',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadCategories,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final isTablet = constraints.maxWidth >= 600 &&
                      constraints.maxWidth < 1200;

                  if (isMobile) {
                    // Vista de lista para móvil
                    return ListView.builder(
                      padding: EdgeInsets.all(
                          ResponsiveHelper.getPadding(context)),
                      itemCount: _categorias.length,
                      itemBuilder: (context, index) {
                        final categoria = _categorias[index];
                        final color = _getCategoryColor(index);

                        return _buildCategoryTile(categoria, color);
                      },
                    );
                  } else if (isTablet) {
                    // Vista de dos columnas para tablet
                    return GridView.builder(
                      padding: EdgeInsets.all(
                          ResponsiveHelper.getPadding(context)),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _categorias.length,
                      itemBuilder: (context, index) {
                        final categoria = _categorias[index];
                        final color = _getCategoryColor(index);

                        return _buildCategoryCard(categoria, color);
                      },
                    );
                  } else {
                    // Vista de tres columnas para desktop
                    return GridView.builder(
                      padding: EdgeInsets.all(
                          ResponsiveHelper.getPadding(context)),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.6,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _categorias.length,
                      itemBuilder: (context, index) {
                        final categoria = _categorias[index];
                        final color = _getCategoryColor(index);

                        return _buildCategoryCard(categoria, color);
                      },
                    );
                  }
                },
              ),
            ),
    );
  }

  Widget _buildCategoryTile(Categoria categoria, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/category/${categoria.slug}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/category/${categoria.slug}');
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      _getCategoryIcon(categoria.slug),
                      size: 32,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoria.nombre,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (categoria.descripcion != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            categoria.descripcion!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Categoria categoria, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/category/${categoria.slug}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/category/${categoria.slug}');
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getCategoryIcon(categoria.slug),
                      size: 28,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          categoria.nombre,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (categoria.descripcion != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            categoria.descripcion!,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: color,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
