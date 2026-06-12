import 'package:flutter/material.dart';

abstract final class AppShadows {
  // ── Nenhuma sombra ────────────────────────────────────────────────────────
  static const List<BoxShadow> none = [];

  // ── sm — cards em lista, elementos secundários ────────────────────────────
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A0F172A), // neutral900 @ 4%
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x060F172A), // neutral900 @ 2.4%
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  // ── md — cards de destaque, quick actions ─────────────────────────────────
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x100F172A), // neutral900 @ 6.3%
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x060F172A), // neutral900 @ 2.4%
      blurRadius: 3,
      offset: Offset(0, 2),
    ),
  ];

  // ── lg — modais, bottom sheets, drawers ───────────────────────────────────
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A0F172A), // neutral900 @ 10%
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A0F172A), // neutral900 @ 4%
      blurRadius: 6,
      offset: Offset(0, 3),
    ),
  ];

  // ── topBar — bottom navigation bar (shadow invertida) ────────────────────
  static const List<BoxShadow> topBar = [
    BoxShadow(
      color: Color(0x0C0F172A), // neutral900 @ 5%
      blurRadius: 8,
      offset: Offset(0, -2),
    ),
  ];

  // ── colored — sombra colorida (ex: header de perfil) ─────────────────────
  static List<BoxShadow> colored(Color color, {double opacity = 0.25}) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
