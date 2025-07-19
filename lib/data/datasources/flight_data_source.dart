// flight_data_source.dart
//
// Uçuş ve sensör verileri için veri kaynağı arayüzü ve mock implementasyonu.

import 'dart:async';
import 'dart:math';

import 'package:kapadokya_balon_app/data/models/alert_model.dart';
import 'package:kapadokya_balon_app/data/models/flight_status_model.dart';
import 'package:kapadokya_balon_app/data/models/sensor_data_model.dart';
import 'package:kapadokya_balon_app/domain/entities/flight_status.dart';
import 'package:kapadokya_balon_app/domain/entities/sensor_data.dart';

abstract class FlightDataSource {
  Future<FlightStatusModel> getFlightStatus();
  Future<FlightStatusModel> updateFlightPhase(FlightPhase phase);
  Future<List<SensorDataModel>> getAllSensorData();
  Future<SensorDataModel> getSensorData(SensorType type);
  Future<List<AlertModel>> getActiveAlerts();
  Future<AlertModel> acknowledgeAlert(String alertId);
  Future<AlertModel> resolveAlert(String alertId);
  Future<FlightStatusModel> endFlight();
  Future<FlightStatusModel> toggleEmergencyMode(bool isActive);
  Future<void> reportIssue({
    required String title,
    required String description,
    SensorType? relatedSensorType,
  });

  Stream<List<SensorDataModel>> observeSensorData();
  Stream<FlightStatusModel> observeFlightStatus();
  Stream<List<AlertModel>> observeAlerts();
}

FlightStatusModel _createFlightStatusModel(
    FlightStatus status, {
      FlightPhase? phase,
      DateTime? endTime,
      double? currentAltitude,
      double? maxAltitude,
      double? groundSpeed,
      double? verticalSpeed,
      double? fuelLevel,
      bool? hasActiveWarnings,
      bool? hasActiveCriticalAlerts,
      bool? isEmergencyMode,
      double? latitude,
      double? longitude,
      bool? hasGPSSignal,
    }) {
  return FlightStatusModel(
    flightId: status.flightId,
    startTime: status.startTime,
    endTime: endTime ?? status.endTime,
    currentPhase: phase ?? status.currentPhase,
    maxAltitude: maxAltitude ?? status.maxAltitude,
    currentAltitude: currentAltitude ?? status.currentAltitude,
    groundSpeed: groundSpeed ?? status.groundSpeed,
    verticalSpeed: verticalSpeed ?? status.verticalSpeed,
    fuelLevel: fuelLevel ?? status.fuelLevel,
    hasActiveWarnings: hasActiveWarnings ?? status.hasActiveWarnings,
    hasActiveCriticalAlerts: hasActiveCriticalAlerts ?? status.hasActiveCriticalAlerts,
    isEmergencyMode: isEmergencyMode ?? status.isEmergencyMode,
    latitude: latitude ?? status.latitude,
    longitude: longitude ?? status.longitude,
    hasGPSSignal: hasGPSSignal ?? status.hasGPSSignal,
  );
}


class MockFlightDataSource implements FlightDataSource {
  // Mevcut uçuş durumu
  FlightStatusModel _currentFlightStatus = FlightStatusModel(
    flightId: 'KPD-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8)}',
    startTime: DateTime.now(),
    currentPhase: FlightPhase.preparation,
    maxAltitude: 0.0,
    currentAltitude: 0.0,
    groundSpeed: 0.0,
    verticalSpeed: 0.0,
    fuelLevel: 100.0,
    hasActiveWarnings: false,
    hasActiveCriticalAlerts: false,
    isEmergencyMode: false,
    latitude: 38.6431,
    longitude: 34.8287,
    hasGPSSignal: true,
  );

