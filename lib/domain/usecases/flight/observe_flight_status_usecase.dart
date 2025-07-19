// observe_flight_status_usecase.dart
//
// Uçuş durumunun akışını izleyen use case.

import 'package:kapadokya_balon_app/domain/entities/flight_status.dart';
import 'package:kapadokya_balon_app/domain/repositories/flight_repository.dart';

class ObserveFlightStatusUseCase {
  final FlightRepository repository;

  ObserveFlightStatusUseCase(this.repository);

  Stream<FlightStatus> call() {
    return repository.observeFlightStatus();
  }
}