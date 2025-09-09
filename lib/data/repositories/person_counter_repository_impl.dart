import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/person_counter_repository.dart';
import '../../domain/entities/person_count.dart'; // fromJson için
import '../services/flight/firebase_rtdb_service.dart';
import '../services/person/person_counter_service.dart';
import '../services/firebase_violation_service.dart';

class PersonCounterRepositoryImpl implements PersonCounterRepository {
  PersonCounterService? _service;
  final FirebaseRtdbService _rtdbService;
  final FirebaseViolationService _violationService;
  final String captainId; // Yeni: captainId field

  PersonCounterRepositoryImpl({
    required this.captainId, // Constructor'a ekle
    FirebaseRtdbService? rtdbService,
    FirebaseViolationService? violationService,
  }) : _rtdbService = rtdbService ?? FirebaseRtdbService(),
        _violationService = violationService ?? FirebaseViolationService();

  @override
  Future<void> startPersonCounting(String flightId, String rtspUrl) async { // captainId constructor'dan
    _service = PersonCounterService(
      rtspUrl: rtspUrl,
      captainId: captainId,
      flightId: flightId,
      rtdbService: _rtdbService,
      violationService: _violationService,
    );
    await _service!.init();
  }

  @override
  Future<void> stopPersonCounting() async {
    await _service?.stop();
    _service?.dispose();
    _service = null;
  }

  @override
  Stream<PersonCount?> observePersonCount() {
    // captainId constructor'dan kullan
    return _rtdbService.observePersonCounter(captainId);
  }
}