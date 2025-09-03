import 'dart:typed_data';
import 'package:ultralytics_yolo/yolo.dart';

/// YOLO (You Only Look Once) servisi - Görüntüde nesne tespiti yapar
class YoloService {
  YoloService._();
  static final YoloService instance = YoloService._();

  YOLO? _yolo;

  Future<void> ensureLoaded() async {
    if (_yolo != null) return;
    _yolo = YOLO(
      modelPath: 'breathalyzer', // ✅ sadece dosya adı, uzantısız
      task: YOLOTask.detect,
      useGpu: false,
    );
    await _yolo!.loadModel();
  }

  Future<Map<String, dynamic>> predict(Uint8List bytes) async {
    await ensureLoaded();
    return await _yolo!.predict(bytes);
  }
}
