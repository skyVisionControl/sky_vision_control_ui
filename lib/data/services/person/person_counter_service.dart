import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../utils/id_generator.dart'; // Mevcut dosya import
import '../../models/person_count_violation_model.dart';
import '../flight/firebase_rtdb_service.dart';
import '../rtsp_snapshot_service.dart';
import 'person_detection_service.dart';
import '../firebase_violation_service.dart'; // Güncellenecek

class PersonCounterService extends ChangeNotifier {
  final String rtspUrl;
  final String captainId;
  final String flightId;

  late final RtspSnapshotService _snapshotService;
  late final PersonDetectionService _detectionService;
  late final FirebaseRtdbService _rtdbService;
  late final FirebaseViolationService _violationService;

  int? currentCount;
  double? currentConfidence;
  DateTime? lastDetectionTime;
  String? lastSnapshotPath;
  bool _isRunning = false;

  PersonCounterService({
    required this.rtspUrl,
    required this.captainId,
    required this.flightId,
    FirebaseRtdbService? rtdbService,
    FirebaseViolationService? violationService,
  }) : _rtdbService = rtdbService ?? FirebaseRtdbService(),
        _violationService = violationService ?? FirebaseViolationService();

  Future<void> init() async {
    _detectionService = PersonDetectionService();
    await _detectionService.loadModel();

    _snapshotService = RtspSnapshotService(
      rtspUrl: rtspUrl,
      captureInterval: const Duration(seconds: 5),
    );

    _snapshotService.startCapturing((imagePath) async {
      await _processImage(imagePath);
    });

    _isRunning = true;
    print('Person counter service initialized for flight: $flightId');
  }

  Future<void> _processImage(String imagePath) async {
    try {
      lastSnapshotPath = imagePath;
      // Değişiklik: detectPersons çağrısı aynı kalır (interface korundu)
      final result = await _detectionService.detectPersons(imagePath); // İçte face detection yapar
      currentCount = result['count'] as int?;
      currentConfidence = result['confidence'] as double?;
      lastDetectionTime = DateTime.now();

      if (currentCount != null) {
        notifyListeners();

        // RTDB güncelle (aynı)
        await _rtdbService.updatePersonCounter(captainId, currentCount!, currentConfidence!);

        // İhlal kontrolü (aynı)
        if (currentCount! > 12) {
          final violationId = generateViolationId(flightId, 'personCount');
          final violation = PersonCountViolationModel(
            detectionType: 'personCount',
            headCount: currentCount!,
            confidence: currentConfidence ?? 0.0,
            flightId: flightId,
            id: violationId,
            timeStamp: lastDetectionTime!,
            violationUrl: null,
          );
          await _violationService.saveViolation(violation.toJson());
          print('Person count violation saved: $violationId');
        }
      }
    } catch (e) {
      print('Error processing image for person count: $e');
      // Hata durumunda varsayılan 0 güncelle (opsiyonel)
      await _rtdbService.updatePersonCounter(captainId, 0, 0.0);
    }
  }

  Future<void> stop() async {
    _snapshotService.stopCapturing();
    _isRunning = false;
    print('Person counter service stopped');
  }

  @override
  void dispose() {
    _detectionService.dispose();
    _snapshotService.dispose();
    super.dispose();
  }

  bool get isRunning => _isRunning;
}