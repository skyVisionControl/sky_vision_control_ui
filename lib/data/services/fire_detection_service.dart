import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'rtsp_snapshot_service.dart';
import 'yolo_detection_service.dart';
import 'firebase_violation_service.dart';

/// Yangın algılama için ana servis sınıfı
class FireDetectionService {
  final RtspSnapshotService _rtspService;
  final YoloDetectionService _yoloService;
  final FirebaseViolationService _violationService;

  String? _currentFlightId;
  bool _isRunning = false;

  final Duration _cooldownPeriod = const Duration(minutes: 1);
  DateTime? _lastDetectionTime;

  FireDetectionService({
    required RtspSnapshotService rtspService,
    required YoloDetectionService yoloService,
    required FirebaseViolationService violationService,
  })  : _rtspService = rtspService,
        _yoloService = yoloService,
        _violationService = violationService;

  Future<void> startDetection(String flightId) async {
    if (_isRunning) {
      print('⚠️ Fire detection service is already running');
      return;
    }

    _currentFlightId = flightId;
    _isRunning = true;

    print('🚀 Starting fire detection service for flight: $flightId');

    try {
      await _yoloService.load();

      await _rtspService.startCapturing((imagePath) {
        _processImage(imagePath);
      });
    } catch (e) {
      print('❌ Error starting fire detection service: $e');
      _isRunning = false;
    }
  }

  Future<void> _processImage(String imagePath) async {
    if (!_isRunning || _currentFlightId == null) return;

    try {
      print('📸 Processing snapshot: $imagePath');

      final detections = await _yoloService.detectFile(
        File(imagePath),
        confThreshold: 0.25,
      );

      print('🔍 YOLO detections: $detections');

      final fireDetections = detections.where((d) =>
      d.label.toLowerCase() == 'fire' || d.label.toLowerCase() == 'smoke').toList();

      if (fireDetections.isEmpty) {
        print('❎ No fire/smoke detected in this frame.');
        if (await File(imagePath).exists()) {
          await File(imagePath).delete();
        }
        return;
      }

      final now = DateTime.now();
      if (_lastDetectionTime != null &&
          now.difference(_lastDetectionTime!) < _cooldownPeriod) {
        print('⏳ Cooldown active. Skipping duplicate detection.');
        if (await File(imagePath).exists()) {
          await File(imagePath).delete();
        }
        return;
      }

      fireDetections.sort((a, b) => b.confidence.compareTo(a.confidence));
      final bestDetection = fireDetections.first;

      print('🔥 FIRE DETECTED: ${bestDetection.label} '
          '(${(bestDetection.confidence * 100).toStringAsFixed(2)}%)');

      await _violationService.logFireDetection(
        flightId: _currentFlightId!,
        confidence: bestDetection.confidence,
        detectionType: bestDetection.label.toLowerCase(),
        imageUrl: null, // buraya Firebase Storage linki eklenebilir
      );

      _lastDetectionTime = now;
    } catch (e) {
      print('❌ Error processing image for fire detection: $e');
    } finally {
      if (await File(imagePath).exists()) {
        await File(imagePath).delete();
      }
    }
  }

  void stopDetection() {
    if (!_isRunning) return;

    _rtspService.stopCapturing();
    _currentFlightId = null;
    _isRunning = false;

    print('🛑 Fire detection service stopped');
  }

  void dispose() {
    stopDetection();
    _rtspService.dispose();
  }

  bool get isRunning => _isRunning;
}
