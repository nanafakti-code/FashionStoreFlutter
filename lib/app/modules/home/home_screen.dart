import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../routes/app_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/app_typography.dart';
import '../../../utils/responsive_helper.dart';
import '../../widgets/product_card.dart';
import '../../widgets/promo_section.dart';
import '../../widgets/hero_banner.dart';
import '../../widgets/custom_app_bar.dart';
import 'widgets/newsletter_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load featured products when screen initiates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(productNotifierProvider.notifier).loadFeaturedProducts();
    });
  }

  Future<void> _refresh() async {
    await ref.read(productNotifierProvider.notifier).loadFeaturedProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomFashionAppBar(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSearchBar(context),
              const HeroBannerWidget(),
              _buildPromoSection(context),
              _buildFeaturedSection(context),
              const NewsletterSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ─── Search bar ───

  Widget _buildSearchBar(BuildContext context) {
    return ResponsiveHelper.constrain(
      child: Padding(
        padding: AppSpacing.paddingAllLg,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onTap: () => context.push(AppRoutes.search),
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Busca productos...',
                  hintStyle: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.grey50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: IconButton(
                onPressed: () => context.push(AppRoutes.search),
                icon: const Icon(Icons.search, color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Promotional categories ───

  Widget _buildPromoSection(BuildContext context) {
    final promoCategories = [
      PromoCategory(
        title: 'Las mejores ofertas',
        imageUrl:
            'https://www.backmarket.es/cdn-cgi/image/format%3Dauto%2Cquality%3D75%2Cwidth%3D3840/https://images.ctfassets.net/mmeshd7gafk1/Pp4pOTfXlUSotMSqXEbxu/3370173794ce712f1e1cbcc40295b383/Modular-card_Desktop_Great_deals.jpg',
        onTap: () => context.push(AppRoutes.products),
      ),
      PromoCategory(
        title: 'iPhone',
        imageUrl:
            'https://www.backmarket.es/cdn-cgi/image/format%3Dauto%2Cquality%3D75%2Cwidth%3D3840/https://images.ctfassets.net/mmeshd7gafk1/1bRy70V8KNknn628bf14h8/00d17107aeb0b9649fbdf6b07f3ffaf5/Modular-card_Desktop_iPhone.jpg',
        onTap: () => context.push(AppRoutes.products),
      ),
      PromoCategory(
        title: 'MacBooks',
        imageUrl:
            'https://www.backmarket.es/cdn-cgi/image/format%3Dauto%2Cquality%3D75%2Cwidth%3D3840/https://images.ctfassets.net/mmeshd7gafk1/5GjoGJCqWVngJRShjjG7a/e5244dcc76c3549e25b290f886334388/Modular-card_Desktop_Macbooks.jpg',
        onTap: () => context.push(AppRoutes.products),
      ),
      PromoCategory(
        title: 'iPad',
        imageUrl:
            'https://www.backmarket.es/cdn-cgi/image/format%3Dauto%2Cquality%3D75%2Cwidth%3D3840/https://images.ctfassets.net/mmeshd7gafk1/jW258Um5YCpwOTHNgEokq/1bf0f42f2e1714c689abf89d98b4710c/Modular-card_Desktop_iPad.jpg',
        onTap: () => context.push(AppRoutes.products),
      ),
      PromoCategory(
        title: 'Smartwatch',
        imageUrl:
            'https://www.backmarket.es/cdn-cgi/image/format%3Dauto%2Cquality%3D75%2Cwidth%3D3840/https://images.ctfassets.net/mmeshd7gafk1/1W08wc0KJB4db2rXsJyP1P/cec0c617c837e6ca306ef223eae6d8ee/Modular-card_Desktop_Smartwatch.jpg',
        onTap: () => context.push(AppRoutes.products),
      ),
      PromoCategory(
        title: 'Android',
        imageUrl:
            'https://www.backmarket.es/cdn-cgi/image/format%3Dauto%2Cquality%3D75%2Cwidth%3D3840/https://images.ctfassets.net/mmeshd7gafk1/1kHjYTtX4lFsNMLAybrL15/039602935bc433400942240a92a50a4d/Modular-card_Desktop_Android.jpg',
        onTap: () => context.push(AppRoutes.products),
      ),
      PromoCategory(
        title: 'Portátiles Windows',
        imageUrl:
            'https://www.backmarket.es/cdn-cgi/image/format%3Dauto%2Cquality%3D75%2Cwidth%3D3840/https://images.ctfassets.net/mmeshd7gafk1/5hkcYLitLSwmhC6mC9UkYI/1b14e28d69023e48311650e134dd7623/Modular-card_Desktop_Windows_Laptop.jpg',
        onTap: () => context.push(AppRoutes.products),
      ),
      PromoCategory(
        title: 'Electrodomésticos',
        imageUrl:
            'https://www.backmarket.es/cdn-cgi/image/format%3Dauto%2Cquality%3D75%2Cwidth%3D3840/https://images.ctfassets.net/mmeshd7gafk1/7snz6xrm8ugZjYmQFScxkl/3311b3b3194d277b2dcd1a2d39bfc69f/Modular-card_Desktop_Home_appliances.jpg',
        onTap: () => context.push(AppRoutes.products),
      ),
    ];

    return PromoSection(categories: promoCategories);
  }

  // ─── Featured products grid ───

  Widget _buildFeaturedSection(BuildContext context) {
    final columns = ResponsiveHelper.getGridCrossAxisCount(context);
    final ratio = ResponsiveHelper.getChildAspectRatio(context);
    final spacing = ResponsiveHelper.getGridSpacing(context);

    // Watch state
    final productState = ref.watch(productNotifierProvider);
    final isLoading = productState.isLoading;
    final featuredProducts = productState.featuredProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        ResponsiveHelper.constrain(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Productos Destacados',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (ResponsiveHelper.isMobile(context)
                            ? AppTypography.headlineMedium
                            : AppTypography.displaySmall)
                        .copyWith(color: AppColors.charcoal),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => context.push(AppRoutes.products),
                  child: Text(
                    'Ver todos →',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Grid
        if (isLoading && featuredProducts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ResponsiveHelper.maxContentWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: ratio,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                  ),
                  itemCount: featuredProducts.length,
                  itemBuilder: (_, i) =>
                      ProductCard(producto: featuredProducts[i]),
                ),
              ),
            ),
          ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ─── Bottom navigation ───

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.success,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined), label: 'Productos'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Perfil'),
      ],
      onTap: (i) {
        switch (i) {
          case 0:
            // Already home
            break;
          case 1:
            context.push(AppRoutes.products);
            break;
          case 2:
            context.push(AppRoutes.profile);
            break;
        }
      },
    );
  }
}
