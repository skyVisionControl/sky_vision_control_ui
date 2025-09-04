import '../../repositories/fire_detection_repository.dart';

class StopFireDetectionServiceUseCase {
  final FireDetectionRepository _repository;

  StopFireDetectionServiceUseCase(this._repository);

  Future<void> execute() {
    return _repository.stopFireDetectionService();
  }
}