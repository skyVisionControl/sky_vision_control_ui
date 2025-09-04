// lib/data/datasources/flight_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kapadokya_balon_app/domain/entities/alert.dart';
import 'package:kapadokya_balon_app/domain/entities/flight/flight_status.dart';
import 'package:kapadokya_balon_app/domain/entities/flight/sensor_data.dart';
import '../models/flight_status_model.dart';

abstract class FlightDataSource {
  Future<FlightStatus> getFlightStatus();
  Stream<FlightStatus> observeFlightStatus();
  Future<FlightStatus> updateFlightPhase(FlightPhase phase);
  Future<FlightStatus> endFlight();
  Future<FlightStatus> toggleEmergencyMode(bool isActive);

  Future<List<Alert>> getActiveAlerts();
  Stream<List<Alert>> observeAlerts();
  Future<Alert> acknowledgeAlert(String alertId);
  Future<Alert> resolveAlert(String alertId);

  Future<void> reportIssue({
    required String title,
    required String description,
    SensorType? relatedSensorType,
  });

  // Sensörler (opsiyonel — SensorRepository aslında kullanıyor)
  Future<List<SensorData>> getAllSensorData();
  Future<SensorData> getSensorData(SensorType type);
  Stream<List<SensorData>> observeSensorData();
}

class FirestoreFlightDataSource implements FlightDataSource {
  final FirebaseFirestore _firestore;
  final String _flightId;

  FirestoreFlightDataSource(this._firestore, this._flightId);

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection('flights').doc(_flightId);

  @override
  Future<FlightStatus> getFlightStatus() async {
    final snap = await _doc.get();
    if (!snap.exists) {
      throw StateError('Flight not found: $_flightId');
    }
    return FlightStatusModel.fromFirestore(snap);
  }

  @override
  Stream<FlightStatus> observeFlightStatus() {
    return _doc.snapshots().map((snap) => FlightStatusModel.fromFirestore(snap));
  }

  @override
  Future<FlightStatus> updateFlightPhase(FlightPhase phase) async {
    await _doc.update({
      'currentPhase': phase.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return getFlightStatus();
  }

  @override
  Future<FlightStatus> endFlight() async {
    await _doc.update({
      'endTime': FieldValue.serverTimestamp(),
      'flightStatus': 'completed',
      'currentPhase': 'completed',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return getFlightStatus();
  }

  @override
  Future<FlightStatus> toggleEmergencyMode(bool isActive) async {
    await _doc.update({
      'isEmergencyMode': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return getFlightStatus();
  }

  // --- Alerts (basit örnek) ---

  @override
  Future<List<Alert>> getActiveAlerts() async {
    // Projene göre burada gerçek mapping yap.
    // Şimdilik boş liste döndürelim.
    return <Alert>[];
  }

  @override
  Stream<List<Alert>> observeAlerts() {
    // Şimdilik boş stream
    return const Stream<List<Alert>>.empty();
  }

  @override
  Future<Alert> acknowledgeAlert(String alertId) async {
    // İstersen flights/{id}/alerts alt koleksiyonunda status güncelle.
    throw UnimplementedError('acknowledgeAlert not implemented');
  }

  @override
  Future<Alert> resolveAlert(String alertId) async {
    throw UnimplementedError('resolveAlert not implemented');
  }

  @override
  Future<void> reportIssue({
    required String title,
    required String description,
    SensorType? relatedSensorType,
  }) async {
    await _doc.collection('issues').add({
      'title': title,
      'description': description,
      'relatedSensorType': relatedSensorType?.toString().split('.').last,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Sensörler (FlightRepository üzerinden kullanmıyoruz) ---
  // Sensor akışını ayrı SensorRepository üzerinden hallediyorsun.
  @override
  Future<List<SensorData>> getAllSensorData() async {
    throw UnimplementedError('Use SensorRepository for sensor data');
  }

  @override
  Future<SensorData> getSensorData(SensorType type) async {
    throw UnimplementedError('Use SensorRepository for sensor data');
  }

  @override
  Stream<List<SensorData>> observeSensorData() {
    throw UnimplementedError('Use SensorRepository for sensor data');
  }
}
