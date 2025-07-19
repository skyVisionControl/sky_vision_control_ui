
// Uygulama genelinde kullanılan sabit değerleri içerir.
// Metinler, sayılar, API URL'leri gibi değerler burada saklanır.


class AppConstants {
  // Uygulama Adı
  static const String appName = "Kapadokya Balon Kaptanları";

  // API URL'leri (Mock şimdilik)
  static const String baseUrl = "https://api.example.com";

  // Uygulama İçi Sabitler
  static const int timeoutDuration = 30; // saniye
  static const int maxLoginAttempts = 3;

  // Checklist Kategorileri
  static const List<String> checklistCategories = [
    "Uçuş Öncesi",
    "Ekipman Kontrolü",
    "Hava Durumu",
    "Yolcu Güvenliği",
    "İletişim"
  ];

  // Sensör Birimleri
  static const String altitudeUnit = "m";
  static const String speedUnit = "km/h";
  static const String temperatureUnit = "°C";
  static const String humidityUnit = "%";

  // Hata Mesajları
  static const String connectionError = "Bağlantı hatası. Lütfen internet bağlantınızı kontrol edin.";
  static const String authError = "Kimlik doğrulama hatası. Lütfen tekrar deneyin.";
  static const String unknownError = "Bilinmeyen bir hata oluştu. Lütfen tekrar deneyin.";
}