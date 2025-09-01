import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/sensor_data.dart';
import '../../domain/usecases/sensor/get_all_sensor_data_usecase.dart';
import '../../domain/usecases/sensor/observe_sensor_data_usecase.dart';

class SensorState {
  final bool isLoading;
  final String? errorMessage;
  final List<SensorData> sensorDataList;
  final DateTime lastUpdated;

  SensorState({
    this.isLoading = false,
    this.errorMessage,
    this.sensorDataList = const [],
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  SensorState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<SensorData>? sensorDataList,
    DateTime? lastUpdated,
  }) {
    return SensorState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      sensorDataList: sensorDataList ?? this.sensorDataList,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class SensorViewModel extends StateNotifier<SensorState> {
  final GetAllSensorDataUseCase _getAllSensorData;
  final ObserveSensorDataUseCase _observeSensorData;
  final String _userId;

  StreamSubscription? _sensorSubscription;

  SensorViewModel({
    required GetAllSensorDataUseCase getAllSensorData,
    required ObserveSensorDataUseCase observeSensorData,
    required String userId,
  })  : _getAllSensorData = getAllSensorData,
        _observeSensorData = observeSensorData,
        _userId = userId,
        super(SensorState()) {
    // İlk başta verileri yükle
    loadSensorData();
    // Gerçek zamanlı güncellemeleri dinle
    _startListening();
  }

  Future<void> loadSensorData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final sensorData = await _getAllSensorData.execute(_userId);
      state = state.copyWith(
        isLoading: false,
        sensorDataList: sensorData,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sensör verileri yüklenirken hata oluştu: $e',
      );
    }
  }

  void _startListening() {
    _sensorSubscription?.cancel();

    // Stream dinlemeye başlarken loading'i aç
    state = state.copyWith(isLoading: true, errorMessage: null);

    _sensorSubscription = _observeSensorData.execute(_userId).listen(
          (sensorData) {
        state = state.copyWith(
          isLoading: false,              // ✅ yüklemeyi kapat
          sensorDataList: sensorData,
          lastUpdated: DateTime.now(),
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,              // ✅ hata olsa da kapat
          errorMessage: 'Sensör verilerini dinlerken hata oluştu: $error',
        );
      },
    );
  }


  void refreshData() {
    loadSensorData();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // Belirli bir sensör tipine göre veri al
  SensorData? getSensorData(SensorType type) {
    try {
      return state.sensorDataList.firstWhere((data) => data.type == type);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }
}