import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';

/// A single promotional category card — BackMarket / Amazon style.
///
/// Full background image with a bottom gradient overlay for readability,
/// category title overlaid at the bottom-left.
class PromoCategoryCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final VoidCallback? onTap;
  final double height;

  const PromoCategoryCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.onTap,
    this.height = 180,
  });

  @override
  State<PromoCategoryCard> createState() => _PromoCategoryCardState();
}

class _PromoCategoryCardState extends State<PromoCategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: _hovered
              ? (Matrix4.identity()..scale(1.015, 1.015))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.18 : 0.10),
                blurRadius: _hovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.grey100,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.grey200,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.grey400,
                        size: 32,
                      ),
                    ),
                  ),

                  // Bottom gradient for text readability
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Title label
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 14,
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Hover highlight
                  if (_hovered)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.06),
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
}
