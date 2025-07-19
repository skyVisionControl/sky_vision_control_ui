// flight_status_model.dart
//
// FlightStatus entity'sinin data layer modeli.

import 'package:kapadokya_balon_app/domain/entities/flight_status.dart';

class FlightStatusModel extends FlightStatus {
  const FlightStatusModel({
    required String flightId,
    required DateTime startTime,
    DateTime? endTime,
    required FlightPhase currentPhase,
    double maxAltitude = 0.0,
    double currentAltitude = 0.0,
    double groundSpeed = 0.0,
    double verticalSpeed = 0.0,
    double fuelLevel = 100.0,
    bool hasActiveWarnings = false,
    bool hasActiveCriticalAlerts = false,
    bool isEmergencyMode = false,
    double latitude = 0.0,
    double longitude = 0.0,
    bool hasGPSSignal = true,
  }) : super(
    flightId: flightId,
    startTime: startTime,
    endTime: endTime,
    currentPhase: currentPhase,
    maxAltitude: maxAltitude,
    currentAltitude: currentAltitude,
    groundSpeed: groundSpeed,
    verticalSpeed: verticalSpeed,
    fuelLevel: fuelLevel,
    hasActiveWarnings: hasActiveWarnings,
    hasActiveCriticalAlerts: hasActiveCriticalAlerts,
    isEmergencyMode: isEmergencyMode,
    latitude: latitude,
    longitude: longitude,
    hasGPSSignal: hasGPSSignal,
  );

  factory FlightStatusModel.fromJson(Map<String, dynamic> json) {
    return FlightStatusModel(
      flightId: json['flightId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      currentPhase: _parseFlightPhase(json['currentPhase']),
      maxAltitude: json['maxAltitude'] as double? ?? 0.0,
      currentAltitude: json['currentAltitude'] as double? ?? 0.0,
      groundSpeed: json['groundSpeed'] as double? ?? 0.0,
      verticalSpeed: json['verticalSpeed'] as double? ?? 0.0,
      fuelLevel: json['fuelLevel'] as double? ?? 100.0,
      hasActiveWarnings: json['hasActiveWarnings'] as bool? ?? false,
      hasActiveCriticalAlerts: json['hasActiveCriticalAlerts'] as bool? ?? false,
      isEmergencyMode: json['isEmergencyMode'] as bool? ?? false,
      latitude: json['latitude'] as double? ?? 0.0,
      longitude: json['longitude'] as double? ?? 0.0,
      hasGPSSignal: json['hasGPSSignal'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flightId': flightId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'currentPhase': currentPhase.toString().split('.').last,
      'maxAltitude': maxAltitude,
      'currentAltitude': currentAltitude,
      'groundSpeed': groundSpeed,
      'verticalSpeed': verticalSpeed,
      'fuelLevel': fuelLevel,
      'hasActiveWarnings': hasActiveWarnings,
      'hasActiveCriticalAlerts': hasActiveCriticalAlerts,
      'isEmergencyMode': isEmergencyMode,
      'latitude': latitude,
      'longitude': longitude,
      'hasGPSSignal': hasGPSSignal,
    };
  }

  static FlightPhase _parseFlightPhase(dynamic value) {
    if (value == null) return FlightPhase.preparation;

    if (value is String) {
      for (var phase in FlightPhase.values) {
        if (phase.toString().split('.').last.toLowerCase() == value.toLowerCase()) {
          return phase;
        }
      }
    }

    return FlightPhase.preparation;
  }
}