  // Mevcut sensör verileri
  final List<SensorDataModel> _sensorData = [
    SensorDataModel(
      type: SensorType.altitude,
      value: 0.0,
      unit: 'm',
      alertLevel: AlertLevel.none,
      timestamp: DateTime.now(),
      minValue: 0.0,
      maxValue: 3000.0,
    ),
    SensorDataModel(
      type: SensorType.temperature,
      value: 24.5,
      unit: '°C',
      alertLevel: AlertLevel.none,
      timestamp: DateTime.now(),
      minValue: -10.0,
      maxValue: 120.0,
    ),
    SensorDataModel(
      type: SensorType.pressure,
      value: 1013.25,
      unit: 'hPa',
      alertLevel: AlertLevel.none,
      timestamp: DateTime.now(),
      minValue: 900.0,
      maxValue: 1100.0,
    ),
    SensorDataModel(
      type: SensorType.direction,
      value: 180.0,
      unit: '°',
      alertLevel: AlertLevel.none,
      timestamp: DateTime.now(),
      minValue: 0.0,
      maxValue: 360.0,
    ),
    SensorDataModel(
      type: SensorType.speed,
      value: 0.0,
      unit: 'km/h',
      alertLevel: AlertLevel.none,
      timestamp: DateTime.now(),
      minValue: 0.0,
      maxValue: 50.0,
    ),
    SensorDataModel(
      type: SensorType.fuelLevel,
      value: 100.0,
      unit: '%',
      alertLevel: AlertLevel.none,
      timestamp: DateTime.now(),
      minValue: 0.0,
      maxValue: 100.0,
    ),
    SensorDataModel(
      type: SensorType.verticalSpeed,
      value: 0.0,
      unit: 'm/s',
      alertLevel: AlertLevel.none,
      timestamp: DateTime.now(),
      minValue: -5.0,
      maxValue: 5.0,
    ),
    SensorDataModel(
      type: SensorType.gpsPosition,
      value: 38.6431, // Enlem
      unit: 'koordinat',
      alertLevel: AlertLevel.none,
      timestamp: DateTime.now(),
      minValue: -90.0,
      maxValue: 90.0,
      secondaryValue: 34.8287, // Boylam
    ),
  ];

  // Aktif uyarılar
  final List<AlertModel> _activeAlerts = [];

  // Stream controllers
  final _sensorDataStreamController = StreamController<List<SensorDataModel>>.broadcast();
  final _flightStatusStreamController = StreamController<FlightStatusModel>.broadcast();
  final _alertsStreamController = StreamController<List<AlertModel>>.broadcast();

  // Simülasyon için timer
  Timer? _simulationTimer;
  final Random _random = Random();

  MockFlightDataSource() {
    // Simülasyon timerını başlat
    _startSimulation();
  }

