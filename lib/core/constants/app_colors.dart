import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand — Emerald scale (Tailwind) ──────────────────────────────────────
  static const Color primary50  = Color(0xFFF0FDF4);
  static const Color primary100 = Color(0xFFDCFCE7);
  static const Color primary200 = Color(0xFFBBF7D0);
  static const Color primary300 = Color(0xFF86EFAC);
  static const Color primary400 = Color(0xFF4ADE80);
  static const Color primary500 = Color(0xFF22C55E);
  static const Color primary600 = Color(0xFF16A34A); // ← cor primária do app
  static const Color primary700 = Color(0xFF15803D);
  static const Color primary800 = Color(0xFF166534);
  static const Color primary900 = Color(0xFF14532D);

  // ── Neutrals — Slate scale (Tailwind) ────────────────────────────────────
  static const Color neutral50  = Color(0xFFF8FAFC); // background
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0); // borders
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8); // placeholder
  static const Color neutral500 = Color(0xFF64748B); // subtitle (contraste 4.6:1 ✓)
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155); // secondary text
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A); // primary text

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color error        = Color(0xFFEF4444);
  static const Color errorLight   = Color(0xFFFEF2F2);
  static const Color errorDark    = Color(0xFF991B1B);

  static const Color warning      = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color warningDark  = Color(0xFF92400E);

  static const Color success      = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFF0FDF4);

  static const Color info         = Color(0xFF3B82F6);
  static const Color infoLight    = Color(0xFFEFF6FF);
  static const Color infoDark     = Color(0xFF1D4ED8);

  // ── Category accents — paleta coesa para quick actions ───────────────────
  static const Color accentBlue   = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentTeal   = Color(0xFF14B8A6);
  static const Color accentRose   = Color(0xFFF43F5E);

  // ── Utility ───────────────────────────────────────────────────────────────
  static const Color white       = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  // ── Sombras (cores) ───────────────────────────────────────────────────────
  static const Color shadowColor = Color(0x0A0F172A); // neutral900 @ 4%
}
