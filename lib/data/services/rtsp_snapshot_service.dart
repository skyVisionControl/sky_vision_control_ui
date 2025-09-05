import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class RtspSnapshotService {
  final String rtspUrl;
  final Duration captureInterval;

  Timer? _captureTimer;
  bool _isCapturing = false;
  String? _lastCapturedImagePath;
  bool _isProcessing = false; // Yeni: paralel snapshot önleme

  RtspSnapshotService({
    required this.rtspUrl,
    this.captureInterval = const Duration(seconds: 5),
  });

  Future<void> startCapturing(void Function(String imagePath) onImageCaptured) async {
    if (_isCapturing) {
      print('RTSP snapshot capture is already running');
      return;
    }

    _isCapturing = true;
    print('Starting RTSP snapshot capture');

    _captureTimer = Timer.periodic(captureInterval, (_) async {
      final imagePath = await _captureSnapshot();
      if (imagePath != null) {
        onImageCaptured(imagePath);
      }
    });
  }

  Future<String?> _captureSnapshot() async {
    if (_isProcessing) return null; // Yeni: başka snapshot devam ederken yenisini alma
    _isProcessing = true;

    try {
      final dir = await getTemporaryDirectory();
      final path = p.join(
        dir.path,
        'rtsp_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Execute FFmpeg to capture a single frame from RTSP (no -update 1)
      final session = await FFmpegKit.execute(
        '-rtsp_transport tcp -i $rtspUrl -frames:v 1 $path',
      );

      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        _lastCapturedImagePath = path;
        print('Snapshot captured: $path');
        return path;
      } else {
        final output = await session.getOutput();
        print('FFmpeg capture failed: $output (return code: $returnCode)');
        return null;
      }
    } catch (e) {
      print('Error capturing RTSP snapshot: $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  Future<String?> captureCurrentFrame() async {
    return _captureSnapshot();
  }

  String? get lastCapturedImagePath => _lastCapturedImagePath;

  void stopCapturing() {
    _captureTimer?.cancel();
    _captureTimer = null;
    _isCapturing = false;
    print('RTSP snapshot capture stopped');
  }

  void dispose() {
    stopCapturing();
  }

  bool get isCapturing => _isCapturing;
}
