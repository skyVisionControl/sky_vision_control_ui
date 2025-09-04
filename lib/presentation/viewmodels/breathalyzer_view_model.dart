import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import '../../domain/entities/onboarding/alcohol_detection.dart';
import '../../data/services/onboarding/breathalyzer/ocr_service.dart';
import '../../data/services/onboarding/breathalyzer/yolo_service.dart';
import '../../data/services/onboarding/breathalyzer/firebase_breathalyzer_service.dart';

enum BreathalyzerStepState { idle, scanning, bothFound, displayFound, done, error }

class BreathalyzerState {
  final bool isLoading;
  final String? errorMessage;
  final BreathalyzerStepState stepState;
  final String statusMessage;
  final String? ocrValue;
  final double? alcoholValue;
  final List<Detection> detections;
  final bool ledStart;
  final bool ledShowDevice;
  final bool ledDone;
  final XFile? lastShot;
  final String? breathImageUrl;
  final String? breathalyzerId;
  final String? captainId;  // Kaptan ID'sini ekledik

  BreathalyzerState({
    this.isLoading = false,
    this.errorMessage,
    this.stepState = BreathalyzerStepState.idle,
    this.statusMessage = 'Alkolmetre testi başladı',
    this.ocrValue,
    this.alcoholValue,
    this.detections = const [],
    this.ledStart = true,
    this.ledShowDevice = false,
    this.ledDone = false,
    this.lastShot,
    this.breathImageUrl,
    this.breathalyzerId,
    this.captainId,
  });

  BreathalyzerState copyWith({
    bool? isLoading,
    String? errorMessage,
    BreathalyzerStepState? stepState,
    String? statusMessage,
    String? ocrValue,
    double? alcoholValue,
    List<Detection>? detections,
    bool? ledStart,
    bool? ledShowDevice,
    bool? ledDone,
    XFile? lastShot,
    String? breathImageUrl,
    String? breathalyzerId,
    String? captainId,
  }) {
    return BreathalyzerState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      stepState: stepState ?? this.stepState,
      statusMessage: statusMessage ?? this.statusMessage,
      ocrValue: ocrValue ?? this.ocrValue,
      alcoholValue: alcoholValue ?? this.alcoholValue,
      detections: detections ?? this.detections,
      ledStart: ledStart ?? this.ledStart,
      ledShowDevice: ledShowDevice ?? this.ledShowDevice,
      ledDone: ledDone ?? this.ledDone,
      lastShot: lastShot ?? this.lastShot,
      breathImageUrl: breathImageUrl ?? this.breathImageUrl,
      breathalyzerId: breathalyzerId ?? this.breathalyzerId,
      captainId: captainId ?? this.captainId,
    );
  }
}

class BreathalyzerViewModel extends StateNotifier<BreathalyzerState> {
  final FirebaseBreathalyzerService _breathalyzerService;

  CameraController? _cameraController;
  Timer? _detectionTimer;
  bool _busy = false;

  // YOLO etiketleri (modelindeki isimlerle birebir aynı olmalı)
  static const labelCaptain = 'captain_head';
  static const labelDevice = 'breathalyzer';
  static const labelDisplay = 'breath_display';

  BreathalyzerViewModel(this._breathalyzerService) : super(BreathalyzerState());

  Future<void> initCamera() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      // Tespit için zamanlayıcı başlat
      _detectionTimer = Timer.periodic(
        const Duration(seconds: 3),
            (_) => captureAndDetect(),
      );

