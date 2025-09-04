// flight_repository.dart
//
// Uçuş durumu ve sensör verilerini yöneten repository arayüzü.

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/entities/alert.dart';
import 'package:kapadokya_balon_app/domain/entities/flight/flight_status.dart';
import 'package:kapadokya_balon_app/domain/entities/flight/sensor_data.dart';

abstract class FlightRepository {
  /// Mevcut uçuş durumunu getirir
  Future<Either<Failure, FlightStatus>> getFlightStatus();

  /// Uçuş evresini günceller
  Future<Either<Failure, FlightStatus>> updateFlightPhase(FlightPhase phase);

  /// Tüm sensör verilerini getirir
  Future<Either<Failure, List<SensorData>>> getAllSensorData();

  /// Belirli bir sensörün verilerini getirir
  Future<Either<Failure, SensorData>> getSensorData(SensorType type);

  /// Aktif uyarıları getirir
  Future<Either<Failure, List<Alert>>> getActiveAlerts();

  /// Uyarıyı görüldü olarak işaretler
  Future<Either<Failure, Alert>> acknowledgeAlert(String alertId);

  /// Uyarıyı çözüldü olarak işaretler
  Future<Either<Failure, Alert>> resolveAlert(String alertId);

  /// Uçuşu sonlandırır
  Future<Either<Failure, FlightStatus>> endFlight();

  /// Acil durum modunu etkinleştirir/devre dışı bırakır
  Future<Either<Failure, FlightStatus>> toggleEmergencyMode(bool isActive);

  /// Sorun bildirimi yapar
  Future<Either<Failure, void>> reportIssue({
    required String title,
    required String description,
    SensorType? relatedSensorType,
  });

  /// Sensör verilerinin akışını izler
  Stream<List<SensorData>> observeSensorData();

  /// Uçuş durumunun akışını izler
  Stream<FlightStatus> observeFlightStatus();

  /// Uyarıların akışını izler
  Stream<List<Alert>> observeAlerts();
}