import '../../entities/sensor_data.dart';
import '../../repositories/sensor_repository.dart';

class GetAllSensorDataUseCase {
  final SensorRepository _repository;

  GetAllSensorDataUseCase(this._repository);

  Future<List<SensorData>> execute(String userId) {
    return _repository.getSensorData(userId);
  }
}