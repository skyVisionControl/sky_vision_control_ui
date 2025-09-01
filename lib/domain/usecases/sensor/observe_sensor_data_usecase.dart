import '../../entities/sensor_data.dart';
import '../../repositories/sensor_repository.dart';

class ObserveSensorDataUseCase {
  final SensorRepository _repository;

  ObserveSensorDataUseCase(this._repository);

  Stream<List<SensorData>> execute(String userId) {
    return _repository.observeSensorData(userId);
  }
}