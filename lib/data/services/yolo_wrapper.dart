// lib/data/services/yolo_wrapper.dart
import 'dart:typed_data';
import 'package:ultralytics_yolo/yolo.dart';

class YoloWrapper {
  YOLO? _yolo;

  Future<void> loadModel(String modelPath, {bool useGpu = false}) async {
    if (_yolo != null) return;
    _yolo = YOLO(
      modelPath: modelPath,
      task: YOLOTask.detect,
      useGpu: useGpu,
      useMultiInstance: true,  // Multiple instance desteği için true
    );
    await _yolo!.loadModel();
  }

  Future<Map<String, dynamic>> predict(Uint8List bytes) async {
    return await _yolo!.predict(bytes);
  }

  void dispose() {
    _yolo = null;
  }
}