import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/theme/extension_estados.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PALETA — extraída de styles-light.css del prototipo DetailCarWash
// ═══════════════════════════════════════════════════════════════════════════

// Superficies
const Color _bgBase = Color(0xFFFFFFFF);
const Color _bgSurface = Color(0xFFF5F6FA);
const Color _bgElevated = Color(0xFFEDEEF4);
// ignore: unused_element
const Color _bgOverlay = Color(0xD9FFFFFF); // rgba(255,255,255,0.85)

// Bordes
const Color _border = Color(0xFFDDE0EA);
// ignore: unused_element
const Color _borderStrong = Color(0xFFC8CCDA);
const Color _borderSubtle = Color(0xFFEDEEF4);

// Texto
const Color _textPrimary = Color(0xFF0D1117);
const Color _textBody = Color(0xFF3D4460);
const Color _textMuted = Color(0xFF7A8194);
const Color _textFaint = Color(0xFFB0B6C8);

// Acento — identidad de marca (igual en claro y oscuro)
const Color _accent = Color(0xFF2E6BFF);
const Color _accentStrong = Color(0xFF1B57F0);
const Color _accentSoft = Color(0x1F2E6BFF); // rgba(46,107,255,0.12)
// ignore: unused_element
const Color _accentTint = Color(0x0F2E6BFF); // rgba(46,107,255,0.06)

// Semánticos
const Color _danger = Color(0xFFA82828);

// ═══════════════════════════════════════════════════════════════════════════
// ESCALA TIPOGRÁFICA
// ═══════════════════════════════════════════════════════════════════════════

/// Construye la tipografía inyectando colores directamente para evitar
/// problemas de herencia con GoogleFonts y Material 3.
TextTheme _buildTextTheme(Color displayColor, Color bodyColor) => TextTheme(
  displayLarge: GoogleFonts.syne(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: 28 * -0.01,
    color: displayColor,
  ),
  displayMedium: GoogleFonts.syne(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.20,
    color: displayColor,
  ),
  displaySmall: GoogleFonts.syne(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: displayColor,
  ),
  bodyLarge: GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: bodyColor,
  ),
  bodyMedium: GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFeatures: const [FontFeature.tabularFigures()],
    color: bodyColor,
  ),
  bodySmall: GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: bodyColor,
  ),
  labelLarge: GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: bodyColor,
  ),
  labelSmall: GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 11 * 0.12,
    color: bodyColor,
  ),
);

// ═══════════════════════════════════════════════════════════════════════════
// TEMA ÚNICO DE CITARIA (CLARO)
// ═══════════════════════════════════════════════════════════════════════════

final ThemeData temaCitaria = () {
  const espaciado = EspaciadoCitaria.base;
  const estados = EstadosReservaCitaria.base;

  // Generamos el TextTheme con los colores de la paleta ya aplicados
  final textTheme = _buildTextTheme(_textPrimary, _textBody);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // ── ColorScheme ───────────────────────────────────────────────────────
    colorScheme: const ColorScheme.light(
      primary: _accent,
      onPrimary: Colors.white,
      primaryContainer: _accentSoft,
      onPrimaryContainer: _accentStrong,
      secondary: _textBody,
      onSecondary: Colors.white,
      surface: _bgBase,
      onSurface: _textPrimary,
      surfaceContainerHighest: _bgElevated,
      outline: _textMuted, // texto secundario (captions, horas, labels)
      outlineVariant: _border, // bordes sutiles
      error: _danger,
      onError: Colors.white,
    ),

    // ── Tipografía ────────────────────────────────────────────────────────
    textTheme: textTheme,

    // ── Scaffold ──────────────────────────────────────────────────────────
    scaffoldBackgroundColor: _bgBase,

    // ── Extensiones propias ───────────────────────────────────────────────
    extensions: const <ThemeExtension<dynamic>>[espaciado, estados],

    // ── AppBar ────────────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: _bgSurface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: _textPrimary),
      actionsIconTheme: const IconThemeData(color: _textPrimary),
      // Al usar el estilo ya inyectado con color, se verá correctamente en negro
      titleTextStyle: textTheme.displaySmall,
      centerTitle: true,
    ),

    // ── Card ──────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: _bgSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: espaciado.radioCard,
        side: const BorderSide(color: _border),
      ),
    ),

    // ── ElevatedButton ────────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _accentSoft,
        disabledForegroundColor: Colors.white60,
        elevation: 0,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: espaciado.radioBoton),
        textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
      ),
    ),

    // ── OutlinedButton ────────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _textPrimary,
        side: const BorderSide(color: _border),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: espaciado.radioBoton),
        textStyle: textTheme.labelLarge,
      ),
    ),

    // ── InputDecoration ───────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _bgElevated,
      constraints: const BoxConstraints(minHeight: 48),
      border: OutlineInputBorder(
        borderRadius: espaciado.radioInput,
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: espaciado.radioInput,
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: espaciado.radioInput,
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: espaciado.radioInput,
        borderSide: const BorderSide(color: _danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: espaciado.radioInput,
        borderSide: const BorderSide(color: _danger, width: 1.5),
      ),
      hintStyle: textTheme.bodyLarge?.copyWith(color: _textFaint),
      labelStyle: textTheme.bodyLarge?.copyWith(color: _textMuted),
    ),

    // ── BottomNavigationBar ───────────────────────────────────────────────
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _bgSurface,
      selectedItemColor: _accent,
      unselectedItemColor: _textMuted,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: true,
      selectedIconTheme: const IconThemeData(color: _accent, size: 24),
      unselectedIconTheme: const IconThemeData(color: _textMuted, size: 24),
      selectedLabelStyle: textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      elevation: 0,
    ),

    // ── Divider ───────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: _borderSubtle,
      thickness: 1,
      space: 1,
    ),

    // ── Chip ──────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: _bgElevated,
      side: const BorderSide(color: _border),
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioPill),
      labelStyle: textTheme.bodySmall,
    ),
  );
}();