      state = state.copyWith(
        isLoading: false,
        stepState: BreathalyzerStepState.scanning,
        statusMessage: 'Cihazı ve kaptanı aynı kareye getir',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        stepState: BreathalyzerStepState.error,
        errorMessage: 'Kamera başlatma hatası: $e',
        statusMessage: 'Kamera hatası: $e',
      );
    }
  }

  Future<void> captureAndDetect() async {
    if (_busy || _cameraController == null || !_cameraController!.value.isInitialized) return;
    _busy = true;

    try {
      // 1) Foto çek
      final shot = await _cameraController!.takePicture();
      state = state.copyWith(lastShot: shot);

      // 2) YOLO ile tespit et
      final bytes = await File(shot.path).readAsBytes();
      final det = await YoloService.instance.predict(bytes);

      final decoded = img.decodeImage(bytes)!;
      final w = decoded.width, h = decoded.height;

      final boxes = (det['boxes'] ?? []) as List;
      final detections = boxes
          .map((m) => Detection.fromMap(m as Map, imgW: w, imgH: h))
          .toList();

      state = state.copyWith(detections: detections);

      final hasCaptain = detections.any((d) => d.label == labelCaptain);
      final hasDevice = detections.any((d) => d.label == labelDevice);
      final display = detections.where((d) => d.label == labelDisplay).toList();

      // 3) Kaptan + cihaz aynı karedeyse
      if (hasCaptain && hasDevice) {
        state = state.copyWith(
          ledShowDevice: true,
          stepState: BreathalyzerStepState.bothFound,
          statusMessage: 'Kaptan + cihaz aynı karede. 3 sn\'de bir foto alınıyor...',
        );
      } else {
        state = state.copyWith(
          ledShowDevice: false,
          stepState: BreathalyzerStepState.scanning,
          statusMessage: 'Cihazı ve kaptanı aynı kareye getir',
        );
      }

      // 4) Ekran (kırmızı alan) varsa → ROI kırp, OCR yap
      if (display.isNotEmpty) {
        state = state.copyWith(
          stepState: BreathalyzerStepState.displayFound,
          statusMessage: 'Ekran bulundu, sayı okunuyor...',
        );

        display.sort((a, b) => b.confidence.compareTo(a.confidence));
        final roiImg = _crop(decoded, display.first);
        final roiPng = Uint8List.fromList(img.encodePng(roiImg));

        // OCR sadece sayı oku
        final value = await OcrService.instance.readNumeric(roiPng);

        if (value != null && double.tryParse(value) != null) {
          // Resim yükleme işlemini atla
          // final imageUrl = await _breathalyzerService.uploadBreathImage(
          //   bytes,
          //   state.captainId ?? 'DenizDogan21',
          // );

          // OCR sadece sayı oku
          final value = await OcrService.instance.readNumeric(roiPng);
          print('OCR read value: $value'); // Debug için

          if (value != null && double.tryParse(value) != null) {
            // Sayı değerini double'a çevir
            final alcoholValue = double.tryParse(value) ?? 0.0;
            print('Parsed alcohol value: $alcoholValue'); // Debug için

            // Veritabanına kaydet (resim URL'si olmadan)
            if (state.breathalyzerId != null) {
              await _breathalyzerService.completeBreathalyzerTest(
                breathalyzerId: state.breathalyzerId!,
                alcoholValue: alcoholValue,
              );
            }

            // State'i güncelle
            state = state.copyWith(
              ocrValue: value,
              alcoholValue: alcoholValue,
              stepState: BreathalyzerStepState.done,
              ledDone: true,
              statusMessage: 'Okunan değer: $value - Test tamamlandı!',
            );

            // Tespit döngüsünü durdur
            _detectionTimer?.cancel();
          }
        } else {
          state = state.copyWith(
            statusMessage: 'Sayı okunamadı, ekranı netleştir',
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        stepState: BreathalyzerStepState.error,
        statusMessage: 'Tespit hatası: $e',
        errorMessage: 'Tespit hatası: $e',
      );
    } finally {
      _busy = false;
    }
  }

  img.Image _crop(img.Image src, Detection d) {
    final x = d.left.round(), y = d.top.round();
    final w = (d.right - d.left).round();
    final h = (d.bottom - d.top).round();

    final rx = x.clamp(0, src.width - 1);
    final ry = y.clamp(0, src.height - 1);
    final rw = (rx + w > src.width) ? (src.width - rx) : w;
    final rh = (ry + h > src.height) ? (src.height - ry) : h;

    const pad = 6;
    final rx2 = (rx - pad).clamp(0, src.width - 1);
    final ry2 = (ry - pad).clamp(0, src.height - 1);
    final rw2 = ((rw + pad * 2) + rx2 > src.width) ? (src.width - rx2) : (rw + pad * 2);
    final rh2 = ((rh + pad * 2) + ry2 > src.height) ? (src.height - ry2) : (rh + pad * 2);

    return img.copyCrop(src, x: rx2, y: ry2, width: rw2, height: rh2);
  }

// Alkolmetre testini başlat
  Future<void> startBreathalyzerTest(String captainId) async {
    state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        captainId: captainId
    );

    try {
      // Test kaydı oluştur
      final breathalyzerId = await _breathalyzerService.createBreathalyzerTest(
        captainId: captainId,
      );

      state = state.copyWith(
        breathalyzerId: breathalyzerId,
        isLoading: false,
      );

      // Kamerayı başlat
      await initCamera();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        stepState: BreathalyzerStepState.error,
        errorMessage: 'Alkolmetre testi başlatma hatası: $e',
        statusMessage: 'Hata: $e',
      );
    }
  }


  CameraController? get cameraController => _cameraController;

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _cameraController?.dispose();
    OcrService.instance.dispose();
    super.dispose();
  }
}