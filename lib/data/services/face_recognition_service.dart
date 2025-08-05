import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kapadokya_balon_app/data/models/face_user.dart';
import 'package:kapadokya_balon_app/data/models/face_match.dart';

class FaceRecognitionService {
  final int faceNetInputImageSize = 112;
  late Interpreter _interpreter;
  final faceDetector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate));

  // Kayıtlı kaptan yüzü (sadece bir yüz kaydediyoruz - kaptanın kendisi)
  FaceUser? registeredCaptain;

  FaceRecognitionService() {
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      debugPrint("⏳ Loading FaceNet model...");
      final modelBuffer = await rootBundle.load("assets/mobile_face_net.tflite");
      _interpreter = Interpreter.fromBuffer(modelBuffer.buffer.asUint8List());
      debugPrint("✅ FaceNet model loaded successfully");
      _isModelLoaded = true;
    } catch (e) {
      debugPrint("💥 Error loading FaceNet model: $e");
      _isModelLoaded = false;
      throw Exception("Failed to load FaceNet model: $e");
    }
  }

  Future<List<double>> recognizeFace(img.Image image, Face face) async {
    try {
      List input = _imageProcessor(image, face);
      input = input.reshape([1, 112, 112, 3]);
      List output = List.generate(1, (index) => List.filled(192, 0.0));
      _interpreter.run(input, output);
      return output[0].cast<double>();
    } catch (error) {
      debugPrint("Error in face recognition: $error");
      return [];
    }
  }

  List _imageProcessor(img.Image imageInput, Face faceDetected) {
    img.Image croppedImage = _cropFace(imageInput, faceDetected);
    img.Image image = img.copyResizeCropSquare(croppedImage, size: 112);
    Float32List imageAsList = imageToByteListFloat32(image);
    return imageAsList;
  }

  img.Image _cropFace(img.Image convertedImage, Face faceDetected) {
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;

    // Negatif değerleri engelle
    x = x < 0 ? 0 : x;
    y = y < 0 ? 0 : y;

    // Resim sınırlarını aşmamasını sağla
    if (x + w > convertedImage.width) w = convertedImage.width - x;
    if (y + h > convertedImage.height) h = convertedImage.height - y;

    return img.copyCrop(convertedImage,
        x: x.round(),
        y: y.round(),
        width: w.round(),
        height: h.round()
    );
  }

  Float32List imageToByteListFloat32(img.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - 128) / 128;
        buffer[pixelIndex++] = (pixel.g - 128) / 128;
        buffer[pixelIndex++] = (pixel.b - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  // Yüzü dosya sistemine kaydet
  Future<bool> saveCaptainFace(FaceUser captain, Uint8List faceImageBytes) async {
    try {
      debugPrint("⏳ Starting to save captain face data...");

      // Klasör yapısını oluştur
      final directory = await getApplicationDocumentsDirectory();
      final captainDir = Directory('${directory.path}/skyVisionControl/captain/faceRecognition');

      if (!await captainDir.exists()) {
        await captainDir.create(recursive: true);
        debugPrint("📁 Created directory: ${captainDir.path}");
      }

      // Önce eski dosyaları temizle (varsa)
      final vectorFilePath = '${captainDir.path}/face_data.json';
      final imageFilePath = '${captainDir.path}/me.jpg';

      final oldVectorFile = File(vectorFilePath);
      final oldImageFile = File(imageFilePath);

      if (await oldVectorFile.exists()) await oldVectorFile.delete();
      if (await oldImageFile.exists()) await oldImageFile.delete();

      // Vektör verisini daha güvenli bir şekilde kaydet - basit string formatı kullan
      final vectorFile = File(vectorFilePath);
      final vectorString = captain.vectorList.toString();
      await vectorFile.writeAsString(vectorString);

      debugPrint("💾 Vector data saved (${captain.vectorList.length} elements)");
      debugPrint("📄 Vector file size: ${await vectorFile.length()} bytes");

      // Yüz görüntüsünü kaydet
      final imageFile = File(imageFilePath);
      await imageFile.writeAsBytes(faceImageBytes);

      debugPrint("🖼️ Face image saved");
      debugPrint("📄 Image file size: ${await imageFile.length()} bytes");

      // Kaydedilen yüzü servis içinde sakla
      registeredCaptain = captain;

      debugPrint("✅ Captain face saved successfully");
      return true;
    } catch (e) {
      debugPrint("💥 Error saving captain face: $e");
      return false;
    }
  }

  // Kayıtlı yüzü kontrol et ve yükle
  Future<bool> loadCaptainFace() async {
    try {
      debugPrint("⏳ Checking for existing captain face data...");
      final directory = await getApplicationDocumentsDirectory();
      final facePath = '${directory.path}/skyVisionControl/captain/faceRecognition/me.jpg';
      final vectorPath = '${directory.path}/skyVisionControl/captain/faceRecognition/face_data.json';

      final faceFile = File(facePath);
      final vectorFile = File(vectorPath);

      // Dosya varlığını kontrol et
      final faceExists = await faceFile.exists();
      final vectorExists = await vectorFile.exists();

      debugPrint("📁 Face image file exists: $faceExists");
      debugPrint("📁 Vector data file exists: $vectorExists");

      if (!faceExists || !vectorExists) {
        debugPrint("❌ Required files not found. First-time registration needed.");
        return false;
      }

      try {
        // Vektör dosyasının içeriğini oku
        final String vectorContent = await vectorFile.readAsString();
        debugPrint("📄 Vector file content (first 50 chars): ${vectorContent.substring(0, min(50, vectorContent.length))}");

        try {
          // Vektör içeriğini parse et
          List<double> vectorList = [];

          // Düz string formatını parse etmeye çalış
          final cleanedStr = vectorContent
              .replaceAll('[', '')
              .replaceAll(']', '')
              .trim();

          if (cleanedStr.isNotEmpty) {
            vectorList = cleanedStr
                .split(',')
                .map((s) => double.parse(s.trim()))
                .toList();
          }

          if (vectorList.isEmpty) {
            debugPrint("⚠️ Vector parsing failed - empty list");
            return false;
          }

          debugPrint("✅ Vector parsed successfully with ${vectorList.length} elements");

          // Kaptanı servis içinde sakla
          registeredCaptain = FaceUser('captain', 'Captain', vectorList);
          debugPrint("👤 Captain face loaded successfully");
          if (registeredCaptain != null) {
            // Yüklenen vektörü doğrula - en azından uzunluğu makul olmalı
            if (registeredCaptain!.vectorList.length < 10) {
              debugPrint("⚠️ Loaded vector seems too short (${registeredCaptain!.vectorList.length} elements)");
              registeredCaptain = null;
              return false;
            }

            // Vektör değerlerini kontrol et - NaN veya Infinity değerleri olmamalı
            bool hasInvalidValues = registeredCaptain!.vectorList.any(
                    (value) => value.isNaN || value.isInfinite
            );

            if (hasInvalidValues) {
              debugPrint("⚠️ Vector contains invalid values (NaN or Infinity)");
              registeredCaptain = null;
              return false;
            }
          }
          return true;
        } catch (parseError) {
          debugPrint("⚠️ Error parsing vector data: $parseError");
          // Parse hatası durumunda dosyaları sil ve yeniden kayıt gerektiğini belirt
          await faceFile.delete();
          await vectorFile.delete();
          debugPrint("🗑️ Corrupted files deleted. First-time registration needed.");
          return false;
        }
      } catch (readError) {
        debugPrint("⚠️ Error reading vector file: $readError");
        return false;
      }
    } catch (e) {
      debugPrint("💥 Fatal error loading captain face: $e");
      return false;
    }

  }

  // Yüz karşılaştırma
  FaceMatch? matchFace(List<double> faceVector, Rect boundingRect) {
    if (registeredCaptain == null) {
      return FaceMatch(
          user: FaceUser('unknown', 'Unknown', faceVector),
          difference: 1.0,
          boundingRect: boundingRect,
          isRecognized: false
      );
    }

    // Öklid uzaklığı hesapla
    double distance = 0;
    final knownVector = registeredCaptain!.vectorList;

    for (int i = 0; i < faceVector.length; i++) {
      double diff = faceVector[i] - knownVector[i];
      distance += diff * diff;
    }
    distance = sqrt(distance); // double.sqrt() yerine dart:math'ten sqrt() kullanın

    // Eşleşme eşiği (0.7'den küçük değerler kabul edilir)
    final bool isMatch = distance < 0.7;

    return FaceMatch(
        user: isMatch
            ? registeredCaptain!
            : FaceUser('unknown', 'Unknown', faceVector),
        difference: distance,
        boundingRect: boundingRect,
        isRecognized: isMatch
    );
  }

  // Ui.Image oluşturma yardımcısı
  Future<ui.Image?> imageToUiImage(img.Image? image) async {
    if (image == null) return null;
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(img.JpegEncoder().encode(image), completer.complete);
    return completer.future;
  }

  void close() {
    _interpreter.close();
    faceDetector.close();
  }

  // Model yükleme durumunu kontrol eden metod
  bool _isModelLoaded = false;

  Future<void> ensureModelLoaded() async {
    if (!_isModelLoaded) {
      await loadModel();
      _isModelLoaded = true;
    }
  }
}