// get_flight_status_usecase.dart
//
// Mevcut uçuş durumunu getiren use case.

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/entities/flight/flight_status.dart';
import 'package:kapadokya_balon_app/domain/repositories/flight_repository.dart';

class GetFlightStatusUseCase {
  final FlightRepository repository;

  GetFlightStatusUseCase(this.repository);

  Future<Either<Failure, FlightStatus>> call() {
    return repository.getFlightStatus();
  }
}