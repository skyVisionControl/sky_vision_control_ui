// face_recognition_page.dart
//
// Yüz tanıma onboarding sayfası.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:kapadokya_balon_app/core/constants/route_constants.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/data/models/face_match.dart';
import 'package:kapadokya_balon_app/data/models/face_user.dart';
import 'package:kapadokya_balon_app/data/services/face_recognition_service.dart';
import 'package:kapadokya_balon_app/presentation/providers/onboarding_providers.dart';
import 'package:kapadokya_balon_app/presentation/widgets/buttons/app_button.dart';
import 'package:kapadokya_balon_app/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:kapadokya_balon_app/presentation/widgets/face_painter.dart';
import 'package:path_provider/path_provider.dart';

final faceRecognitionServiceProvider = Provider<FaceRecognitionService>((ref) {
  final service = FaceRecognitionService();
  ref.onDispose(() => service.close());
  return service;
});

class FaceRecognitionPage extends ConsumerStatefulWidget {
  const FaceRecognitionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FaceRecognitionPage> createState() => _FaceRecognitionPageState();
}

class _FaceRecognitionPageState extends ConsumerState<FaceRecognitionPage> {
  final imagePicker = ImagePicker();

  bool isLoading = true;
  bool isCaptainRegistered = false;
  bool isCapturing = false;
  bool isProcessingImage = false;

  img.Image? capturedImage;
  Size? imageSize;
  List<FaceMatch> detectedFaces = [];

  @override
  void initState() {
    super.initState();
    _initializeFaceRecognition();
  }

