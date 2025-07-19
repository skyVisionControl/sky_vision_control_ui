// observe_sensor_data_usecase.dart
//
// Sensör verilerinin akışını izleyen use case.

import 'package:kapadokya_balon_app/domain/entities/sensor_data.dart';
import 'package:kapadokya_balon_app/domain/repositories/flight_repository.dart';

class ObserveSensorDataUseCase {
  final FlightRepository repository;

  ObserveSensorDataUseCase(this.repository);

  Stream<List<SensorData>> call() {
    return repository.observeSensorData();
  }
}