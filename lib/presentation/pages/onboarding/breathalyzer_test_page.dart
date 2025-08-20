import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapadokya_balon_app/core/constants/route_constants.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/presentation/providers/breathalyzer_providers.dart';
import 'package:kapadokya_balon_app/presentation/providers/auth_providers.dart';
import 'package:kapadokya_balon_app/presentation/widgets/buttons/app_button.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/loading_indicator.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/status_led.dart';
import '../../viewmodels/breathalyzer_view_model.dart';

class BreathalyzerTestPage extends ConsumerStatefulWidget {
  const BreathalyzerTestPage({Key? key, required this.flightId}) : super(key: key);

  final String flightId;

  @override
  ConsumerState<BreathalyzerTestPage> createState() => _BreathalyzerTestPageState();
}

class _BreathalyzerTestPageState extends ConsumerState<BreathalyzerTestPage> {
  @override
  void initState() {
    super.initState();

    // Widget ağacı oluştuktan sonra alkolmetre testini başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBreathalyzerTest();
    });
  }

  void _initializeBreathalyzerTest() async {
    try {
      // Kullanıcı bilgisini al
      final userState = ref.read(authViewModelProvider);
      final user = userState.user;

      if (user == null) {
        print('Cannot start breathalyzer test: User is null');
        return;
      }

      // ViewModel'ı al
      final viewModel = ref.read(breathalyzerViewModelProvider.notifier);

      // Kaptan ID'si ile alkolmetre testini başlat
      await viewModel.startBreathalyzerTest(
        user.id, // Gerçek kaptan ID'si (Firebase Auth UID)
      );

      // Eğer viewmodel'da flight ID'yi saklamak istiyorsanız
      // viewModel.setFlightId(widget.flightId); // gibi bir metod ekleyebilirsiniz

    } catch (e) {
      print('Error initializing breathalyzer test: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(breathalyzerViewModelProvider);
    final isLoading = state.isLoading;
    final errorMessage = state.errorMessage;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: PageLoading(message: 'Alkolmetre testi başlatılıyor...'),
        ),
      );
    }

    // Test tamamlandıysa ve hata yoksa sonraki sayfaya yönlendir
    if (state.stepState == BreathalyzerStepState.done && errorMessage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RouteConstants.checklist);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alkolmetre Testi'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          return isWide
              ? _buildWideLayout(state)
              : _buildNarrowLayout(state);
        },
      ),
    );
  }

  Widget _buildWideLayout(BreathalyzerState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sol: Kamera önizleme
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _buildCameraPreview(state),
          ),
        ),

        // Sağ: LED'ler ve durum bilgileri
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _buildStatusPanel(state),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BreathalyzerState state) {
    return Column(
      children: [
        // Üst: Kamera önizleme
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _buildCameraPreview(state),
          ),
        ),

        // Alt: LED'ler ve durum bilgileri
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _buildStatusPanel(state),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview(BreathalyzerState state) {
    final cameraController = ref.read(breathalyzerViewModelProvider.notifier).cameraController;
    final isInitialized = cameraController?.value.isInitialized ?? false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.black12,
        child: Column(
          children: [
            // Kamera önizleme
            Expanded(
              child: isInitialized
                  ? AspectRatio(
                aspectRatio: cameraController!.value.aspectRatio,
                child: CameraPreview(cameraController),
              )
                  : const Center(
                child: CircularProgressIndicator(),
              ),
            ),

            // Son çekilen fotoğraf
            if (state.lastShot != null)
              Container(
                height: 120,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(
                  File(state.lastShot!.path),
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPanel(BreathalyzerState state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // LED durum göstergeleri
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  StatusLed(
                    title: 'Alkolmetre testi başladı',
                    on: state.ledStart,
                    onColor: AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  StatusLed(
                    title: 'Cihazı ekrana göster (kaptan + cihaz aynı karede)',
                    on: state.ledShowDevice,
                    onColor: AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  StatusLed(
                    title: 'İşlem tamamlandı',
                    on: state.ledDone,
                    onColor: AppColors.success,
                  ),
                ],
              ),
            ),

            // Durum mesajı
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE3E6EC)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    state.statusMessage,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ),
              ),
            ),

            // Okunan değer kutusu
            Container(
              width: double.infinity,
              height: 100,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  state.ocrValue ?? '—',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Hata mesajı (varsa)
            if (state.errorMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error),
                ),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: AppColors.error),
                ),
              ),

            // Test tamamlandıysa devam et butonu
            if (state.stepState == BreathalyzerStepState.done)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: AppButton(
                  text: 'Devam Et',
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    context.go(RouteConstants.checklist);
                  },
                  isFullWidth: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}