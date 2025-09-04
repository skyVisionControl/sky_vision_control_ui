/// Uygulama için benzersiz ID üreten yardımcı fonksiyonlar

final now = DateTime.now();
final dateTime = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
// Uçuş ID'si oluştur - captainId'yi kullanarak
String generateFlightId(String captainId) {

  // captainId-flight-YYYYMMDD-HHMMSS formatında ID
  return "$captainId-flight-$dateTime";
}

// Checklist ID'si oluştur - captainId'yi kullanarak
String generateChecklistId(String captainId) {

  // captainId-checklist-YYYYMMDD-HHMMSS formatında ID
  return "$captainId-checklist-$dateTime";
}

// Breathalyzer ID'si oluştur - captainId'yi kullanarak
String generateBreathalyzerId(String captainId) {

  // captainId-breathalyzer-YYYYMMDD-HHMMSS formatında ID
  return "$captainId-breathalyzer-$dateTime";
}

/// Yangın algılama ihlali ID'si oluştur
String generateViolationId(String flightId, String violationType) {

  // flightId-violationType-YYYYMMDD-HHMMSS formatında ID
  return "$flightId-$violationType-$dateTime";
}