import 'package:flutter/material.dart';

/// AppColors extracted from the Inventify logo palette
/// Logo features a gradient from Deep Navy → Royal Blue → Cyan → Mint Green
class AppColors {
  // ── Primary Brand ────────────────────────────────────────────────────────
  /// Deep navy — logo wordmark left side ("Inven-")
  static const primary = Color(0xFF1A237E);

  /// Cyan teal — shopping cart icon & wave graphic
  static const secondary = Color(0xFF00ACC1);

  /// Royal blue — mid-gradient transition in logo icon
  static const accent = Color(0xFF1565C0);

  // ── Backgrounds ──────────────────────────────────────────────────────────
  /// Keep original background unchanged
  static const background = Color(0xFFFCFEFF);

  /// Input field background — soft navy tint
  static const inputBg = Color(0xFFE8EDF6);

  // ── Text ─────────────────────────────────────────────────────────────────
  /// Primary text — deep navy from logo wordmark
  static const textPrimary = Color(0xFF1A237E);

  /// Secondary text — muted blue-grey
  static const textSecondary = Color(0xFF546E8A);

  /// Hint / placeholder — light blue-grey
  static const textHint = Color(0xFF90A4AE);

  // ── UI States ────────────────────────────────────────────────────────────
  /// Disabled button — desaturated cyan
  static const buttonDisabled = Color(0xFF90CAF9);

  static const white = Colors.white;

  /// Card background — very light cyan wash
  static const cardBg = Color(0xFFE0F7FA);

  // ── Stock Status ─────────────────────────────────────────────────────────
  /// Tersedia (Available) — vibrant cyan from logo wave
  static const tersedia = Color(0xFF00BCD4);

  /// Stok Tipis (Low Stock) — warm amber (kept semantic, logo-adjacent)
  static const stokTipis = Color(0xFFFFA726);

  /// Habis (Out of Stock) — kept semantic red for clarity
  static const habis = Color(0xFFEF5350);

  // ── Extra Brand Tones ────────────────────────────────────────────────────
  /// Dark text variant — deepest navy from logo
  static const textDark = Color(0xFF0D1B5E);

  /// Grey text — cool blue-grey
  static const textGrey = Color(0xFF78909C);

  // ── Gradient Helpers ─────────────────────────────────────────────────────
  /// Mint green — logo arrow tip / "ify" tail accent
  static const mintAccent = Color(0xFF64FFDA);

  /// Sky teal — logo gradient midpoint
  static const skyTeal = Color(0xFF26C6DA);

  /// Full brand gradient matching the logo (navy → cyan → mint)
  static const LinearGradient brandGradient = LinearGradient(
    colors: [
      Color(0xFF1A237E), // deep navy
      Color(0xFF1565C0), // royal blue
      Color(0xFF00ACC1), // cyan
      Color(0xFF64FFDA), // mint
    ],
    stops: [0.0, 0.35, 0.70, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}