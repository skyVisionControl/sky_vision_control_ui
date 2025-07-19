// face_recognition_page.dart
//
// Yüz tanıma onboarding sayfası.
//
// Yazan: Deniz Dogan
// Tarih: 2025-07-18

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapadokya_balon_app/core/constants/route_constants.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/presentation/providers/onboarding_providers.dart';
import 'package:kapadokya_balon_app/presentation/widgets/buttons/app_button.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/loading_indicator.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/app_message.dart';

class FaceRecognitionPage extends ConsumerStatefulWidget {
  const FaceRecognitionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FaceRecognitionPage> createState() => _FaceRecognitionPageState();
}

class _FaceRecognitionPageState extends ConsumerState<FaceRecognitionPage> {
  bool _isCameraActive = false;
  bool _isFaceDetected = false;

  @override
  void initState() {
    super.initState();
    // Onboarding durumunu yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingViewModelProvider.notifier).loadOnboardingStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);
    final isLoading = state.isLoading;
    final errorMessage = state.errorMessage;

    // Yüz tanıma tamamlandıysa bir sonraki sayfaya yönlendir
    if (state.status != null && state.status!.isFaceRecognitionCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RouteConstants.alcoholTest);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yüz Tanıma'),
        centerTitle: true,
      ),
      body: isLoading
          ? const PageLoading(message: 'Yükleniyor...')
          : _buildContent(errorMessage),
    );
  }

  Widget _buildContent(String? errorMessage) {
    final state = ref.watch(onboardingViewModelProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Hata mesajı (varsa)
          if (errorMessage != null) ...[
            AppMessage(
              message: errorMessage,
              type: MessageType.error,
              onClose: () => ref.read(onboardingViewModelProvider.notifier).clearError(),
            ),
            const SizedBox(height: 16),
          ],

          // Başlık ve açıklama
          Text(
            'Yüz Tanıma',
            style: TextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Güvenlik için lütfen kameraya bakınız. Sistem yüzünüzü tanıyacak ve doğrulayacaktır.',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Kamera alanı
          Expanded(
            child: _buildCameraPreview(),
          ),

          const SizedBox(height: 24),

          // Yüz tanıma durumu
          if (_isCameraActive) ...[
            _isFaceDetected
                ? const AppMessage(
              message: 'Yüz tespit edildi! Doğrulama yapılıyor...',
              type: MessageType.success,
              icon: Icons.face,
            )
                : const AppMessage(
              message: 'Lütfen kameraya bakınız ve yüzünüzün net görünmesini sağlayınız.',
              type: MessageType.info,
              icon: Icons.face,
            ),
            const SizedBox(height: 24),
          ],

          // Butonlar
          _buildButtons(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final isProcessing = ref.watch(onboardingViewModelProvider).isFaceRecognitionProcessing;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFaceDetected ? AppColors.success : AppColors.border,
          width: _isFaceDetected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Kamera önizlemesi (simüle edilmiş)
          if (_isCameraActive)
            Image.asset(
              'assets/images/camera_placeholder.png',
              fit: BoxFit.cover,
              // Hata durumunda icon göster
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.camera_alt,
                size: 80,
                color: AppColors.primary,
              ),
            )
          else
            const Center(
              child: Icon(
                Icons.camera_alt,
                size: 80,
                color: AppColors.primary,
              ),
            ),

          // Yüz çerçevesi
          if (_isFaceDetected && _isCameraActive)
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.success,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),

          // İşlem göstergesi
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: LoadingIndicator(
                  color: Colors.white,
                  size: 60,
                  message: 'Yüz doğrulanıyor...',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    final state = ref.watch(onboardingViewModelProvider);
    final isProcessing = state.isFaceRecognitionProcessing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Kamera açma/kapama butonu
        Expanded(
          child: AppButton(
            text: _isCameraActive ? 'Kamerayı Kapat' : 'Kamerayı Aç',
            icon: _isCameraActive ? Icons.videocam_off_outlined : Icons.camera,
            onPressed: isProcessing ? () {} : _toggleCamera,
            type: AppButtonType.secondary,
            isFullWidth: true,
          ),
        ),
        const SizedBox(width: 16),

        // Yüz tanımayı başlat butonu
        Expanded(
          child: AppButton(
            text: 'Yüz Tanımayı Başlat',
            icon: Icons.face,
            onPressed: (isProcessing || !_isCameraActive)
                ? () {}
                : _startFaceRecognition,
            isLoading: isProcessing,
            isFullWidth: true,
          ),
        ),
      ],
    );
  }

  void _toggleCamera() {
    setState(() {
      _isCameraActive = !_isCameraActive;
      _isFaceDetected = false;

      // Kamera açıldıysa, 2 saniye sonra yüzü tespit et (simülasyon)
      if (_isCameraActive) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isFaceDetected = true;
            });
          }
        });
      }
    });
  }

  void _startFaceRecognition() {
    if (!_isFaceDetected) {
      // Yüz tespit edilmediyse uyarı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yüz tespit edilemedi. Lütfen kameraya bakın.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Yüz tanıma işlemini başlat
    ref.read(onboardingViewModelProvider.notifier).completeFaceRecognition();
  }
}