// logger.dart
//
// Uygulama için özelleştirilmiş loglama yardımcısı.
// Hata ayıklama, bilgi ve hata mesajlarını göstermek için kullanılır.

import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Hata ayıklama mesajları
  static void d(String message) {
    _logger.d(message);
  }

  // Bilgi mesajları
  static void i(String message) {
    _logger.i(message);
  }

  // Uyarı mesajları
  static void w(String message) {
    _logger.w(message);
  }

  // Hata mesajları
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message); // error ve stackTrace parametreleri kaldırıldı
  }

  // Kritik hatalar
  static void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.wtf(message); // f yerine wtf metodu kullanıldı
  }
}