// lib/presentation/providers/flight_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapadokya_balon_app/data/datasources/flight_data_source.dart';
import 'package:kapadokya_balon_app/data/repositories/flight_repository_impl.dart';
import 'package:kapadokya_balon_app/domain/repositories/flight_repository.dart';
import 'package:kapadokya_balon_app/domain/usecases/alert/get_active_alerts_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/alert/observe_alerts_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/flight/end_flight_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/flight/get_flight_status_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/flight/observe_flight_status_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/flight/update_flight_phase_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/sensor/get_all_sensor_data_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/sensor/observe_sensor_data_usecase.dart';
import 'package:kapadokya_balon_app/presentation/providers/sensor_providers.dart';
import 'package:kapadokya_balon_app/presentation/viewmodels/flight_view_model.dart';
import 'package:kapadokya_balon_app/presentation/providers/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ FlightDataSource artık Firestore'dan
final flightDataSourceProvider = Provider<FlightDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final flightId = ref.watch(currentFlightIdProvider);

  if (flightId == null || flightId.isEmpty) {
    // Çalışma zamanında uçuş henüz yaratılmamış olabilir.
    // Bu durumda minimal bir fake datasource fırlatabilir veya hata atabilirsin.
    throw StateError('No active flightId. Set currentFlightIdProvider before using flight VM.');
  }

  return FirestoreFlightDataSource(firestore, flightId);
});

final flightRepositoryProvider = Provider<FlightRepository>((ref) {
  final dataSource = ref.watch(flightDataSourceProvider);
  return FlightRepositoryImpl(dataSource);
});

final getFlightStatusUseCaseProvider = Provider<GetFlightStatusUseCase>((ref) {
  final repository = ref.watch(flightRepositoryProvider);
  return GetFlightStatusUseCase(repository);
});

final updateFlightPhaseUseCaseProvider = Provider<UpdateFlightPhaseUseCase>((ref) {
  final repository = ref.watch(flightRepositoryProvider);
  return UpdateFlightPhaseUseCase(repository);
});

// ✅ Sensör use-case'lerini SensorRepository üzerinden alıyoruz
final getAllSensorDataUseCaseProvider = Provider<GetAllSensorDataUseCase>((ref) {
  final repository = ref.watch(sensorRepositoryProvider);
  return GetAllSensorDataUseCase(repository);
});

final getActiveAlertsUseCaseProvider = Provider<GetActiveAlertsUseCase>((ref) {
  final repository = ref.watch(flightRepositoryProvider);
  return GetActiveAlertsUseCase(repository);
});

final endFlightUseCaseProvider = Provider<EndFlightUseCase>((ref) {
  final repository = ref.watch(flightRepositoryProvider);
  return EndFlightUseCase(repository);
});

final observeSensorDataUseCaseProvider = Provider<ObserveSensorDataUseCase>((ref) {
  final repository = ref.watch(sensorRepositoryProvider);
  return ObserveSensorDataUseCase(repository);
});

final observeFlightStatusUseCaseProvider = Provider<ObserveFlightStatusUseCase>((ref) {
  final repository = ref.watch(flightRepositoryProvider);
  return ObserveFlightStatusUseCase(repository);
});

final observeAlertsUseCaseProvider = Provider<ObserveAlertsUseCase>((ref) {
  final repository = ref.watch(flightRepositoryProvider);
  return ObserveAlertsUseCase(repository);
});

final flightViewModelProvider = StateNotifierProvider<FlightViewModel, FlightState>((ref) {
  return FlightViewModel(
    ref.watch(getFlightStatusUseCaseProvider),
    ref.watch(updateFlightPhaseUseCaseProvider),
    ref.watch(getAllSensorDataUseCaseProvider),
    ref.watch(getActiveAlertsUseCaseProvider),
    ref.watch(endFlightUseCaseProvider),
    ref.watch(observeSensorDataUseCaseProvider),
    ref.watch(observeFlightStatusUseCaseProvider),
    ref.watch(observeAlertsUseCaseProvider),
  );
});
