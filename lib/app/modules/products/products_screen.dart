import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../routes/app_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../utils/responsive_helper.dart';
import '../../widgets/product_card.dart';
import '../../widgets/custom_app_bar.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(productNotifierProvider.notifier);
      notifier.loadProducts();
      notifier.loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomFashionAppBar(
        title: 'Productos',
        showBackButton: true,
        onBack: () => context.go(AppRoutes.home),
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildCategoryFilter(context),
          Expanded(child: _buildProductGrid(context)),
        ],
      ),
    );
  }

  // ─── Search ───

  Widget _buildSearchBar(BuildContext context) {
    return ResponsiveHelper.constrain(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar productos...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: const Icon(Icons.filter_list),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          onChanged: (value) {
            ref.read(productNotifierProvider.notifier).setSearchQuery(value);
          },
        ),
      ),
    );
  }

  // ─── Category chips ───

  Widget _buildCategoryFilter(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);
    final categories = productState.categories
        .where((c) => c.nombre.toLowerCase() != 'ofertas')
        .toList();
    final selectedCategory = productState.selectedCategory;

    return ResponsiveHelper.constrain(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getPadding(context),
        ),
        child: Row(
          children: [
            FilterChip(
              label: const Text('Todos'),
              selected: selectedCategory == null,
              onSelected: (s) {
                if (s) {
                  ref.read(productNotifierProvider.notifier).setCategory(null);
                }
              },
            ),
            const SizedBox(width: 8),
            // Ofertas justo después de Todos
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Ofertas'),
                selected: selectedCategory == 'OFERTAS',
                onSelected: (s) {
                  if (s) {
                    ref
                        .read(productNotifierProvider.notifier)
                        .setCategory('OFERTAS');
                  }
                },
              ),
            ),
            ...categories.map((cat) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat.nombre),
                  selected: selectedCategory == cat.id,
                  onSelected: (s) {
                    if (s) {
                      ref
                          .read(productNotifierProvider.notifier)
                          .setCategory(cat.id);
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─── Product grid ───

  Widget _buildProductGrid(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);
    final products = productState.filteredProducts;
    final isLoading = productState.isLoading;

    if (isLoading && products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text('No hay productos disponibles',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    final padding = ResponsiveHelper.getPadding(context);
    final columns = ResponsiveHelper.getGridCrossAxisCount(context);
    final ratio = ResponsiveHelper.getChildAspectRatio(context);
    final spacing = ResponsiveHelper.getGridSpacing(context);

    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: ResponsiveHelper.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: ratio,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: products.length,
            itemBuilder: (_, i) => ProductCard(producto: products[i]),
          ),
        ),
      ),
    );
  }
}
