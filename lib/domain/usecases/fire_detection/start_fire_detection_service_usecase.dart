import '../../repositories/fire_detection_repository.dart';

class StartFireDetectionServiceUseCase {
  final FireDetectionRepository _repository;

  StartFireDetectionServiceUseCase(this._repository);

  Future<void> execute(String flightId) {
    return _repository.startFireDetectionService(flightId);
  }
}