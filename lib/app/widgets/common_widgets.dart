import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

/// Widget de loading reutilizable
class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: TextStyle(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// Widget de estado vacío reutilizable
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColors.greyLight),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: Text(buttonText!,
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Badge de carrito
class CartBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const CartBadge({Key? key, required this.count, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(icon: const Icon(Icons.shopping_cart), onPressed: onTap),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text('$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}

/// Widget de precio con descuento
class PriceWidget extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final double fontSize;

  const PriceWidget({
    Key? key,
    required this.price,
    this.originalPrice,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('${price.toStringAsFixed(2)}€',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            )),
        if (originalPrice != null && originalPrice! > price) ...[
          const SizedBox(width: 8),
          Text('${originalPrice!.toStringAsFixed(2)}€',
              style: TextStyle(
                fontSize: fontSize * 0.75,
                decoration: TextDecoration.lineThrough,
                color: AppColors.textSecondary,
              )),
        ],
      ],
    );
  }
}

/// Widget de rating con estrellas
class RatingWidget extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double size;
  final int? reviewCount;

  const RatingWidget({
    Key? key,
    required this.rating,
    this.maxStars = 5,
    this.size = 16,
    this.reviewCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
            maxStars,
            (i) => Icon(
                  i < rating.round() ? Icons.star : Icons.star_border,
                  color: AppColors.gold,
                  size: size,
                )),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text('($reviewCount)',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: size * 0.8)),
        ],
      ],
    );
  }
}

/// Sección de Newsletter
class NewsletterSection extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onSubscribe;
  final bool isLoading;

  const NewsletterSection({
    Key? key,
    required this.emailController,
    required this.onSubscribe,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      color: AppColors.navy,
      child: Column(
        children: [
          const Text('Suscríbete a nuestro Newsletter',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Recibe las últimas novedades y ofertas exclusivas',
              style: TextStyle(color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tu email',
                      hintStyle:
                          TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      prefixIcon: Icon(Icons.email,
                          color: Colors.white.withValues(alpha: 0.7)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: isLoading ? null : onSubscribe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Suscribirse',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom Navigation Bar personalizado
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag), label: 'Productos'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
