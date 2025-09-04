// lib/presentation/providers/sensor_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../data/services/flight/firebase_rtdb_service.dart';
import '../../data/repositories/sensor_repository_impl.dart';
import '../../domain/usecases/sensor/get_all_sensor_data_usecase.dart';
import '../../domain/usecases/sensor/observe_sensor_data_usecase.dart';
import '../viewmodels/sensor_view_model.dart';
import 'auth_providers.dart';

// ✅ RTDB EU endpoint'i kullan
final firebaseRtdbProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instanceFor(
    databaseURL: 'https://sky-vision-control-5ca1b-default-rtdb.europe-west1.firebasedatabase.app', app: FirebaseDatabase.instance.app,
  );
});

final firebaseRtdbServiceProvider = Provider<FirebaseRtdbService>((ref) {
  final rtdb = ref.watch(firebaseRtdbProvider);
  return FirebaseRtdbService(database: rtdb); // artık EU instance geliyor
});

final sensorRepositoryProvider = Provider<SensorRepositoryImpl>((ref) {
  final rtdbService = ref.watch(firebaseRtdbServiceProvider);
  return SensorRepositoryImpl(rtdbService);
});

final getAllSensorDataUseCaseProvider = Provider<GetAllSensorDataUseCase>((ref) {
  final repository = ref.watch(sensorRepositoryProvider);
  return GetAllSensorDataUseCase(repository);
});

final observeSensorDataUseCaseProvider = Provider<ObserveSensorDataUseCase>((ref) {
  final repository = ref.watch(sensorRepositoryProvider);
  return ObserveSensorDataUseCase(repository);
});

final sensorViewModelProvider = StateNotifierProvider<SensorViewModel, SensorState>((ref) {
  final getAllSensorData = ref.watch(getAllSensorDataUseCaseProvider);
  final observeSensorData = ref.watch(observeSensorDataUseCaseProvider);
  final authState = ref.watch(authViewModelProvider);

  final userId = authState.user?.id ?? 'k1EJQXvcsydXeREjLunVwHPE9wr2';

  return SensorViewModel(
    getAllSensorData: getAllSensorData,
    observeSensorData: observeSensorData,
    userId: userId,
  );
});
