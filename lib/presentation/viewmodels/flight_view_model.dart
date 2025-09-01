import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final FirebaseAuth _auth;

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
      this._observeAlertsUseCase, {
        FirebaseAuth? auth,
      })  : _auth = auth ?? FirebaseAuth.instance,
        super(FlightState()) {
    _startObserving();
  }
  String get _userId => _auth.currentUser?.uid ?? "";
  String get _sensorUserId => state.flightStatus?.telemetry?['rtdbUserId'] ?? _userId;

  @override
  void dispose() {
    _stopObserving();
    super.dispose();
  }

  void _startObserving() {
    print('_sensorUserId: $_sensorUserId');
    _stopObserving();

    // 🔴 Uçuş durumu
    _flightStatusSubscription = _observeFlightStatusUseCase().listen(
          (status) {
        state = state.copyWith(flightStatus: status);
      },
      onError: (e) {
        state = state.copyWith(errorMessage: 'Uçuş durumu dinlenirken hata: $e');
      },
    );

    // 🔴 Sensör verileri
    if (_userId.isNotEmpty) {
      _sensorDataSubscription = _observeSensorDataUseCase.execute(_sensorUserId).listen(
                (data) {
              state = state.copyWith(sensorData: data);
            },
            onError: (e) {
              state = state.copyWith(
                  errorMessage: 'Sensör verileri dinlenirken hata: $e');
            },
          );
    }

    // 🔴 Uyarılar
    _alertsSubscription = _observeAlertsUseCase().listen(
          (alerts) {
        state = state.copyWith(activeAlerts: alerts);
      },
      onError: (e) {
        state = state.copyWith(errorMessage: 'Uyarılar dinlenirken hata: $e');
      },
    );
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _getFlightStatusUseCase();

    result.fold(
          (failure) => state =
          state.copyWith(isLoading: false, errorMessage: failure.message),
          (status) =>
          state.copyWith(isLoading: false, flightStatus: status),
    );
  }

  void _stopObserving() {
    _sensorDataSubscription?.cancel();
    _flightStatusSubscription?.cancel();
    _alertsSubscription?.cancel();
  }

  Future<void> loadSensorData() async {
    print('_sensorUserId: $_sensorUserId');
    if (_userId.isEmpty) return;

    final sensors = await _getAllSensorDataUseCase.execute(_sensorUserId);
    try {
      final sensors = await _getAllSensorDataUseCase.execute(_userId);
      state = state.copyWith(isLoading: false, sensorData: sensors);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: "Sensör verisi alınamadı: $e");
    }
  }

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

  SensorData? getSensorData(SensorType type) {
    try {
      return state.sensorData.firstWhere((s) => s.type == type);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
