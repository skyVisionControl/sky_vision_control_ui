// end_flight_usecase.dart
//
// Uçuşu sonlandıran use case.

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/entities/flight/flight_status.dart';
import 'package:kapadokya_balon_app/domain/repositories/flight_repository.dart';

class EndFlightUseCase {
  final FlightRepository repository;

  EndFlightUseCase(this.repository);

  Future<Either<Failure, FlightStatus>> call() {
    return repository.endFlight();
  }
}