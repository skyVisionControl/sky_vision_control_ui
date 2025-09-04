import 'package:kapadokya_balon_app/data/services/flight/firebase_rtdb_service.dart';
import '../../domain/entities/flight/sensor_data.dart';
import '../../domain/repositories/sensor_repository.dart';
import '../models/telemetry_data_model.dart';

class SensorRepositoryImpl implements SensorRepository {
  final FirebaseRtdbService _rtdbService;

  SensorRepositoryImpl(this._rtdbService);

  @override
  Future<List<SensorData>> getSensorData(String userId) async {
    final telemetry = await _rtdbService.getTelemetryData(userId);
    return telemetry?.toSensorDataList() ?? [];
  }

  @override
  Stream<List<SensorData>> observeSensorData(String userId) {
    return _rtdbService.observeTelemetryData(userId).map((telemetry) {
      return telemetry?.toSensorDataList() ?? [];
    });
  }
}