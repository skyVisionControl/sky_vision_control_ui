// sensor_data.dart
//
// Balon sensörlerinden gelen verileri temsil eden entity.

import 'package:equatable/equatable.dart';

enum SensorType {
  altitude,
  temperature,
  pressure,
  direction,
  speed,
  fuelLevel,
  verticalSpeed,
  gpsPosition
}

enum AlertLevel {
  none,
  info,
  warning,
  critical
}

class SensorData extends Equatable {
  final SensorType type;
  final double value;
  final String unit;
  final AlertLevel alertLevel;
  final DateTime timestamp;
  final double minValue;
  final double maxValue;
  final double? secondaryValue; // Örneğin, GPS için enlem/boylam ikinci değer olabilir

  const SensorData({
    required this.type,
    required this.value,
    required this.unit,
    this.alertLevel = AlertLevel.none,
    required this.timestamp,
    required this.minValue,
    required this.maxValue,
    this.secondaryValue,
  });

  bool get isInAlertState => alertLevel != AlertLevel.none;

  bool get isInWarningState =>
      alertLevel == AlertLevel.warning || alertLevel == AlertLevel.critical;

  bool get isInCriticalState => alertLevel == AlertLevel.critical;

  @override
  List<Object?> get props => [
    type, value, unit, alertLevel, timestamp, minValue, maxValue, secondaryValue
  ];
}