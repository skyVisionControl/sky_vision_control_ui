// get_all_sensor_data_usecase.dart
//
// Tüm sensör verilerini getiren use case.

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/entities/sensor_data.dart';
import 'package:kapadokya_balon_app/domain/repositories/flight_repository.dart';

class GetAllSensorDataUseCase {
  final FlightRepository repository;

  GetAllSensorDataUseCase(this.repository);

  Future<Either<Failure, List<SensorData>>> call() {
    return repository.getAllSensorData();
  }
}