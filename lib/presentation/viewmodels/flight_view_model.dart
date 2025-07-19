// flight_view_model.dart
//
// Uçuş ekranları için view model.
//
// Yazan: Deniz Dogan
// Tarih: 2025-07-19

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapadokya_balon_app/domain/entities/alert.dart';
import 'package:kapadokya_balon_app/domain/entities/flight_status.dart';
import 'package:kapadokya_balon_app/domain/entities/sensor_data.dart';
import 'package:kapadokya_balon_app/domain/usecases/alert/get_active_alerts_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/alert/observe_alerts_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/flight/end_flight_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/flight/get_flight_status_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/flight/observe_flight_status_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/flight/update_flight_phase_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/sensor/get_all_sensor_data_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/sensor/observe_sensor_data_usecase.dart';

class FlightState {
  final bool isLoading;
  final String? errorMessage;
  final FlightStatus? flightStatus;
  final List<SensorData> sensorData;
  final List<Alert> activeAlerts;
  final bool isEndingFlight;
  final bool isChangingPhase;

  FlightState({
    this.isLoading = false,
    this.errorMessage,
    this.flightStatus,
    this.sensorData = const [],
    this.activeAlerts = const [],
    this.isEndingFlight = false,
    this.isChangingPhase = false,
  });

  FlightState copyWith({
    bool? isLoading,
    String? errorMessage,
    FlightStatus? flightStatus,
    List<SensorData>? sensorData,
    List<Alert>? activeAlerts,
    bool? isEndingFlight,
    bool? isChangingPhase,
  }) {
    return FlightState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      flightStatus: flightStatus ?? this.flightStatus,
      sensorData: sensorData ?? this.sensorData,
      activeAlerts: activeAlerts ?? this.activeAlerts,
      isEndingFlight: isEndingFlight ?? this.isEndingFlight,
      isChangingPhase: isChangingPhase ?? this.isChangingPhase,
    );
  }
}

class FlightViewModel extends StateNotifier<FlightState> {
  final GetFlightStatusUseCase _getFlightStatusUseCase;
  final UpdateFlightPhaseUseCase _updateFlightPhaseUseCase;
  final GetAllSensorDataUseCase _getAllSensorDataUseCase;
  final GetActiveAlertsUseCase _getActiveAlertsUseCase;
  final EndFlightUseCase _endFlightUseCase;
  final ObserveSensorDataUseCase _observeSensorDataUseCase;
  final ObserveFlightStatusUseCase _observeFlightStatusUseCase;
  final ObserveAlertsUseCase _observeAlertsUseCase;

  StreamSubscription<List<SensorData>>? _sensorDataSubscription;
  StreamSubscription<FlightStatus>? _flightStatusSubscription;
  StreamSubscription<List<Alert>>? _alertsSubscription;

  FlightViewModel(
      this._getFlightStatusUseCase,
      this._updateFlightPhaseUseCase,
      this._getAllSensorDataUseCase,
      this._getActiveAlertsUseCase,
      this._endFlightUseCase,
      this._observeSensorDataUseCase,
      this._observeFlightStatusUseCase,
      this._observeAlertsUseCase,
      ) : super(FlightState()) {
    // Akışlara abone ol
    _startObserving();
  }

  @override
  void dispose() {
    _stopObserving();
    super.dispose();
  }

  void _startObserving() {
    // Sensör verilerini izle
    _sensorDataSubscription = _observeSensorDataUseCase().listen(
          (data) {
        state = state.copyWith(sensorData: data);
      },
      onError: (error) {
        state = state.copyWith(errorMessage: 'Sensör verisi izleme hatası: $error');
      },
    );

    // Uçuş durumunu izle
    _flightStatusSubscription = _observeFlightStatusUseCase().listen(
          (status) {
        state = state.copyWith(flightStatus: status);
      },
      onError: (error) {
        state = state.copyWith(errorMessage: 'Uçuş durumu izleme hatası: $error');
      },
    );

    // Uyarıları izle
    _alertsSubscription = _observeAlertsUseCase().listen(
          (alerts) {
        state = state.copyWith(activeAlerts: alerts);
      },
      onError: (error) {
        state = state.copyWith(errorMessage: 'Uyarı izleme hatası: $error');
      },
    );
  }

  void _stopObserving() {
    _sensorDataSubscription?.cancel();
    _flightStatusSubscription?.cancel();
    _alertsSubscription?.cancel();
  }

  // Verileri ilk kez yükle
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Uçuş durumunu yükle
    final flightStatusResult = await _getFlightStatusUseCase();

    flightStatusResult.fold(
          (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: 'Uçuş durumu yüklenirken hata: ${failure.message}',
      ),
          (flightStatus) async {
        // Sensör verilerini yükle
        final sensorDataResult = await _getAllSensorDataUseCase();

        sensorDataResult.fold(
              (failure) => state = state.copyWith(
            isLoading: false,
            flightStatus: flightStatus,
            errorMessage: 'Sensör verileri yüklenirken hata: ${failure.message}',
          ),
              (sensorData) async {
            // Uyarıları yükle
            final alertsResult = await _getActiveAlertsUseCase();

            alertsResult.fold(
                  (failure) => state = state.copyWith(
                isLoading: false,
                flightStatus: flightStatus,
                sensorData: sensorData,
                errorMessage: 'Uyarılar yüklenirken hata: ${failure.message}',
              ),
                  (alerts) => state = state.copyWith(
                isLoading: false,
                flightStatus: flightStatus,
                sensorData: sensorData,
                activeAlerts: alerts,
              ),
            );
          },
        );
      },
    );
  }

  // Uçuş evresini güncelle
  Future<void> updateFlightPhase(FlightPhase phase) async {
    state = state.copyWith(isChangingPhase: true, errorMessage: null);

    final result = await _updateFlightPhaseUseCase(phase);

    result.fold(
          (failure) => state = state.copyWith(
        isChangingPhase: false,
        errorMessage: 'Uçuş evresi güncellenirken hata: ${failure.message}',
      ),
          (updatedStatus) => state = state.copyWith(
        isChangingPhase: false,
        flightStatus: updatedStatus,
      ),
    );
  }

  // Uçuşu sonlandır
  Future<void> endFlight() async {
    state = state.copyWith(isEndingFlight: true, errorMessage: null);

    final result = await _endFlightUseCase();

    result.fold(
          (failure) => state = state.copyWith(
        isEndingFlight: false,
        errorMessage: 'Uçuş sonlandırılırken hata: ${failure.message}',
      ),
          (updatedStatus) => state = state.copyWith(
        isEndingFlight: false,
        flightStatus: updatedStatus,
      ),
    );
  }

  // Sensör verisi getir
  SensorData? getSensorData(SensorType type) {
    try {
      return state.sensorData.firstWhere((sensor) => sensor.type == type);
    } catch (e) {
      return null;
    }
  }

  // Hata mesajını temizle
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}