// alert_model.dart
//
// Alert entity'sinin data layer modeli.

import 'package:kapadokya_balon_app/domain/entities/alert.dart';
import 'package:kapadokya_balon_app/domain/entities/flight/sensor_data.dart';

class AlertModel extends Alert {
  const AlertModel({
    required String id,
    required String title,
    required String message,
    required DateTime timestamp,
    required AlertLevel level,
    SensorType? relatedSensorType,
    bool isAcknowledged = false,
    bool isResolved = false,
    DateTime? acknowledgedAt,
    DateTime? resolvedAt,
  }) : super(
    id: id,
    title: title,
    message: message,
    timestamp: timestamp,
    level: level,
    relatedSensorType: relatedSensorType,
    isAcknowledged: isAcknowledged,
    isResolved: isResolved,
    acknowledgedAt: acknowledgedAt,
    resolvedAt: resolvedAt,
  );

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: _parseAlertLevel(json['level']),
      relatedSensorType: _parseSensorType(json['relatedSensorType']),
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      isResolved: json['isResolved'] as bool? ?? false,
      acknowledgedAt: json['acknowledgedAt'] != null ?
      DateTime.parse(json['acknowledgedAt'] as String) : null,
      resolvedAt: json['resolvedAt'] != null ?
      DateTime.parse(json['resolvedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'level': level.toString().split('.').last,
      'relatedSensorType': relatedSensorType?.toString().split('.').last,
      'isAcknowledged': isAcknowledged,
      'isResolved': isResolved,
      'acknowledgedAt': acknowledgedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  static AlertLevel _parseAlertLevel(dynamic value) {
    if (value == null) return AlertLevel.info;

    if (value is String) {
      for (var level in AlertLevel.values) {
        if (level.toString().split('.').last.toLowerCase() == value.toLowerCase()) {
          return level;
        }
      }
    }

    return AlertLevel.info;
  }

  static SensorType? _parseSensorType(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      for (var type in SensorType.values) {
        if (type.toString().split('.').last.toLowerCase() == value.toLowerCase()) {
          return type;
        }
      }
    }

    return null;
  }
}