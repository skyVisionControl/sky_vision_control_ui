import '../../domain/entities/fire_detection_violation.dart';
import '../../domain/repositories/fire_detection_repository.dart';
import '../services/fire_detection_service.dart';
import '../services/firebase_violation_service.dart';

class FireDetectionRepositoryImpl implements FireDetectionRepository {
  final FireDetectionService _fireDetectionService;
  final FirebaseViolationService _violationService;

  FireDetectionRepositoryImpl(this._fireDetectionService, this._violationService);

  @override
  Future<List<FireDetectionViolation>> getFireDetectionsByFlightId(String flightId) {
    return _violationService.getFireDetectionsByFlightId(flightId);
  }

  @override
  Future<void> logFireDetection(FireDetectionViolation violation) async {
    await _violationService.logFireDetection(
      flightId: violation.flightId,
      confidence: violation.confidence,
      detectionType: violation.detectionType,
      imageUrl: violation.imageUrl,
    );
  }

  @override
  Future<void> startFireDetectionService(String flightId) async {
    await _fireDetectionService.startDetection(flightId);
  }

  @override
  Future<void> stopFireDetectionService() async {
    _fireDetectionService.stopDetection();
  }
}