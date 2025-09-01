// lib/data/models/flight_status_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Timestamp için
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
    Map<String, dynamic>? telemetry,
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
      telemetry: telemetry
  );

  factory FlightStatusModel.fromJson(Map<String, dynamic> json) {
    return FlightStatusModel(
      flightId: json['flightId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      currentPhase: _parseFlightPhase(json['currentPhase']),
      maxAltitude: _toDouble(json['maxAltitude']),
      currentAltitude: _toDouble(json['currentAltitude']),
      groundSpeed: _toDouble(json['groundSpeed']),
      verticalSpeed: _toDouble(json['verticalSpeed']),
      fuelLevel: _toDouble(json['fuelLevel'], 100.0),
      hasActiveWarnings: json['hasActiveWarnings'] as bool? ?? false,
      hasActiveCriticalAlerts: json['hasActiveCriticalAlerts'] as bool? ?? false,
      isEmergencyMode: json['isEmergencyMode'] as bool? ?? false,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      hasGPSSignal: json['hasGPSSignal'] as bool? ?? true,
    );
  }

  /// ✅ Firestore dokümanından güvenli parse
  factory FlightStatusModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    DateTime _ts(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) {
        try { return DateTime.parse(v); } catch (_) {}
      }
      return DateTime.now();
    }

    return FlightStatusModel(
      flightId: (data['id'] ?? doc.id) as String,
      startTime: data['startTime'] != null ? _ts(data['startTime']) : _ts(data['createdAt']),
      endTime: data['endTime'] != null ? _ts(data['endTime']) : null,
      currentPhase: _parseFlightPhase(data['currentPhase']),
      maxAltitude: _toDouble(data['maxAltitude']),
      currentAltitude: _toDouble(data['currentAltitude']),
      groundSpeed: _toDouble(data['groundSpeed']),
      verticalSpeed: _toDouble(data['verticalSpeed']),
      fuelLevel: _toDouble(data['fuelLevel'], 100.0),
      hasActiveWarnings: data['hasActiveWarnings'] as bool? ?? false,
      hasActiveCriticalAlerts: data['hasActiveCriticalAlerts'] as bool? ?? false,
      isEmergencyMode: data['isEmergencyMode'] as bool? ?? false,
      latitude: _toDouble(data['latitude']),
      longitude: _toDouble(data['longitude']),
      hasGPSSignal: data['hasGPSSignal'] as bool? ?? true,
      telemetry: data['telemetry'] as Map<String, dynamic>?,
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
      'telemetry': telemetry,
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

  static double _toDouble(dynamic v, [double def = 0.0]) {
    if (v == null) return def;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? def;
    return def;
  }
}
