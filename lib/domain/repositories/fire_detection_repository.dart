import '../entities/fire_detection_violation.dart';

abstract class FireDetectionRepository {
  /// Yangın algılama ihlalini Firebase'e kaydet
  Future<void> logFireDetection(FireDetectionViolation violation);

  /// Belirli bir uçuşa ait yangın algılama ihlallerini getir
  Future<List<FireDetectionViolation>> getFireDetectionsByFlightId(String flightId);

  /// Yangın algılama servisini başlat
  Future<void> startFireDetectionService(String flightId);

  /// Yangın algılama servisini durdur
  Future<void> stopFireDetectionService();
}