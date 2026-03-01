import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../providers/coupon_provider.dart';
import '../../../data/models/coupon_model.dart';

class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userCouponsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leadingWidth: 250,
        leading: TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: AppColors.success),
          label: const Text('Volver a tu perfil',
              style: TextStyle(
                  color: AppColors.success,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(userCouponsProvider.notifier).loadCoupons();
        },
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 60),
                const SizedBox(height: 16),
                const Text('Error al cargar cupones'),
                TextButton(
                  onPressed: () {
                    ref.read(userCouponsProvider.notifier).loadCoupons();
                  },
                  child: const Text('Reintentar'),
                )
              ],
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.discount_outlined,
                            size: 80, color: AppColors.greyLight),
                        const SizedBox(height: 16),
                        const Text(
                            'No tienes cupones disponibles en este momento.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.confirmation_number_outlined,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mis Cupones',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  const SizedBox(height: 16),
                  ...items.map((item) => _buildCouponCard(item)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCouponCard(CouponModel coupon) {
    final dateFormat =
        "${coupon.expirationDate.day}/${coupon.expirationDate.month}/${coupon.expirationDate.year}";
    final discountText = coupon.discountType == 'PERCENTAGE'
        ? "${coupon.value.toInt()}% OFF"
        : "${coupon.value.toStringAsFixed(2)}€ OFF";

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      // Contenedor principal para el borde punteado
      child: CustomPaint(
        painter: DashedRectPainter(
          color: AppColors.success,
          strokeWidth: 1.5,
          gap: 6,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior (DISPONIBLE y 10% OFF)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'DISPONIBLE',
                      style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5),
                    ),
                  ),
                  Text(
                    discountText,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.charcoal,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // Título y descripción
              Text(
                'Cupón ${coupon.code}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 6),
              if (coupon.description != null)
                Text(
                  coupon.description!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              const SizedBox(height: 20),

              // Caja Gris para Copiar Código
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12)),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: coupon.code));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Código copiado al portapapeles'),
                          backgroundColor: AppColors.success));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            coupon.code,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.success,
                                letterSpacing: 0.5),
                          ),
                          Icon(Icons.copy,
                              color: Colors.grey.shade500, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Validez
              Center(
                child: Text(
                  'Válido hasta $dateFormat',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius)));

    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final double length = gap;
        if (draw) {
          canvas.drawPath(
              pathMetric.extractPath(distance, distance + length), paint);
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
