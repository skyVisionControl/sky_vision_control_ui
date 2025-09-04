import '../entities/flight/sensor_data.dart';

abstract class SensorRepository {
  Future<List<SensorData>> getSensorData(String userId);
  Stream<List<SensorData>> observeSensorData(String userId);
}