// alcohol_test_page.dart
//
// Alkolmetre testi onboarding sayfası.
// Pilotların uçuş öncesi alkol seviyesini ölçmek için kullanılır.
//
// Yazan: Deniz Dogan
// Tarih: 2025-07-19

import 'dart:async';
import 'dart:math';

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

class AlcoholTestPage extends ConsumerStatefulWidget {
  const AlcoholTestPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AlcoholTestPage> createState() => _AlcoholTestPageState();
}

class _AlcoholTestPageState extends ConsumerState<AlcoholTestPage> with SingleTickerProviderStateMixin {
  final double _maxAlcoholLevel = 0.08; // BAC (Kan Alkol Konsantrasyonu) maksimum değeri
  final double _limitAlcoholLevel = 0.04; // Uçuş için izin verilen maksimum değer

  bool _isDeviceConnected = false;
  bool _isTestRunning = false;
  double _currentAlcoholLevel = 0.0;
  int _testProgress = 0; // 0-100 arası
  Timer? _testTimer;

  late AnimationController _pulseAnimationController;

  @override
  void initState() {
    super.initState();

    // Onboarding durumunu yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingViewModelProvider.notifier).loadOnboardingStatus();
    });

    // Nefes alıp verme animasyonu için controller
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _testTimer?.cancel();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);
    final isLoading = state.isLoading;
    final errorMessage = state.errorMessage;

    // Alkol testi tamamlandıysa bir sonraki sayfaya yönlendir
    if (state.status != null && state.status!.isAlcoholTestCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RouteConstants.checklist);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alkolmetre Testi'),
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
            'Alkolmetre Testi',
            style: TextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Uçuş güvenliği için alkolmetre testi yapmalısınız. Lütfen cihaza yaklaşıp üfleyiniz.',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Alkolmetre görseli ve test alanı
          Expanded(
            child: _buildAlcoholmeterView(),
          ),

          const SizedBox(height: 24),

          // Bağlantı durumu
          if (_isDeviceConnected) ...[
            AppMessage(
              message: 'Alkolmetre cihazı bağlı. Test için hazır.',
              type: MessageType.success,
              icon: Icons.bluetooth_connected,
            ),
          ] else ...[
            const AppMessage(
              message: 'Alkolmetre cihazına bağlanmak için butona basın.',
              type: MessageType.info,
              icon: Icons.bluetooth,
            ),
          ],

          const SizedBox(height: 24),

          // Butonlar
          _buildButtons(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAlcoholmeterView() {
    final isProcessing = ref.watch(onboardingViewModelProvider).isAlcoholTestProcessing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(),
          width: _isTestRunning ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Alkol seviyesi göstergesi
          Expanded(
            child: _buildAlcoholGauge(),
          ),

          // Test ilerleme çubuğu
          if (_isTestRunning || _testProgress > 0) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _testProgress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(),
              ),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Text(
              _isTestRunning ? 'Test yapılıyor... %$_testProgress' : 'Test tamamlandı',
              style: TextStyle(
                fontSize: 14,
                color: _getStatusColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          // Üfleme talimatları
          if (_isTestRunning) ...[
            const SizedBox(height: 16),
            _buildBreathingAnimation(),
          ],

          // Sonuç
          if (!_isTestRunning && _testProgress == 100) ...[
            const SizedBox(height: 16),
            _buildTestResult(),
          ],
        ],
      ),
    );
  }

  Widget _buildAlcoholGauge() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cihaz görseli
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey[400]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey[500]!,
                  width: 1,
                ),
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isDeviceConnected
                        ? (_isTestRunning ? Colors.blue : Colors.green)
                        : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isTestRunning
                        ? Icons.air
                        : (_isDeviceConnected ? Icons.check : Icons.bluetooth),
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Alkol seviyesi göstergesi (sadece test tamamlandığında)
        if (!_isTestRunning && _testProgress == 100) ...[
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusColor(),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _currentAlcoholLevel <= _limitAlcoholLevel
                        ? Icons.check_circle
                        : Icons.error,
                    color: _getStatusColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BAC: ${_currentAlcoholLevel.toStringAsFixed(3)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBreathingAnimation() {
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.air,
                color: Colors.blue,
                size: 20 + (_pulseAnimationController.value * 10),
              ),
              const SizedBox(width: 8),
              Text(
                'Lütfen cihaza doğru üfleyiniz',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestResult() {
    final isLevelOk = _currentAlcoholLevel <= _limitAlcoholLevel;

    return AppMessage(
      message: isLevelOk
          ? 'Test başarılı! Alkol seviyeniz izin verilen limitin altında.'
          : 'Test başarısız! Alkol seviyeniz izin verilen limitin üzerinde.',
      type: isLevelOk ? MessageType.success : MessageType.error,
      icon: isLevelOk ? Icons.check_circle : Icons.warning,
    );
  }

  Widget _buildButtons() {
    final state = ref.watch(onboardingViewModelProvider);
    final isProcessing = state.isAlcoholTestProcessing;

    return Column(
      children: [
        // Cihaz bağlantı butonu
        if (!_isDeviceConnected) ...[
          AppButton(
            text: 'Cihaza Bağlan',
            icon: Icons.bluetooth,
            onPressed: _connectDevice,
            isFullWidth: true,
            type: AppButtonType.secondary,
          ),
          const SizedBox(height: 16),
        ],

        // Test başlatma butonu
        if (_isDeviceConnected && !_isTestRunning && _testProgress == 0) ...[
          AppButton(
            text: 'Testi Başlat',
            icon: Icons.play_arrow,
            onPressed: _startTest,
            isFullWidth: true,
          ),
        ],

        // Test sonucu gönderme butonu
        if (!_isTestRunning && _testProgress == 100) ...[
          AppButton(
            text: 'Sonucu Gönder',
            icon: Icons.send,
            onPressed: _currentAlcoholLevel <= _limitAlcoholLevel
                ? () => _submitTestResult(_currentAlcoholLevel)
                : () {},
            isLoading: isProcessing,
            isFullWidth: true,
          ),

          if (_currentAlcoholLevel > _limitAlcoholLevel) ...[
            const SizedBox(height: 8),
            const Text(
              'Alkol seviyeniz izin verilen limitin üzerinde. Uçuş yapılamaz.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 16),

          // Testi tekrarlama butonu
          AppButton(
            text: 'Testi Tekrarla',
            icon: Icons.refresh,
            onPressed: _resetTest,
            isFullWidth: true,
            type: AppButtonType.secondary,
          ),
        ],
      ],
    );
  }

  void _connectDevice() {
    // Cihaz bağlantı simülasyonu
    setState(() {
      _isDeviceConnected = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(
                child: Text('Alkolmetre cihazına bağlanılıyor...'),
              ),
            ],
          ),
        ),
      ),
    );

    // 2 saniye sonra bağlantı kuruldu
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Dialog'u kapat
      setState(() {
        _isDeviceConnected = true;
      });
    });
  }

  void _startTest() {
    setState(() {
      _isTestRunning = true;
      _testProgress = 0;
      _currentAlcoholLevel = 0;
    });

    // Test simülasyonu - 5 saniye sürecek
    _testTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_testProgress < 100) {
          _testProgress += 2;
        } else {
          _isTestRunning = false;
          timer.cancel();

          // Test sonucu (rastgele)
          _generateTestResult();
        }
      });
    });
  }

  void _generateTestResult() {
    // Demo amaçlı, %70 başarılı test sonucu üret
    final random = Random();
    if (random.nextDouble() < 0.7) {
      // Başarılı test - limtin altında
      _currentAlcoholLevel = random.nextDouble() * _limitAlcoholLevel;
    } else {
      // Başarısız test - limitin üzerinde
      _currentAlcoholLevel = _limitAlcoholLevel + (random.nextDouble() * (_maxAlcoholLevel - _limitAlcoholLevel));
    }
  }

  void _resetTest() {
    setState(() {
      _testProgress = 0;
      _currentAlcoholLevel = 0;
      _isTestRunning = false;
    });
  }

  void _submitTestResult(double alcoholLevel) {
    ref.read(onboardingViewModelProvider.notifier).completeAlcoholTest(alcoholLevel);
  }

  Color _getStatusColor() {
    if (_isTestRunning) return Colors.blue;
    if (_testProgress == 0) return Colors.grey;

    return _currentAlcoholLevel <= _limitAlcoholLevel
        ? AppColors.success
        : AppColors.error;
  }

  Color _getProgressColor() {
    if (_testProgress < 60) return Colors.blue;
    if (_testProgress < 80) return Colors.orange;
    return Colors.green;
  }
}