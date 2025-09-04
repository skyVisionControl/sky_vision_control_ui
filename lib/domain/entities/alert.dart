// alert.dart
//
// Uçuş sırasında oluşan uyarı ve alarmları temsil eden entity.

import 'package:equatable/equatable.dart';
import 'package:kapadokya_balon_app/domain/entities/flight/sensor_data.dart';

class Alert extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final AlertLevel level;
  final SensorType? relatedSensorType;
  final bool isAcknowledged;
  final bool isResolved;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;

  const Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.level,
    this.relatedSensorType,
    this.isAcknowledged = false,
    this.isResolved = false,
    this.acknowledgedAt,
    this.resolvedAt,
  });

  Alert copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    AlertLevel? level,
    SensorType? relatedSensorType,
    bool? isAcknowledged,
    bool? isResolved,
    DateTime? acknowledgedAt,
    DateTime? resolvedAt,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      level: level ?? this.level,
      relatedSensorType: relatedSensorType ?? this.relatedSensorType,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      isResolved: isResolved ?? this.isResolved,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, title, message, timestamp, level, relatedSensorType,
    isAcknowledged, isResolved, acknowledgedAt, resolvedAt
  ];
}