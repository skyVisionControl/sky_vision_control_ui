// sensor_data.dart
//
// Sensör verilerini tanımlayan domain katmanı sınıfı.
// Balon uçuşu sırasında toplanan sensör verilerini içerir.

import 'package:equatable/equatable.dart';

class SensorData extends Equatable {
  final String id;
  final String flightId;
  final DateTime timestamp;
  final double altitude;      // metre
  final double speed;         // km/h
  final double temperature;   // Celsius
  final double humidity;      // Yüzde
  final double direction;     // Derece (0-360)
  final double latitude;      // GPS koordinatı
  final double longitude;     // GPS koordinatı
  final double acceleration;  // m/s²
  final bool isWarning;       // Herhangi bir değer uyarı eşiğinde mi?
  final List<String> warnings; // Uyarı mesajları

  const SensorData({
    required this.id,
    required this.flightId,
    required this.timestamp,
    required this.altitude,
    required this.speed,
    required this.temperature,
    required this.humidity,
    required this.direction,
    required this.latitude,
    required this.longitude,
    required this.acceleration,
    this.isWarning = false,
    this.warnings = const [],
  });

  @override
  List<Object?> get props => [
    id, flightId, timestamp, altitude, speed, temperature,
    humidity, direction, latitude, longitude, acceleration,
    isWarning, warnings
  ];

  String get coordinates => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  String get directionAsCardinal {
    const List<String> cardinals = ['K', 'KD', 'D', 'GD', 'G', 'GB', 'B', 'KB'];
    return cardinals[(((direction + 22.5) % 360) / 45).floor()];
  }
}