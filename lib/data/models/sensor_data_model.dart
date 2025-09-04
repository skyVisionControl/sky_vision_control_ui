// sensor_data_model.dart
//
// SensorData entity'sinin data layer modeli.

import 'package:kapadokya_balon_app/domain/entities/flight/sensor_data.dart';

class SensorDataModel extends SensorData {
  const SensorDataModel({
    required SensorType type,
    required double value,
    required String unit,
    AlertLevel alertLevel = AlertLevel.none,
    required DateTime timestamp,
    required double minValue,
    required double maxValue,
    double? secondaryValue,
  }) : super(
    type: type,
    value: value,
    unit: unit,
    alertLevel: alertLevel,
    timestamp: timestamp,
    minValue: minValue,
    maxValue: maxValue,
    secondaryValue: secondaryValue,
  );

  factory SensorDataModel.fromJson(Map<String, dynamic> json) {
    return SensorDataModel(
      type: _parseSensorType(json['type']),
      value: json['value'] as double? ?? 0.0,
      unit: json['unit'] as String? ?? '',
      alertLevel: _parseAlertLevel(json['alertLevel']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      minValue: json['minValue'] as double? ?? 0.0,
      maxValue: json['maxValue'] as double? ?? 100.0,
      secondaryValue: json['secondaryValue'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'value': value,
      'unit': unit,
      'alertLevel': alertLevel.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'minValue': minValue,
      'maxValue': maxValue,
      'secondaryValue': secondaryValue,
    };
  }

  static SensorType _parseSensorType(dynamic value) {
    if (value == null) return SensorType.altitude;

    if (value is String) {
      for (var type in SensorType.values) {
        if (type.toString().split('.').last.toLowerCase() == value.toLowerCase()) {
          return type;
        }
      }
    }

    return SensorType.altitude;
  }

  static AlertLevel _parseAlertLevel(dynamic value) {
    if (value == null) return AlertLevel.none;

    if (value is String) {
      for (var level in AlertLevel.values) {
        if (level.toString().split('.').last.toLowerCase() == value.toLowerCase()) {
          return level;
        }
      }
    }

    return AlertLevel.none;
  }
}