import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../data/services/newsletter_service.dart';

class NewsletterSection extends StatefulWidget {
  const NewsletterSection({super.key});

  @override
  State<NewsletterSection> createState() => _NewsletterSectionState();
}

class _NewsletterSectionState extends State<NewsletterSection> {
  final TextEditingController _emailController = TextEditingController();
  final NewsletterService _newsletterService = NewsletterService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, ingresa un correo electrónico válido')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _newsletterService.subscribe(email);

      if (!mounted) return;

      if (success) {
        _emailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '¡Suscripción exitosa! Te hemos enviado un correo con tu cupón.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este correo ya está suscrito o hubo un problema.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          Text(
            'Suscríbete a nuestra\nnewsletter',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: AppColors.white,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Recibe las últimas novedades, ofertas exclusivas\ny un 10% de descuento en tu primera compra.',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.white, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                      color: AppColors.text, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'tu@email.com',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide:
                          const BorderSide(color: AppColors.white, width: 2),
                    ),
                  ),
                  onSubmitted: (_) => _subscribe(),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _subscribe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: AppColors.primary, strokeWidth: 2),
                          )
                        : const Text('Suscribirme',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Sin spam. Puedes darte de baja en cualquier momento.',
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.white.withOpacity(0.8), fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