  Future<void> _initializeFaceRecognition() async {
    setState(() => isLoading = true);

    try {
      final faceService = ref.read(faceRecognitionServiceProvider);

      // TFLite modelinin yüklendiğinden emin ol
      await faceService.ensureModelLoaded();

      // Kayıtlı yüzü kontrol et
      final hasSavedFace = await faceService.loadCaptainFace();

      debugPrint("👤 Has saved captain face: $hasSavedFace");

      setState(() {
        isCaptainRegistered = hasSavedFace;
        isLoading = false;
      });

      if (!hasSavedFace) {
        debugPrint("📸 No saved face found. Will prompt for face registration.");
        // UI yüklendikten sonra çağır
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _captureImage();
        });
      } else {
        debugPrint("✅ Saved face found. Ready for verification.");
      }
    } catch (e) {
      debugPrint("💥 Error initializing face recognition: $e");
      setState(() {
        isLoading = false;
        isCaptainRegistered = false;
      });

      // Kullanıcıya hata göster
      if (mounted) {
        AppDialogs.showErrorDialog(
          context: context,
          title: 'Yüz Tanıma Hatası',
          message: 'Yüz tanıma sistemi başlatılırken bir hata oluştu. Lütfen yüzünüzü yeniden kaydedin.',
        );
      }
    }
  }

  Future<void> _captureImage() async {
    setState(() => isCapturing = true);

    try {
      final faceService = ref.read(faceRecognitionServiceProvider);
      final pickedImage = await imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedImage == null) {
        setState(() => isCapturing = false);
        return;
      }

      setState(() => isProcessingImage = true);

      // Görüntüyü işle
      final imageFile = File(pickedImage.path);
      final inputImage = InputImage.fromFile(imageFile);
      final originalImage = await img.decodeImageFile(pickedImage.path);

      if (originalImage == null) {
        setState(() {
          isCapturing = false;
          isProcessingImage = false;
        });
        return;
      }

      // Yüzleri tespit et
      final faces = await faceService.faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        setState(() {
          isCapturing = false;
          isProcessingImage = false;
        });

        if (mounted) {
          AppDialogs.showErrorDialog(
            context: context,
            title: 'Yüz Bulunamadı',
            message: 'Fotoğrafta herhangi bir yüz tespit edilemedi. Lütfen tekrar deneyin.',
          );
        }
        return;
      }

      // Her yüz için vektörü hesapla
      List<FaceMatch> matches = [];

      for (final face in faces) {
        final faceVector = await faceService.recognizeFace(originalImage, face);

        if (isCaptainRegistered) {
          // Yüzü doğrula
          final match = faceService.matchFace(faceVector, face.boundingBox);
          if (match != null) matches.add(match);
        } else {
          // Yeni kaptan yüzü kaydet
          final newFace = FaceUser('captain', 'Captain', faceVector);

          // Yüz bölgesini kırp
          final croppedFace = _cropFaceFromImage(originalImage, face.boundingBox);
          final faceBytes = img.JpegEncoder().encode(croppedFace);

          // Kaptanı kaydet
          await faceService.saveCaptainFace(newFace, Uint8List.fromList(faceBytes));

          // Yeni yüzü matches listesine ekle
          matches.add(FaceMatch(
              user: newFace,
              difference: 0.0,
              boundingRect: face.boundingBox,
              isRecognized: true
          ));

          setState(() => isCaptainRegistered = true);
        }
      }

      // Görüntüyü UI için yeniden boyutlandır
      final displayWidth = 320;
      final displayHeight = (originalImage.height / originalImage.width * displayWidth).round();
      final resizedImage = img.copyResize(
          originalImage,
          width: displayWidth,
          height: displayHeight
      );

      setState(() {
        capturedImage = resizedImage;
        imageSize = Size(originalImage.width.toDouble(), originalImage.height.toDouble());
        detectedFaces = matches;
        isCapturing = false;
        isProcessingImage = false;
      });

      // Kaptan doğrulandı mı kontrol et
      final isCaptainVerified = matches.any((match) => match.isRecognized);

      if (isCaptainVerified) {
        // Onboarding sayfasına yüz tanıma durumunu bildir
        ref.read(onboardingViewModelProvider.notifier).setFaceRecognitionCompleted(true);

        if (mounted) {
          AppDialogs.showSuccessDialog(
              context: context,
              title: 'Yüz Tanıma Başarılı',
              message: 'Kaptan yüzü başarıyla doğrulandı.',
              onConfirm: () {
                // Sonraki sayfaya git
                context.replace(RouteConstants.alcoholTest);
              }
          );
        }
      } else if (isCaptainRegistered) {
        // Yüz tanıma başarısız
        if (mounted) {
          AppDialogs.showErrorDialog(
            context: context,
            title: 'Yüz Tanıma Başarısız',
            message: 'Kaptan yüzü doğrulanamadı. Lütfen tekrar deneyin.',
          );
        }
      } else {
        // Yeni yüz kaydedildi
        if (mounted) {
          AppDialogs.showSuccessDialog(
              context: context,
              title: 'Yüz Kaydı Başarılı',
              message: 'Kaptan yüzü başarıyla kaydedildi.',
              onConfirm: () {
                // Sonraki sayfaya git
                context.replace(RouteConstants.alcoholTest);
              }
          );
        }
      }

    } catch (e) {
      debugPrint('Yüz tanıma hatası: $e');
      setState(() {
        isCapturing = false;
        isProcessingImage = false;
      });

      if (mounted) {
        AppDialogs.showErrorDialog(
          context: context,
          title: 'Hata',
          message: 'Yüz tanıma işlemi sırasında bir hata oluştu. Lütfen tekrar deneyin.',
        );
      }
    }
  }

  img.Image _cropFaceFromImage(img.Image image, Rect faceRect) {
    double x = faceRect.left - 10.0;
    double y = faceRect.top - 10.0;
    double w = faceRect.width + 20.0;
    double h = faceRect.height + 20.0;

    // Negatif değerleri engelle
    x = x < 0 ? 0 : x;
    y = y < 0 ? 0 : y;

    // Resim sınırlarını aşmamasını sağla
    if (x + w > image.width) w = image.width - x;
    if (y + h > image.height) h = image.height - y;

    return img.copyCrop(
        image,
        x: x.round(),
        y: y.round(),
        width: w.round(),
        height: h.round()
    );
  }

  Future<ui.Image?> _convertToUiImage(img.Image? image) async {
    if (image == null) return null;
    final service = ref.read(faceRecognitionServiceProvider);
    return service.imageToUiImage(image);
  }

  // Yüz tanıma sayfasına ekleyin
  void _resetFaceRecognition() async {
    setState(() => isLoading = true);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final captainDir = Directory('${directory.path}/skyVisionControl/captain/faceRecognition');

      if (await captainDir.exists()) {
        await captainDir.delete(recursive: true);
        debugPrint("🗑️ Face recognition data cleared");
      }

      setState(() {
        isCaptainRegistered = false;
        isLoading = false;
        capturedImage = null;
        detectedFaces.clear();
      });

      // Yüz tanıma işlemini baştan başlat
      _captureImage();

    } catch (e) {
      debugPrint("💥 Error resetting face recognition: $e");
      setState(() => isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yüz Tanıma'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? _buildLoadingState()
          : _buildMainContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Yüz tanıma sistemi hazırlanıyor...'),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // İkon ve başlık
              const Icon(
                Icons.face,
                size: 72,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                isCaptainRegistered
                    ? 'Kaptan Yüz Doğrulama'
                    : 'Kaptan Yüz Tanıtma',
                style: TextStyles.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (isCaptainRegistered && detectedFaces.isEmpty) ...[
                const SizedBox(height: 16),
                AppButton(
                  text: 'Yüz Tanıma Sıfırla',
                  icon: Icons.refresh,
                  type: AppButtonType.outline,
                  onPressed: _resetFaceRecognition,
                  width: 220,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                isCaptainRegistered
                    ? 'Lütfen kimliğinizi doğrulamak için kameraya bakın.'
                    : 'İlk kez giriş yapıyorsunuz. Lütfen yüzünüzü sisteme tanıtın.',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Yakalanan görüntü
              if (capturedImage != null) ...[
                FutureBuilder<ui.Image?>(
                  future: _convertToUiImage(capturedImage),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final uiImage = snapshot.data;
                    if (uiImage == null) {
                      return const Text('Görüntü işlenemedi.');
                    }

                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomPaint(
                            painter: FaceDetectorPainter(
                              detectedFaces,
                              imageSize!,
                              uiImage,
                            ),
                            child: SizedBox(
                              width: capturedImage!.width.toDouble(),
                              height: capturedImage!.height.toDouble(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          detectedFaces.isEmpty
                              ? 'Yüz tespit edilemedi.'
                              : detectedFaces.any((face) => face.isRecognized)
                              ? 'Kaptan yüzü başarıyla doğrulandı.'
                              : 'Kaptan yüzü doğrulanamadı.',
                          style: TextStyle(
                            color: detectedFaces.any((face) => face.isRecognized)
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],

              // Butonlar
              AppButton(
                text: isCapturing
                    ? 'Kamera Açılıyor...'
                    : isCaptainRegistered
                    ? 'Yüzünüzü Doğrulayın'
                    : 'Yüzünüzü Tanıtın',
                icon: Icons.camera_alt,
                isLoading: isCapturing || isProcessingImage,
                onPressed: isCapturing || isProcessingImage
                    ? null
                    : _captureImage,
                width: 220,
              ),

              const SizedBox(height: 16),

              // Yüz doğrulandıysa sonraki sayfaya geçiş
              if (detectedFaces.any((face) => face.isRecognized)) ...[
                AppButton(
                  text: 'Devam Et',
                  icon: Icons.arrow_forward,
                  type: AppButtonType.secondary,
                  onPressed: () {
                    ref.read(onboardingViewModelProvider.notifier).setFaceRecognitionCompleted(true);
                    context.replace(RouteConstants.alcoholTest);
                  },
                  width: 180,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}