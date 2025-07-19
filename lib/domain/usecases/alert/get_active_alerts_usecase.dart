// get_active_alerts_usecase.dart
//
// Aktif uyarıları getiren use case.

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/entities/alert.dart';
import 'package:kapadokya_balon_app/domain/repositories/flight_repository.dart';

class GetActiveAlertsUseCase {
  final FlightRepository repository;

  GetActiveAlertsUseCase(this.repository);

  Future<Either<Failure, List<Alert>>> call() {
    return repository.getActiveAlerts();
  }
}