import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme/app_typography.dart';
import '../routes/app_router.dart';

class HeroBannerWidget extends StatefulWidget {
  const HeroBannerWidget({super.key});

  @override
  State<HeroBannerWidget> createState() => _HeroBannerWidgetState();
}

class _HeroBannerWidgetState extends State<HeroBannerWidget> {
  final List<String> _images = [
    'https://cdsassets.apple.com/live/SZLF0YNV/images/sp/111979_ipad-pro-12-2018.png',
    'https://cdsassets.apple.com/live/7WUAS350/images/tech-specs/iphone-16.png',
    'https://cdsassets.apple.com/live/SZLF0YNV/images/sp/111979_ipad-pro-12-2018.png',
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final padding = isMobile ? 24.0 : 48.0;

        return Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1400),
            margin: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 12 : 24,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFC8E46B), // Lime green requested
              borderRadius: BorderRadius.circular(32),
            ),
            padding: EdgeInsets.all(padding),
            child: isMobile
                ? Column(
                    children: [
                      _buildTextContent(isMobile),
                      const SizedBox(height: 32),
                      _buildImageCarousel(height: 250),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildTextContent(isMobile),
                      ),
                      Expanded(
                        flex: 6,
                        child: _buildImageCarousel(height: 400),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTextContent(bool isMobile) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          text: TextSpan(
            style: GoogleFonts.kanit(
              fontSize: isMobile ? 36 : 56,
              height: 1.0,
            ),
            children: [
              TextSpan(
                text: 'Tecnología\nPremium\n',
                style: GoogleFonts.kanit(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  fontStyle: FontStyle.normal,
                ),
              ),
              TextSpan(
                text: 'al mejor precio',
                style: GoogleFonts.kanit(
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF005C29),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Descubre los mejores productos electrónicos con garantía.\nSmartphones, laptops y accesorios a los mejores precios.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: isMobile ? 16 : 18,
            color: const Color(0xFF374151), // Dark grey
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => context.go(AppRoutes.products),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Ver Productos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel({required double height}) {
    return SizedBox(
      height: height,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: CachedNetworkImage(
          key: ValueKey<int>(_currentIndex),
          imageUrl: _images[_currentIndex],
          height: height,
          fit: BoxFit.contain,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
