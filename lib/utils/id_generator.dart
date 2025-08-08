/// Uygulama için benzersiz ID üreten yardımcı fonksiyonlar

// Uçuş ID'si oluştur
String generateFlightId(String captainUsername) {
  final now = DateTime.now();
  final date = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
  final time = "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";

  // CaptainUsername-YYYYMMDD-HHMMSS formatında bir ID oluştur
  return "$captainUsername-$date-$time";
}

// Checklist öğesi ID'si oluştur
String generateChecklistItemId(String flightId, String itemTitle) {
  // flightId + title'ın ilk 10 karakteri + rastgele sayı
  final titlePrefix = itemTitle.length > 10 ? itemTitle.substring(0, 10) : itemTitle;
  final randomNum = DateTime.now().millisecondsSinceEpoch % 1000;

  return "$flightId-${titlePrefix.replaceAll(' ', '_')}-$randomNum";
}