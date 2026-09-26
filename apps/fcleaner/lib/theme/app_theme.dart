import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Color tokens ──────────────────────────────────────────────────────
  static const _seed = Color(0xFF00BFA5);
  static const accentTeal = Color(0xFF00E5CC);
  static const accentCyan = Color(0xFF00B8D4);
  static const surfaceDark = Color(0xFF0F1117);
  static const cardDark = Color(0xFF181A20);
  static const cardDarkElevated = Color(0xFF1F222A);
  static const borderDark = Color(0xFF2A2D35);
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFF9EA3B0);
  static const textTertiary = Color(0xFF6B7080);

  // Category colors
  static const flutterBlue = Color(0xFF42A5F5);
  static const androidGreen = Color(0xFF66BB6A);
  static const appleGray = Color(0xFFB0BEC5);
  static const systemOrange = Color(0xFFFF9800);
  static const pubCachePurple = Color(0xFFAB47BC);

  static const dangerRed = Color(0xFFEF5350);
  static const successGreen = Color(0xFF4CAF50);

  static Color categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'flutter':
        return flutterBlue;
      case 'android':
        return androidGreen;
      case 'apple':
        return appleGray;
      case 'system':
        return systemOrange;
      case 'pubcache':
        return pubCachePurple;
      default:
        return accentTeal;
    }
  }

  // ── Dark theme ────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
      surface: surfaceDark,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceDark,
      textTheme: _buildTextTheme(),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cardDark,
        selectedIconTheme: const IconThemeData(color: accentTeal, size: 24),
        unselectedIconTheme: const IconThemeData(
          color: textSecondary,
          size: 24,
        ),
        selectedLabelTextStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: accentTeal,
        ),
        unselectedLabelTextStyle: GoogleFonts.inter(
          fontSize: 12,
          color: textSecondary,
        ),
        indicatorColor: accentTeal.withValues(alpha: 0.15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentTeal,
          foregroundColor: surfaceDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentTeal,
          side: const BorderSide(color: accentTeal, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentTeal;
          return textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentTeal.withValues(alpha: 0.3);
          }
          return borderDark;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentTeal;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(surfaceDark),
        side: const BorderSide(color: textSecondary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderDark),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDarkElevated,
        contentTextStyle: GoogleFonts.inter(color: textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cardDarkElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderDark),
        ),
        textStyle: GoogleFonts.inter(color: textPrimary, fontSize: 12),
      ),
    );
  }

  // ── Light theme ───────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(dark: false),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _seed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme({bool dark = true}) {
    final color = dark ? textPrimary : const Color(0xFF1A1A2E);
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: dark ? textSecondary : Colors.grey.shade700,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: dark ? textTertiary : Colors.grey.shade500,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: dark ? textSecondary : Colors.grey.shade600,
      ),
    );
  }
}

// ── Glassmorphic container decoration ─────────────────────────────────
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 16,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppTheme.borderDark.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
