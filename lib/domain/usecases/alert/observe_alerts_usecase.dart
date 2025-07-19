// observe_alerts_usecase.dart
//
// Uyarıların akışını izleyen use case.

import 'package:kapadokya_balon_app/domain/entities/alert.dart';
import 'package:kapadokya_balon_app/domain/repositories/flight_repository.dart';

class ObserveAlertsUseCase {
  final FlightRepository repository;

  ObserveAlertsUseCase(this.repository);

  Stream<List<Alert>> call() {
    return repository.observeAlerts();
  }
}