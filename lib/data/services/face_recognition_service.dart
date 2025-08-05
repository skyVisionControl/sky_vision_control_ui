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
      final modelBuffer = await rootBundle.load("assets/mobile_face_net.tflite");
      _interpreter = Interpreter.fromBuffer(modelBuffer.buffer.asUint8List());
      debugPrint("FaceNet model loaded successfully");
    } catch (e) {
      debugPrint("Error loading FaceNet model: $e");
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
      // Klasör yapısını oluştur
      final directory = await getApplicationDocumentsDirectory();
      final captainDir = Directory('${directory.path}/skyVisionControl/captain/faceRecognition');
      if (!await captainDir.exists()) {
        await captainDir.create(recursive: true);
      }

      // Yüz vektörünü json dosyasına kaydet
      final vectorFile = File('${captainDir.path}/face_data.json');
      await vectorFile.writeAsString(captain.vectorList.toString());

      // Yüz görüntüsünü kaydet
      final imageFile = File('${captainDir.path}/me.jpg');
      await imageFile.writeAsBytes(faceImageBytes);

      // Kaydedilen yüzü servis içinde sakla
      registeredCaptain = captain;

      debugPrint("Captain face saved successfully");
      return true;
    } catch (e) {
      debugPrint("Error saving captain face: $e");
      return false;
    }
  }

  // Kayıtlı yüzü kontrol et ve yükle
  Future<bool> loadCaptainFace() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final facePath = '${directory.path}/skyVisionControl/captain/faceRecognition/me.jpg';
      final vectorPath = '${directory.path}/skyVisionControl/captain/faceRecognition/face_data.json';

      final faceFile = File(facePath);
      final vectorFile = File(vectorPath);

      if (await faceFile.exists() && await vectorFile.exists()) {
        // Vektör verisini oku ve parse et
        final vectorString = await vectorFile.readAsString();
        final vectorList = vectorString
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((e) => double.parse(e.trim()))
            .toList();

        // Kaptanı servis içinde sakla
        registeredCaptain = FaceUser('captain', 'Captain', vectorList);
        debugPrint("Captain face loaded successfully");
        return true;
      }

      debugPrint("No saved captain face found");
      return false;
    } catch (e) {
      debugPrint("Error loading captain face: $e");
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
}