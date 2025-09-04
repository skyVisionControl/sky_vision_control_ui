import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class RtspService {
  final String rtspUrl;
  final Duration captureInterval;

  VlcPlayerController? _controller;
  Timer? _captureTimer;
  bool _isCapturing = false;
  String? _lastCapturedImagePath;

  RtspService({
    required this.rtspUrl,
    this.captureInterval = const Duration(seconds: 5),
  });

  Future<void> initialize() async {
    _controller = VlcPlayerController.network(
      rtspUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
    );

    await _controller!.initialize();
  }

  Future<void> startCapturing(void Function(String imagePath) onImageCaptured) async {
    if (_controller == null) {
      await initialize();
    }

    _captureTimer?.cancel();
    _captureTimer = Timer.periodic(captureInterval, (_) async {
      final imagePath = await _captureFrame();
      if (imagePath != null) {
        onImageCaptured(imagePath);
      }
    });
  }

  Future<String?> _captureFrame() async {
    if (_isCapturing || _controller == null) return null;

    _isCapturing = true;

    try {
      final Uint8List? bytes = await _controller!.takeSnapshot();
      if (bytes == null || bytes.isEmpty) {
        print('RTSP snapshot is empty');
        return null;
      }

      final dir = await getTemporaryDirectory();
      final path = p.join(
        dir.path,
        'rtsp_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await File(path).writeAsBytes(bytes, flush: true);
      _lastCapturedImagePath = path;

      return path;
    } catch (e) {
      print('Error capturing RTSP frame: $e');
      return null;
    } finally {
      _isCapturing = false;
    }
  }

  Future<String?> captureCurrentFrame() async {
    return _captureFrame();
  }

  String? get lastCapturedImagePath => _lastCapturedImagePath;

  void stopCapturing() {
    _captureTimer?.cancel();
  }

  void dispose() {
    stopCapturing();
    _controller?.dispose();
    _controller = null;
  }
}