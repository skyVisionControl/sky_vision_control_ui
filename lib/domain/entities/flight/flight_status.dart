// flight_status.dart
//
// Mevcut uçuş durumunu temsil eden entity.

import 'package:equatable/equatable.dart';

enum FlightPhase {
  preparation,  // Hazırlık
  inflation,    // Şişirme
  takeoff,      // Kalkış
  climbing,     // Yükseliş
  cruising,     // Seyir
  descending,   // Alçalma
  landing,      // İniş
  completed     // Tamamlandı
}

class FlightStatus extends Equatable {
  final String flightId;
  final DateTime startTime;
  final DateTime? endTime;
  final FlightPhase currentPhase;
  final double maxAltitude;
  final double currentAltitude;
  final double groundSpeed;
  final double verticalSpeed;
  final double fuelLevel;
  final bool hasActiveWarnings;
  final bool hasActiveCriticalAlerts;
  final bool isEmergencyMode;
  final double latitude;
  final double longitude;
  final bool hasGPSSignal;
  final Map<String, dynamic>? telemetry;

  const FlightStatus({
    required this.flightId,
    required this.startTime,
    this.endTime,
    required this.currentPhase,
    this.maxAltitude = 0.0,
    this.currentAltitude = 0.0,
    this.groundSpeed = 0.0,
    this.verticalSpeed = 0.0,
    this.fuelLevel = 100.0,
    this.hasActiveWarnings = false,
    this.hasActiveCriticalAlerts = false,
    this.isEmergencyMode = false,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.hasGPSSignal = true,
    this.telemetry,
  });

  bool get isFlightActive => endTime == null;

  Duration get flightDuration =>
      endTime != null ? endTime!.difference(startTime) : DateTime.now().difference(startTime);

  FlightStatus copyWith({
    String? flightId,
    DateTime? startTime,
    DateTime? endTime,
    FlightPhase? currentPhase,
    double? maxAltitude,
    double? currentAltitude,
    double? groundSpeed,
    double? verticalSpeed,
    double? fuelLevel,
    bool? hasActiveWarnings,
    bool? hasActiveCriticalAlerts,
    bool? isEmergencyMode,
    double? latitude,
    double? longitude,
    bool? hasGPSSignal,
    Map<String, dynamic>? telemetry,
  }) {
    return FlightStatus(
      flightId: flightId ?? this.flightId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      currentPhase: currentPhase ?? this.currentPhase,
      maxAltitude: maxAltitude ?? this.maxAltitude,
      currentAltitude: currentAltitude ?? this.currentAltitude,
      groundSpeed: groundSpeed ?? this.groundSpeed,
      verticalSpeed: verticalSpeed ?? this.verticalSpeed,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      hasActiveWarnings: hasActiveWarnings ?? this.hasActiveWarnings,
      hasActiveCriticalAlerts: hasActiveCriticalAlerts ?? this.hasActiveCriticalAlerts,
      isEmergencyMode: isEmergencyMode ?? this.isEmergencyMode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      hasGPSSignal: hasGPSSignal ?? this.hasGPSSignal,
      telemetry: telemetry ?? this.telemetry,
    );
  }

  @override
  List<Object?> get props => [
    flightId, startTime, endTime, currentPhase, maxAltitude, currentAltitude,
    groundSpeed, verticalSpeed, fuelLevel, hasActiveWarnings,
    hasActiveCriticalAlerts, isEmergencyMode, latitude, longitude, hasGPSSignal, telemetry
  ];
}