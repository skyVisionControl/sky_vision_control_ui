import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class PersonDetectionService {
  FaceDetector? _faceDetector;
  static const double _confidenceThreshold = 0.5; // Classification için threshold

  Future<void> loadModel() async {
    if (_faceDetector != null) return;
    try {
      final options = FaceDetectorOptions(
        enableContours: false, // Gerek yoksa false (hız için)
        enableLandmarks: false, // Gerek yoksa false
        enableClassification: true, // Confidence için true (smiling/eye prob)
        performanceMode: FaceDetectorMode.accurate, // Veya fast
      );
      _faceDetector = FaceDetector(options: options);
      print('Face detection model loaded successfully.');
    } catch (e) {
      print('Error loading face detection model: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> detectPersons(String imagePath) async { // Interface'i koru, ama içte detectFaces
    await loadModel();
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector!.processImage(inputImage);

      // Tüm tespit edilen yüzleri filtrele (head count olarak say)
      final validFaces = faces
          .where((face) {
        // Classification varsa, en az bir prob > threshold
        if (face.smilingProbability != null || face.leftEyeOpenProbability != null || face.rightEyeOpenProbability != null) {
          final probs = [
            face.smilingProbability ?? 0.0,
            face.leftEyeOpenProbability ?? 0.0,
            face.rightEyeOpenProbability ?? 0.0,
          ];
          return probs.any((p) => p > _confidenceThreshold);
        }
        return true; // Classification false ise hepsini kabul et
      })
          .toList();

      final count = validFaces.length;
      // Avg confidence: Probability'lerin ortalaması
      final confidences = validFaces.map((face) {
        final probs = [
          face.smilingProbability ?? 0.5,
          face.leftEyeOpenProbability ?? 0.5,
          face.rightEyeOpenProbability ?? 0.5,
        ];
        return probs.reduce((a, b) => a + b) / probs.length;
      }).toList();
      final avgConfidence = confidences.isEmpty ? 0.0 : confidences.reduce((a, b) => a + b) / count;

      print('Detected $count faces (persons) with avg confidence: $avgConfidence');
      print('Total faces: ${faces.length}'); // Debug için
      return {'count': count, 'confidence': avgConfidence};
    } catch (e) {
      print('Error in face detection: $e');
      return {'count': 0, 'confidence': 0.0};
    }
  }

  void dispose() {
    _faceDetector?.close();
  }
}