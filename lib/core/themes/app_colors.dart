// app_colors.dart
//
// Uygulama genelinde kullanılan renkleri tanımlar.
// Hem açık hem de koyu tema için renk değerleri içerir.


import 'package:flutter/material.dart';

class AppColors {
  // Ana Renkler - Açık Tema
  static const Color primary = Color(0xFF1E88E5);    // Mavi
  static const Color secondary = Color(0xFF26A69A);  // Turkuaz
  static const Color accent = Color(0xFFFF7043);     // Turuncu

  // Arka Plan Renkleri - Açık Tema
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color cardLight = Colors.white;
  static const Color border = Color(0xFFE0E0E0);

  // Metin Renkleri - Açık Tema
  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF607D8B);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Durum Renkleri
  static const Color success = Color(0xFF4CAF50);   // Yeşil
  static const Color warning = Color(0xFFFFC107);   // Sarı
  static const Color error = Color(0xFFF44336);     // Kırmızı
  static const Color info = Color(0xFF2196F3);      // Mavi

  // Ana Renkler - Koyu Tema
  static const Color primaryDark = Color(0xFF42A5F5);    // Mavi
  static const Color secondaryDark = Color(0xFF4DB6AC);  // Turkuaz
  static const Color accentDark = Color(0xFFFF9E80);     // Turuncu

  // Arka Plan Renkleri - Koyu Tema
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color borderDark = Color(0xFF424242);

  // Metin Renkleri - Koyu Tema
  static const Color textPrimaryDark = Color(0xFFECEFF1);
  static const Color textSecondaryDark = Color(0xFFB0BEC5);
  static const Color textDisabledDark = Color(0xFF757575);

  // Durum Renkleri - Koyu Tema
  static const Color successDark = Color(0xFF66BB6A);   // Yeşil
  static const Color warningDark = Color(0xFFFFD54F);   // Sarı
  static const Color errorDark = Color(0xFFE57373);     // Kırmızı
  static const Color infoDark = Color(0xFF64B5F6);      // Mavi

  // Sensor Gösterge Renkleri
  static const Color altitudeGauge = Color(0xFF1E88E5);
  static const Color speedGauge = Color(0xFF26A69A);
  static const Color temperatureGauge = Color(0xFFE53935);
  static const Color humidityGauge = Color(0xFF7CB342);
  static const Color directionGauge = Color(0xFF5E35B1);
}