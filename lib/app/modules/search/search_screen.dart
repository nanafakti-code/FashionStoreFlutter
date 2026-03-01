import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/product_provider.dart';
import '../../../config/theme/app_colors.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize query from provider if needed, or clear it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Optional: Clear search on entry
      // ref.read(productNotifierProvider.notifier).setSearchQuery('');
      _searchController.text = ref.read(productNotifierProvider).searchQuery;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productNotifierProvider);
    final notifier = ref.read(productNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar productos...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: (q) => notifier.setSearchQuery(q),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              notifier.setSearchQuery('');
              _searchController.clear();
              context.pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories filter
          if (state.categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildCategoryChip(
                      'Todos',
                      'todos',
                      state.selectedCategory == null ||
                          state.selectedCategory == 'todos',
                      notifier),
                  ...state.categories.map((c) => _buildCategoryChip(c.nombre,
                      c.id, state.selectedCategory == c.id, notifier)),
                ],
              ),
            ),
          // Results
          Expanded(
            child: Builder(builder: (context) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.searchQuery.isEmpty && state.filteredProducts.isEmpty) {
                // Logic change: filteredProducts might be full list if query is empty unless logic in provider clears it.
                // ProductNotifier logic: if query empty, returns all products (or filtered by category).
                // For SearchScreen, we might want to show nothing if query is empty?
                // But typically we show suggestions or all products.
                // Let's stick to showing whatever filter returns.

                // If we want "Search mode" where nothing is shown initially:
                if (state.searchQuery.isEmpty &&
                    state.selectedCategory == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search,
                            size: 80, color: AppColors.greyLight),
                        const SizedBox(height: 16),
                        const Text('Busca productos por nombre',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }
              }

              if (state.filteredProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                          size: 64, color: AppColors.greyLight),
                      const SizedBox(height: 16),
                      Text(
                          'No se encontraron resultados para "${state.searchQuery}"'),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.filteredProducts.length,
                itemBuilder: (_, i) {
                  final p = state.filteredProducts[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: p.imagenPrincipal != null
                              ? CachedNetworkImage(
                                  imageUrl: p.imagenPrincipal!,
                                  fit: BoxFit.cover)
                              : Container(
                                  color: AppColors.greyLight,
                                  child: const Icon(Icons.image)),
                        ),
                      ),
                      title: Text(p.nombre,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${p.precioEnEuros.toStringAsFixed(2)}€',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart,
                            color: AppColors.primary),
                        onPressed: () {
                          // Logic to add to cart (default variant?)
                          // CartNotifier needs variantId.
                          // ProductModel has 'variantes'.
                          // Need to select first variant or open dialog.
                          // Getting CartNotifier to add.
                          // For now, let's open product detail.
                          // Or simple add if we have logic.
                          // CartController.addItem(p) was used.
                          // We need to see how CartNotifier handles 'addItem(Product)'.
                          // CartNotifier has 'addItem(CartItemModel)'.
                          // We should navigate to detail to select variant.
                          context.push('/product/${p.id}');
                        },
                      ),
                      onTap: () => context.push('/product/${p.id}'),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
      String label, String id, bool isSelected, ProductNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary.withOpacity(0.2),
        onSelected: (_) => notifier.setCategory(id == 'todos' ? null : id),
      ),
    );
  }
}
