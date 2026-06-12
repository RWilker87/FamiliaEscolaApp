import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double xs   = 6.0;    // chips, tags pequenas
  static const double sm   = 8.0;    // botões pequenos, badges
  static const double md   = 12.0;   // inputs, botões padrão
  static const double lg   = 16.0;   // cards padrão
  static const double xl   = 20.0;   // cards de destaque, modais
  static const double xxl  = 24.0;   // bottom sheets
  static const double full = 100.0;  // pills, avatares, badges circulares

  // BorderRadius helpers
  static const BorderRadius cardBorder    = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius inputBorder   = BorderRadius.all(Radius.circular(md));
  static const BorderRadius buttonBorder  = BorderRadius.all(Radius.circular(md));
  static const BorderRadius chipBorder    = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius pillBorder    = BorderRadius.all(Radius.circular(full));
  static const BorderRadius modalBorder   = BorderRadius.vertical(top: Radius.circular(xxl));
}
