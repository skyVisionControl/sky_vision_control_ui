import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'rtsp_service.dart';
import 'yolo_detection_service.dart';
import 'firebase_violation_service.dart';

/// Yangın algılama için ana servis sınıfı
class FireDetectionService {
  final RtspService _rtspService;
  final YoloDetectionService _yoloService;
  final FirebaseViolationService _violationService;

  String? _currentFlightId;
  bool _isRunning = false;

  // Algılamalar arasında geçen minimum süre (spam önleme)
  final Duration _cooldownPeriod = const Duration(minutes: 1);
  DateTime? _lastDetectionTime;

  FireDetectionService({
    required RtspService rtspService,
    required YoloDetectionService yoloService,
    required FirebaseViolationService violationService,
  })  : _rtspService = rtspService,
        _yoloService = yoloService,
        _violationService = violationService;

  /// Yangın algılama servisini başlat
  Future<void> startDetection(String flightId) async {
    if (_isRunning) {
      print('Fire detection service is already running');
      return;
    }

    _currentFlightId = flightId;
    _isRunning = true;

    print('Starting fire detection service for flight: $flightId');

    try {
      // YOLO modelini yükle
      await _yoloService.load();

      // RTSP yakalamayı başlat
      await _rtspService.startCapturing((imagePath) {
        _processImage(imagePath);
      });

    } catch (e) {
      print('Error starting fire detection service: $e');
      _isRunning = false;
    }
  }

  /// Yakalanan görüntüyü işle
  Future<void> _processImage(String imagePath) async {
    if (!_isRunning || _currentFlightId == null) return;

    try {
      // Görüntüde yangın/duman tespit et
      final detections = await _yoloService.detectFile(File(imagePath), confThreshold: 0.25);

      // Sadece yangın/duman tespitlerini filtrele
      final fireDetections = detections.where((d) =>
      d.label.toLowerCase() == 'fire' || d.label.toLowerCase() == 'smoke'
      ).toList();

      if (fireDetections.isEmpty) {
        // Yangın/duman tespit edilmedi
        return;
      }

      // Cooldown kontrol - son tespitle şimdiki tespit arasında yeterli süre geçti mi?
      final now = DateTime.now();
      if (_lastDetectionTime != null &&
          now.difference(_lastDetectionTime!) < _cooldownPeriod) {
        print('Cooldown period active. Skipping duplicate detection.');
        return;
      }

      // En yüksek güven skoruna sahip tespiti al
      fireDetections.sort((a, b) => b.confidence.compareTo(a.confidence));
      final bestDetection = fireDetections.first;

      // İhlali kaydet
      await _violationService.logFireDetection(
        flightId: _currentFlightId!,
        confidence: bestDetection.confidence,
        detectionType: bestDetection.label.toLowerCase(),
        imageUrl: null, // Şimdilik null, ileride storage entegrasyonu eklenebilir
      );

      // Son tespit zamanını güncelle
      _lastDetectionTime = now;

      // Konsola log
      print('🔥 FIRE DETECTION ALERT 🔥');
      print('Type: ${bestDetection.label}');
      print('Confidence: ${(bestDetection.confidence * 100).toStringAsFixed(2)}%');
      print('Flight ID: $_currentFlightId');
      print('Timestamp: $now');

    } catch (e) {
      print('Error processing image for fire detection: $e');
    }
  }

  /// Yangın algılama servisini durdur
  void stopDetection() {
    if (!_isRunning) return;

    _rtspService.stopCapturing();
    _currentFlightId = null;
    _isRunning = false;

    print('Fire detection service stopped');
  }

  /// Kaynakları serbest bırak
  void dispose() {
    stopDetection();
    _rtspService.dispose();
  }

  bool get isRunning => _isRunning;
}