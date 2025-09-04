// flight_repository_impl.dart
//
// FlightRepository arayüzünün implementasyonu.

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/core/utils/logger.dart';
import 'package:kapadokya_balon_app/data/datasources/flight_data_source.dart';
import 'package:kapadokya_balon_app/domain/entities/alert.dart';
import 'package:kapadokya_balon_app/domain/entities/flight/flight_status.dart';
import 'package:kapadokya_balon_app/domain/entities/flight/sensor_data.dart';
import 'package:kapadokya_balon_app/domain/repositories/flight_repository.dart';

class FlightRepositoryImpl implements FlightRepository {
  final FlightDataSource dataSource;

  FlightRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, FlightStatus>> getFlightStatus() async {
    try {
      final result = await dataSource.getFlightStatus();
      return Right(result);
    } catch (e) {
      AppLogger.e('Uçuş durumu alınamadı: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlightStatus>> updateFlightPhase(FlightPhase phase) async {
    try {
      final result = await dataSource.updateFlightPhase(phase);
      return Right(result);
    } catch (e) {
      AppLogger.e('Uçuş evresi güncellenemedi: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SensorData>>> getAllSensorData() async {
    try {
      final result = await dataSource.getAllSensorData();
      return Right(result);
    } catch (e) {
      AppLogger.e('Sensör verileri alınamadı: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SensorData>> getSensorData(SensorType type) async {
    try {
      final result = await dataSource.getSensorData(type);
      return Right(result);
    } catch (e) {
      AppLogger.e('Sensör verisi alınamadı: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Alert>>> getActiveAlerts() async {
    try {
      final result = await dataSource.getActiveAlerts();
      return Right(result);
    } catch (e) {
      AppLogger.e('Aktif uyarılar alınamadı: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Alert>> acknowledgeAlert(String alertId) async {
    try {
      final result = await dataSource.acknowledgeAlert(alertId);
      return Right(result);
    } catch (e) {
      AppLogger.e('Uyarı onaylanamadı: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Alert>> resolveAlert(String alertId) async {
    try {
      final result = await dataSource.resolveAlert(alertId);
      return Right(result);
    } catch (e) {
      AppLogger.e('Uyarı çözülemedi: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlightStatus>> endFlight() async {
    try {
      final result = await dataSource.endFlight();
      return Right(result);
    } catch (e) {
      AppLogger.e('Uçuş sonlandırılamadı: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlightStatus>> toggleEmergencyMode(bool isActive) async {
    try {
      final result = await dataSource.toggleEmergencyMode(isActive);
      return Right(result);
    } catch (e) {
      AppLogger.e('Acil durum modu değiştirilemedi: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reportIssue({
    required String title,
    required String description,
    SensorType? relatedSensorType,
  }) async {
    try {
      await dataSource.reportIssue(
        title: title,
        description: description,
        relatedSensorType: relatedSensorType,
      );
      return const Right(null);
    } catch (e) {
      AppLogger.e('Sorun bildirimi yapılamadı: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<SensorData>> observeSensorData() {
    return dataSource.observeSensorData();
  }

  @override
  Stream<FlightStatus> observeFlightStatus() {
    return dataSource.observeFlightStatus();
  }

  @override
  Stream<List<Alert>> observeAlerts() {
    return dataSource.observeAlerts();
  }
}