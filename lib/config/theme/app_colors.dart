import 'package:flutter/material.dart';

/// Paleta de colores de FashionStore — replica exacta del proyecto Astro original
class AppColors {
  AppColors._();

  // ─── Colores principales (Astro/Tailwind) ───
  static const Color navy = Color(0xFF102A43);
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color cream = Color(0xFFF1ECE3);
  static const Color gold = Color(0xFFD4A574);
  static const Color green = Color(0xFF00AA45);

  // Alias para compatibilidad
  static const Color primary = green;
  static const Color primaryLight = Color(0xFF33BB6A);
  static const Color primaryDark = Color(0xFF008836);
  static const Color secondary = gold;
  static const Color secondaryLight = Color(0xFFE0BA91);
  static const Color secondaryDark = Color(0xFFC89558);

  // ─── Neutrales ───
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9CA3AF);
  static const Color greyLight = Color(0xFFF3F4F6);
  static const Color greyDark = Color(0xFF374151);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // ─── Texto ───
  static const Color text = charcoal;
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnDark = white;

  // ─── Estado ───
  static const Color success = Color(0xFF00AA45); // Verde FashionStore
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFCAF0A);
  static const Color info = Color(0xFF3B82F6);

  // ─── Fondos ───
  static const Color background = Color(0xFFFAF9F7);
  static const Color surface = white;
  static const Color surfaceVariant = Color(0xFFF8F7F4);
  static const Color scaffoldBg = Color(0xFFF5F3EF);
  static const Color cardBg = white;

  // ─── Hero section ───
  static const Color heroYellow = Color(0xFFE2FF7A);

  // ─── Acentos ───
  static const Color purple = Color(0xFF8B5CF6);
  static const Color orange = Color(0xFFF97316);
  static const Color teal = Color(0xFF14B8A6);
  static const Color pink = Color(0xFFEC4899);

  // ─── Bordes ───
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  // ─── Badges ───
  static const Color badgeSale = Color(0xFFEF4444);
  static const Color badgePremium = gold;

  // ─── Descuentos ───
  static const Color discountBg = Color(0xFFDCFCE7);
  static const Color discountText = Color(0xFF166534);

  // ─── Rating ───
  static const Color starActive = Color(0xFFFBBF24);
  static const Color starInactive = Color(0xFFD1D5DB);
}
