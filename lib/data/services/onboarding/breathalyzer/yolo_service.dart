// lib/data/services/onboarding/breathalyzer/yolo_service.dart
import 'dart:typed_data';
import '../../yolo_wrapper.dart'; // yolo_wrapper.dart'ı import et (dosya yoluna göre ayarlayın)

class YoloService {
  YoloService._();
  static final YoloService instance = YoloService._();

  YoloWrapper? _yoloWrapper;

  Future<void> ensureLoaded() async {
    if (_yoloWrapper != null) return;
    _yoloWrapper = YoloWrapper();
    await _yoloWrapper!.loadModel('breathalyzer', useGpu: false);
  }

  Future<Map<String, dynamic>> predict(Uint8List bytes) async {
    await ensureLoaded();
    return await _yoloWrapper!.predict(bytes);
  }

  Future<void> dispose() async {
    _yoloWrapper?.dispose();
    _yoloWrapper = null;
  }
}