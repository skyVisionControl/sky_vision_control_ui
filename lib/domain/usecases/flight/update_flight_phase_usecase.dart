// update_flight_phase_usecase.dart
//
// Uçuş evresini güncelleyen use case.

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/entities/flight_status.dart';
import 'package:kapadokya_balon_app/domain/repositories/flight_repository.dart';

class UpdateFlightPhaseUseCase {
  final FlightRepository repository;

  UpdateFlightPhaseUseCase(this.repository);

  Future<Either<Failure, FlightStatus>> call(FlightPhase phase) {
    return repository.updateFlightPhase(phase);
  }
}