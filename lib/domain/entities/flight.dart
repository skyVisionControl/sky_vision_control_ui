// flight.dart
//
// Uçuş varlığını tanımlayan domain katmanı sınıfı.
// Bir balonun uçuşu ile ilgili bilgileri içerir.

import 'package:equatable/equatable.dart';

enum FlightStatus {
  pending,     // Onay bekliyor
  approved,    // Onaylandı
  rejected,    // Reddedildi
  inProgress,  // Devam ediyor
  completed,   // Tamamlandı
  cancelled    // İptal edildi
}

class Flight extends Equatable {
  final String id;
  final String pilotId;
  final String balloonId;
  final DateTime scheduledDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final FlightStatus status;
  final String? rejectionReason;
  final bool hasIncident;
  final String? incidentReport;
  final String? weatherConditions;
  final int passengerCount;
  final String route;

  const Flight({
    required this.id,
    required this.pilotId,
    required this.balloonId,
    required this.scheduledDate,
    this.startTime,
    this.endTime,
    required this.status,
    this.rejectionReason,
    this.hasIncident = false,
    this.incidentReport,
    this.weatherConditions,
    required this.passengerCount,
    required this.route,
  });

  bool get isActive => status == FlightStatus.inProgress;
  bool get isPending => status == FlightStatus.pending;
  bool get isApproved => status == FlightStatus.approved;
  bool get isRejected => status == FlightStatus.rejected;
  bool get isCompleted => status == FlightStatus.completed;
  bool get isCancelled => status == FlightStatus.cancelled;

  Duration? get flightDuration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id, pilotId, balloonId, scheduledDate, startTime, endTime, status,
    rejectionReason, hasIncident, incidentReport, weatherConditions,
    passengerCount, route
  ];
}