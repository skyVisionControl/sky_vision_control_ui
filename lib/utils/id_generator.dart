/// Uygulama için benzersiz ID üreten yardımcı fonksiyonlar

// Uçuş ID'si oluştur - captainId'yi kullanarak
String generateFlightId(String captainId) {
  final now = DateTime.now();
  final dateTime = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";

  // captainId-flight-YYYYMMDD-HHMMSS formatında ID
  return "$captainId-flight-$dateTime";
}

// Checklist ID'si oluştur - captainId'yi kullanarak
String generateChecklistId(String captainId) {
  final now = DateTime.now();
  final dateTime = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";

  // captainId-checklist-YYYYMMDD-HHMMSS formatında ID
  return "$captainId-checklist-$dateTime";
}