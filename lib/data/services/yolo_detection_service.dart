// lib/data/services/yolo_detection_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Rect;
import 'yolo_wrapper.dart'; // yolo_wrapper.dart'ı import et (dosya yoluna göre ayarlayın)

/// Tek tespit nesnesi
class Detection {
  final String label;        // sınıf adı (veya stringe çevrilmiş id)
  final double confidence;   // 0..1
  final ui.Rect? box;        // piksel cinsinden xyxy

  Detection({
    required this.label,
    required this.confidence,
    this.box,
  });

  @override
  String toString() =>
      'Detection(label=$label, conf=${confidence.toStringAsFixed(2)}, box=$box)';
}

/// YOLO servis sarmalayıcısı
class YoloDetectionService {
  final String modelAssetName; // örn: 'yolo8n.tflite'
  final List<String>? classNames;  // örn: ['fire','smoke']

  YoloWrapper? _yoloWrapper;
  bool get isLoaded => _yoloWrapper != null;

  YoloDetectionService({
    required this.modelAssetName,
    this.classNames,
  });

  /// Modeli yükle (paket uygun delege bulamazsa CPU'ya düşer)
  Future<void> load() async {
    if (_yoloWrapper != null) return; // Zaten yüklenmişse tekrar yükleme

    _yoloWrapper = YoloWrapper();
    await _yoloWrapper!.loadModel(modelAssetName, useGpu: false); // GPU yok, false yap
    print('✅ YOLO model loaded: $modelAssetName');
  }

  /// Dosyadan tahmin
  Future<List<Detection>> detectFile(
      File imgFile, {
        double? confThreshold, // 0..1
      }) async {
    final bytes = await imgFile.readAsBytes();
    return detectBytes(bytes, confThreshold: confThreshold);
  }

  /// Bellekten (bytes) tahmin
  Future<List<Detection>> detectBytes(
      Uint8List imageBytes, {
        double? confThreshold, // 0..1
      }) async {
    if (_yoloWrapper == null) {
      await load();
    }

    final Map<String, dynamic>? out = await _yoloWrapper!.predict(imageBytes);

    final List<dynamic> boxes = (out?['boxes'] ?? const []) as List<dynamic>;
    final results = <Detection>[];

    for (final b in boxes) {
      if (b is! Map) continue;

      // ---- sınıf adı / indeks eşlemesi ----
      final dynamic rawCls =
      (b['class'] ?? b['name'] ?? b['label'] ?? b['id'] ?? b['cls']);
      String label;
      if (rawCls is num && classNames != null) {
        final i = rawCls.toInt();
        label = (i >= 0 && i < classNames!.length)
            ? classNames![i]
            : i.toString();
      } else {
        label = rawCls?.toString() ?? 'unknown';
      }

      // ---- güven ----
      final double conf = (() {
        final c = b['confidence'];
        if (c is num) return c.toDouble();
        if (c is String) return double.tryParse(c) ?? 0.0;
        return 0.0;
      })();
      if (confThreshold != null && conf < confThreshold) continue;

      // ---- bbox ----
      ui.Rect? rect;
      if (b['xyxy'] is List && (b['xyxy'] as List).length == 4) {
        final r = (b['xyxy'] as List)
            .map((e) => (e as num).toDouble())
            .toList(growable: false);
        rect = ui.Rect.fromLTRB(r[0], r[1], r[2], r[3]);
      } else if (b['xywh'] is List && (b['xywh'] as List).length == 4) {
        final r =
        (b['xywh'] as List).map((e) => (e as num).toDouble()).toList();
        final cx = r[0], cy = r[1], w = r[2], h = r[3];
        rect = ui.Rect.fromLTRB(cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2);
      }

      results.add(Detection(label: label, confidence: conf, box: rect));
    }

    print('📦 YOLO boxes=${boxes.length}, results=${results.length}');
    return results;
  }

  void dispose() {
    _yoloWrapper?.dispose();
    _yoloWrapper = null;
  }
}