  void _startSimulation() {
    // Her 2 saniyede bir sensör verilerini güncelle
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateSensorData();
      _checkForAlerts();

      // Stream'lere güncel verileri gönder
      _sensorDataStreamController.add(_sensorData);
      _flightStatusStreamController.add(_currentFlightStatus);
      _alertsStreamController.add(_activeAlerts);
    });
  }

  void _updateSensorData() {
    final phase = _currentFlightStatus.currentPhase;

    // Uçuş evresine göre sensör değerlerini güncelle
    switch (phase) {
      case FlightPhase.preparation:
      // Hazırlık aşamasında değerler minimum
        _updateSensor(SensorType.altitude, 0.0);
        _updateSensor(SensorType.speed, 0.0);
        _updateSensor(SensorType.verticalSpeed, 0.0);
        _updateSensor(SensorType.fuelLevel, 100.0);
        _updateSensor(SensorType.direction, _random.nextDouble() * 360);
        _updateSensor(SensorType.temperature, 20 + _random.nextDouble() * 5);
        break;

      case FlightPhase.inflation:
      // Şişirme aşamasında sıcaklık artıyor
        _updateSensor(SensorType.altitude, 0.0);
        _updateSensor(SensorType.speed, 0.0);
        _updateSensor(SensorType.verticalSpeed, 0.0);
        _updateSensor(SensorType.fuelLevel, 100.0);
        _updateSensor(SensorType.temperature, 40 + _random.nextDouble() * 30);
        _updateSensor(SensorType.direction, _random.nextDouble() * 360);
        break;

      case FlightPhase.takeoff:
      // Kalkış aşamasında yükseklik ve dikey hız artıyor
        _updateSensor(SensorType.altitude, 5 + _random.nextDouble() * 20);
        _updateSensor(SensorType.speed, 2 + _random.nextDouble() * 5);
        _updateSensor(SensorType.verticalSpeed, 1 + _random.nextDouble() * 2);
        _updateSensor(SensorType.fuelLevel, 98 - _random.nextDouble() * 3);
        _updateSensor(SensorType.temperature, 60 + _random.nextDouble() * 30);
        _updateSensor(SensorType.direction, _random.nextDouble() * 360);
        break;

      case FlightPhase.climbing:
      // Yükseliş aşamasında yükseklik hızla artıyor
        final currentAltitude = _getSensorValue(SensorType.altitude);
        _updateSensor(SensorType.altitude, currentAltitude + (10 + _random.nextDouble() * 30));
        _updateSensor(SensorType.speed, 5 + _random.nextDouble() * 10);
        _updateSensor(SensorType.verticalSpeed, 1.5 + _random.nextDouble() * 2);
        _updateSensor(SensorType.fuelLevel, _getSensorValue(SensorType.fuelLevel) - (1 + _random.nextDouble() * 2));
        _updateSensor(SensorType.temperature, 70 + _random.nextDouble() * 30);
        _updateSensor(SensorType.direction, _random.nextDouble() * 360);
        break;

      case FlightPhase.cruising:
      // Seyir aşamasında yükseklik sabit, hız değişken
        final currentAltitude = _getSensorValue(SensorType.altitude);
        _updateSensor(SensorType.altitude, currentAltitude + (_random.nextDouble() * 20 - 10));
        _updateSensor(SensorType.speed, 10 + _random.nextDouble() * 15);
        _updateSensor(SensorType.verticalSpeed, _random.nextDouble() * 1 - 0.5);
        _updateSensor(SensorType.fuelLevel, _getSensorValue(SensorType.fuelLevel) - (0.5 + _random.nextDouble() * 1));
        _updateSensor(SensorType.temperature, 70 + _random.nextDouble() * 30);
        _updateSensor(SensorType.direction, _random.nextDouble() * 360);
        break;

      case FlightPhase.descending:
      // Alçalma aşamasında yükseklik azalıyor
        final currentAltitude = _getSensorValue(SensorType.altitude);
        _updateSensor(SensorType.altitude, max(0, currentAltitude - (10 + _random.nextDouble() * 20)));
        _updateSensor(SensorType.speed, 5 + _random.nextDouble() * 10);
        _updateSensor(SensorType.verticalSpeed, -1 - _random.nextDouble() * 1.5);
        _updateSensor(SensorType.fuelLevel, _getSensorValue(SensorType.fuelLevel) - (0.3 + _random.nextDouble() * 0.7));
        _updateSensor(SensorType.temperature, 60 + _random.nextDouble() * 20);
        _updateSensor(SensorType.direction, _random.nextDouble() * 360);
        break;

      case FlightPhase.landing:
      // İniş aşamasında yükseklik hızla azalıyor
        final currentAltitude = _getSensorValue(SensorType.altitude);
        _updateSensor(SensorType.altitude, max(0, currentAltitude - (5 + _random.nextDouble() * 15)));
        _updateSensor(SensorType.speed, max(0, _getSensorValue(SensorType.speed) - (1 + _random.nextDouble() * 3)));
        _updateSensor(SensorType.verticalSpeed, -0.5 - _random.nextDouble() * 1);
        _updateSensor(SensorType.fuelLevel, _getSensorValue(SensorType.fuelLevel) - (0.2 + _random.nextDouble() * 0.5));
        _updateSensor(SensorType.temperature, 50 + _random.nextDouble() * 20);
        _updateSensor(SensorType.direction, _random.nextDouble() * 360);
        break;

      case FlightPhase.completed:
      // Tamamlanmış uçuşta değerler minimum
        _updateSensor(SensorType.altitude, 0.0);
        _updateSensor(SensorType.speed, 0.0);
        _updateSensor(SensorType.verticalSpeed, 0.0);
        _updateSensor(SensorType.fuelLevel, _getSensorValue(SensorType.fuelLevel));
        _updateSensor(SensorType.temperature, 30 + _random.nextDouble() * 10);
        _updateSensor(SensorType.direction, _random.nextDouble() * 360);
        break;
    }

    // Basınç değeri yükseklikle ters orantılı
    final altitude = _getSensorValue(SensorType.altitude);
    _updateSensor(SensorType.pressure, 1013.25 - (altitude / 100) * 1.2);

    // GPS konumu hafifçe değiştir
    _updateSensor(
      SensorType.gpsPosition,
      _currentFlightStatus.latitude + (_random.nextDouble() * 0.01 - 0.005),
      secondaryValue: _currentFlightStatus.longitude + (_random.nextDouble() * 0.01 - 0.005),
    );

    // Uçuş durumunu güncelle
    double currentAltitude = _getSensorValue(SensorType.altitude);
    double maxAltitude = _currentFlightStatus.maxAltitude;
    if (currentAltitude > maxAltitude) {
      maxAltitude = currentAltitude;
    }

    _currentFlightStatus = _createFlightStatusModel(
      _currentFlightStatus,
      currentAltitude: currentAltitude,
      maxAltitude: maxAltitude,
      groundSpeed: _getSensorValue(SensorType.speed),
      verticalSpeed: _getSensorValue(SensorType.verticalSpeed),
      fuelLevel: _getSensorValue(SensorType.fuelLevel),
      latitude: _getSensorValue(SensorType.gpsPosition),
      longitude: _getSensorValue(SensorType.gpsPosition, isSecondary: true),
    );

    // Faz otomatik geçişleri
    _checkPhaseTransitions();
  }

  void _checkPhaseTransitions() {
    // Eğer iniş aşamasında ve yükseklik 0'a yakınsa, uçuşu tamamla
    if (_currentFlightStatus.currentPhase == FlightPhase.landing &&
        _getSensorValue(SensorType.altitude) < 5.0) {
      _currentFlightStatus = _createFlightStatusModel(
        _currentFlightStatus,
        phase: FlightPhase.completed,
        endTime: DateTime.now(),
        currentAltitude: 0.0,
        groundSpeed: 0.0,
        verticalSpeed: 0.0,
      );

      // Simülasyonu durdur
      _simulationTimer?.cancel();
    }
  }

  void _checkForAlerts() {
    List<SensorType> checkedSensors = [];
    bool hasWarnings = false;
    bool hasCritical = false;

    // Her sensör için uyarı kontrolü yap
    for (var sensor in _sensorData) {
      final type = sensor.type;
      if (checkedSensors.contains(type)) continue;
      checkedSensors.add(type);

      AlertLevel newAlertLevel = AlertLevel.none;
      String alertMessage = '';

      switch (type) {
        case SensorType.altitude:
          final value = sensor.value;
          if (value > 2700) {
            newAlertLevel = AlertLevel.critical;
            alertMessage = 'Tehlikeli yükseklik! İzin verilen maksimum yüksekliğe yaklaşıldı.';
          } else if (value > 2400) {
            newAlertLevel = AlertLevel.warning;
            alertMessage = 'Yükseklik uyarısı: İzin verilen maksimum yüksekliğe yaklaşılıyor.';
          }
          break;

        case SensorType.temperature:
          final value = sensor.value;
          if (value > 110) {
            newAlertLevel = AlertLevel.critical;
            alertMessage = 'Tehlikeli sıcaklık! Balon kumaşı zarar görebilir.';
          } else if (value > 100) {
            newAlertLevel = AlertLevel.warning;
            alertMessage = 'Sıcaklık uyarısı: Maksimum güvenli sıcaklığa yaklaşılıyor.';
          }
          break;

        case SensorType.fuelLevel:
          final value = sensor.value;
          if (value < 10) {
            newAlertLevel = AlertLevel.critical;
            alertMessage = 'Kritik yakıt seviyesi! Acil iniş yapılmalı.';
          } else if (value < 20) {
            newAlertLevel = AlertLevel.warning;
            alertMessage = 'Düşük yakıt seviyesi: İniş hazırlıklarına başlanmalı.';
          }
          break;

        case SensorType.verticalSpeed:
          final value = sensor.value;
          if (value < -3.5) {
            newAlertLevel = AlertLevel.critical;
            alertMessage = 'Tehlikeli alçalma hızı! Düşüş kontrol edilmeli.';
          } else if (value < -2.5) {
            newAlertLevel = AlertLevel.warning;
            alertMessage = 'Yüksek alçalma hızı: Düşüş yavaşlatılmalı.';
          } else if (value > 3.5) {
            newAlertLevel = AlertLevel.critical;
            alertMessage = 'Tehlikeli yükselme hızı! Yükseliş kontrol edilmeli.';
          } else if (value > 2.5) {
            newAlertLevel = AlertLevel.warning;
            alertMessage = 'Yüksek yükselme hızı: Yükseliş yavaşlatılmalı.';
          }
          break;

        case SensorType.speed:
          final value = sensor.value;
          if (value > 45) {
            newAlertLevel = AlertLevel.critical;
            alertMessage = 'Tehlikeli hız! Maksimum güvenli hız aşılıyor.';
          } else if (value > 40) {
            newAlertLevel = AlertLevel.warning;
            alertMessage = 'Yüksek hız uyarısı: Maksimum güvenli hıza yaklaşılıyor.';
          }
          break;

        case SensorType.gpsPosition:
          final hasSignal = _currentFlightStatus.hasGPSSignal;
          if (!hasSignal) {
            newAlertLevel = AlertLevel.warning;
            alertMessage = 'GPS sinyali kaybedildi! Konum bilgisi doğrulanamıyor.';
          }
          break;

        default:
          break;
      }

      // Sensör uyarı durumunu güncelle
      if (newAlertLevel != sensor.alertLevel) {
        _updateSensorAlertLevel(type, newAlertLevel);

        // Eğer yeni bir uyarı oluştuysa, alerts listesine ekle
        if (newAlertLevel != AlertLevel.none) {
          _addAlert(
            title: '${_getSensorName(type)} Uyarısı',
            message: alertMessage,
            level: newAlertLevel,
            relatedSensorType: type,
          );
        }
      }

      // Uyarı bayraklarını güncelle
      if (newAlertLevel == AlertLevel.warning) hasWarnings = true;
      if (newAlertLevel == AlertLevel.critical) hasCritical = true;
    }

    // Uçuş durumunu güncelle
    _currentFlightStatus = _createFlightStatusModel(
      _currentFlightStatus,
      hasActiveWarnings: hasWarnings || hasCritical,
      hasActiveCriticalAlerts: hasCritical,
    );
  }

  void _addAlert({
    required String title,
    required String message,
    required AlertLevel level,
    SensorType? relatedSensorType,
  }) {
    final alertId = 'ALT-${DateTime.now().millisecondsSinceEpoch}';

    final alert = AlertModel(
      id: alertId,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      level: level,
      relatedSensorType: relatedSensorType,
    );

    _activeAlerts.add(alert);

    // En fazla 20 uyarı sakla
    if (_activeAlerts.length > 20) {
      _activeAlerts.removeAt(0);
    }
  }

  double _getSensorValue(SensorType type, {bool isSecondary = false}) {
    for (var sensor in _sensorData) {
      if (sensor.type == type) {
        return isSecondary && sensor.secondaryValue != null
            ? sensor.secondaryValue!
            : sensor.value;
      }
    }
    return 0.0;
  }

  void _updateSensor(SensorType type, double value, {double? secondaryValue}) {
    for (var i = 0; i < _sensorData.length; i++) {
      if (_sensorData[i].type == type) {
        _sensorData[i] = SensorDataModel(
          type: type,
          value: value,
          unit: _sensorData[i].unit,
          alertLevel: _sensorData[i].alertLevel,
          timestamp: DateTime.now(),
          minValue: _sensorData[i].minValue,
          maxValue: _sensorData[i].maxValue,
          secondaryValue: secondaryValue ?? _sensorData[i].secondaryValue,
        );
        break;
      }
    }
  }

  void _updateSensorAlertLevel(SensorType type, AlertLevel level) {
    for (var i = 0; i < _sensorData.length; i++) {
      if (_sensorData[i].type == type) {
        _sensorData[i] = SensorDataModel(
          type: type,
          value: _sensorData[i].value,
          unit: _sensorData[i].unit,
          alertLevel: level,
          timestamp: _sensorData[i].timestamp,
          minValue: _sensorData[i].minValue,
          maxValue: _sensorData[i].maxValue,
          secondaryValue: _sensorData[i].secondaryValue,
        );
        break;
      }
    }
  }

  String _getSensorName(SensorType type) {
    switch (type) {
      case SensorType.altitude:
        return 'Yükseklik';
      case SensorType.temperature:
        return 'Sıcaklık';
      case SensorType.pressure:
        return 'Basınç';
      case SensorType.direction:
        return 'Yön';
      case SensorType.speed:
        return 'Hız';
      case SensorType.fuelLevel:
        return 'Yakıt Seviyesi';
      case SensorType.verticalSpeed:
        return 'Dikey Hız';
      case SensorType.gpsPosition:
        return 'GPS Konumu';
    }
  }

  @override
  Future<FlightStatusModel> getFlightStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentFlightStatus;
  }

  @override
  Future<FlightStatusModel> updateFlightPhase(FlightPhase phase) async {
    await Future.delayed(const Duration(milliseconds: 500));

    _currentFlightStatus = _createFlightStatusModel(
      _currentFlightStatus,
      phase: phase,
    );

    return _currentFlightStatus;
  }

  @override
  Future<List<SensorDataModel>> getAllSensorData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _sensorData;
  }

  @override
  Future<SensorDataModel> getSensorData(SensorType type) async {
    await Future.delayed(const Duration(milliseconds: 200));

    for (var sensor in _sensorData) {
      if (sensor.type == type) {
        return sensor;
      }
    }

    throw Exception('Sensör bulunamadı: $type');
  }

  @override
  Future<List<AlertModel>> getActiveAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _activeAlerts;
  }

  @override
  Future<AlertModel> acknowledgeAlert(String alertId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    int index = _activeAlerts.indexWhere((alert) => alert.id == alertId);
    if (index == -1) {
      throw Exception('Uyarı bulunamadı: $alertId');
    }

    final alert = _activeAlerts[index];
    final updatedAlert = AlertModel(
      id: alert.id,
      title: alert.title,
      message: alert.message,
      timestamp: alert.timestamp,
      level: alert.level,
      relatedSensorType: alert.relatedSensorType,
      isAcknowledged: true,
      isResolved: alert.isResolved,
      acknowledgedAt: DateTime.now(),
      resolvedAt: alert.resolvedAt,
    );

    _activeAlerts[index] = updatedAlert;
    return updatedAlert;
  }

  @override
  Future<AlertModel> resolveAlert(String alertId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    int index = _activeAlerts.indexWhere((alert) => alert.id == alertId);
    if (index == -1) {
      throw Exception('Uyarı bulunamadı: $alertId');
    }

    final alert = _activeAlerts[index];
    final updatedAlert = AlertModel(
      id: alert.id,
      title: alert.title,
      message: alert.message,
      timestamp: alert.timestamp,
      level: alert.level,
      relatedSensorType: alert.relatedSensorType,
      isAcknowledged: true,
      isResolved: true,
      acknowledgedAt: alert.acknowledgedAt ?? DateTime.now(),
      resolvedAt: DateTime.now(),
    );

    _activeAlerts[index] = updatedAlert;
    return updatedAlert;
  }

  @override
  Future<FlightStatusModel> endFlight() async {
    await Future.delayed(const Duration(seconds: 1));

    _currentFlightStatus = _createFlightStatusModel(
      _currentFlightStatus,
      phase: FlightPhase.completed,
      endTime: DateTime.now(),
    );

    // Simülasyonu durdur
    _simulationTimer?.cancel();

    return _currentFlightStatus;
  }

  @override
  Future<FlightStatusModel> toggleEmergencyMode(bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 500));

    _currentFlightStatus = _createFlightStatusModel(
      _currentFlightStatus,
      isEmergencyMode: isActive,
    );

    return _currentFlightStatus;
  }

  @override
  Future<void> reportIssue({
    required String title,
    required String description,
    SensorType? relatedSensorType,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Sadece simülasyon, gerçek implementasyonda rapor kaydedilir
    print('Sorun raporu kaydedildi: $title');

    // İsteğe bağlı olarak bir uyarı eklenebilir
    _addAlert(
      title: 'Sorun Raporu: $title',
      message: description,
      level: AlertLevel.info,
      relatedSensorType: relatedSensorType,
    );
  }

  @override
  Stream<List<SensorDataModel>> observeSensorData() {
    return _sensorDataStreamController.stream;
  }

  @override
  Stream<FlightStatusModel> observeFlightStatus() {
    return _flightStatusStreamController.stream;
  }

  @override
  Stream<List<AlertModel>> observeAlerts() {
    return _alertsStreamController.stream;
  }
}