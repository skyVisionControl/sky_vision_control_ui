// approval_waiting_page.dart
//
// Uçuş onayı bekleme sayfası.
// Uçuş öncesi tüm kontroller tamamlandıktan sonra
// sivil havacılık yetkilisinden onay beklerken gösterilen ekran.
//
// Yazan: Deniz Dogan
// Tarih: 2025-07-19

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapadokya_balon_app/core/constants/route_constants.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/domain/entities/onboarding_status.dart';
import 'package:kapadokya_balon_app/presentation/providers/onboarding_providers.dart';
import 'package:kapadokya_balon_app/presentation/widgets/buttons/app_button.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/loading_indicator.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/app_message.dart';
import 'package:kapadokya_balon_app/presentation/widgets/onboarding/approval_status_card.dart';

class ApprovalWaitingPage extends ConsumerStatefulWidget {
  const ApprovalWaitingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ApprovalWaitingPage> createState() => _ApprovalWaitingPageState();
}

class _ApprovalWaitingPageState extends ConsumerState<ApprovalWaitingPage> {
  // Demo için onay durumunu otomatik değiştirme
  Timer? _autoApprovalTimer;
  bool _isAutoApprovalEnabled = false;

  @override
  void initState() {
    super.initState();
    // Onboarding durumunu yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingViewModelProvider.notifier).loadOnboardingStatus();
    });
  }

  @override
  void dispose() {
    _autoApprovalTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);
    final isLoading = state.isLoading;
    final errorMessage = state.errorMessage;
    final status = state.status;

    // Onay durumuna göre yönlendirme kontrolü
    _handleNavigation(status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uçuş Onayı'),
        centerTitle: true,
        actions: [
          // Demo onay modu butonu - sadece geliştirme aşamasında
          IconButton(
            icon: Icon(
              _isAutoApprovalEnabled ? Icons.timer : Icons.timer_off,
              color: _isAutoApprovalEnabled ? AppColors.success : Colors.grey,
            ),
            onPressed: _toggleAutoApproval,
            tooltip: 'Demo: Otomatik Onay',
          ),
        ],
      ),
      body: isLoading
          ? const PageLoading(message: 'Onay durumu kontrol ediliyor...')
          : _buildContent(errorMessage, status),
    );
  }

  Widget _buildContent(String? errorMessage, OnboardingStatus? status) {
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

          // Durum açıklaması
          Text(
            'Uçuş Onay Durumu',
            style: TextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Uçuş öncesi kontroller tamamlandı. Sivil havacılık yetkilisinden onay bekleniyor.',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Durum kartı
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: _buildApprovalStatusCard(status),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Alt butonlar
          _buildBottomButtons(status),
        ],
      ),
    );
  }

  Widget _buildApprovalStatusCard(OnboardingStatus? status) {
    if (status == null) {
      return const SizedBox.shrink();
    }

    final approvalStatus = status.approvalStatus;

    // Demo için tarih ve onaylayan bilgileri
    final DateTime approvalTime = approvalStatus == ApprovalStatus.pending
        ? DateTime.now()
        : DateTime.now().subtract(const Duration(minutes: 5));

    final String approverName = "Ahmet Yılmaz";

    return ApprovalStatusCard(
      status: _mapApprovalStatus(approvalStatus),
      approverName: approvalStatus != ApprovalStatus.pending ? approverName : null,
      approvalTime: approvalStatus != ApprovalStatus.pending ? approvalTime : null,
      rejectionReason: status.rejectionReason,
    );
  }

  Widget _buildBottomButtons(OnboardingStatus? status) {
    if (status == null) {
      return const SizedBox.shrink();
    }

    final approvalStatus = status.approvalStatus;

    return Column(
      children: [
        // Onaylandıysa uçuşa başla butonu
        if (approvalStatus == ApprovalStatus.approved) ...[
          AppButton(
            text: 'Uçuşa Başla',
            icon: Icons.flight_takeoff,
            onPressed: () => context.go(RouteConstants.sensorDashboard),
            isFullWidth: true,
          ),
        ],

        // Reddedildiyse tekrar deneme butonu
        if (approvalStatus == ApprovalStatus.rejected) ...[
          AppButton(
            text: 'Kontrol Listesine Dön',
            icon: Icons.refresh,
            onPressed: () => context.go(RouteConstants.checklist),
            isFullWidth: true,
            type: AppButtonType.secondary,
          ),
        ],

        // İptal butonu (Bekleme durumunda)
        if (approvalStatus == ApprovalStatus.pending) ...[
          AppButton(
            text: 'Onay İsteğini İptal Et',
            icon: Icons.cancel,
            onPressed: _resetOnboarding,
            isFullWidth: true,
            type: AppButtonType.secondary,
          ),
        ],

        const SizedBox(height: 16),

        // Demo kontrolleri - sadece geliştirme aşamasında
        if (approvalStatus == ApprovalStatus.pending) ...[
          _buildDemoControls(),
        ],
      ],
    );
  }

  Widget _buildDemoControls() {
    return Column(
      children: [
        const Divider(height: 32),
        const Text(
          'Demo Kontrolleri',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Onayla',
                onPressed: _simulateApproval,
                type: AppButtonType.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                text: 'Reddet',
                onPressed: _simulateRejection,
                type: AppButtonType.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleNavigation(OnboardingStatus? status) {
    if (status == null) return;

    // Tüm adımlar tamamlandı ve onaylandıysa, sensör ekranına yönlendir
    if (status.isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RouteConstants.sensorDashboard);
      });
    }
  }

  void _resetOnboarding() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İptal Onayı'),
        content: const Text(
            'Onay isteğini iptal ederseniz, tüm süreç baştan başlayacaktır. Devam etmek istiyor musunuz?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Onboarding sürecini sıfırla
              context.go(RouteConstants.faceRecognition);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );
  }

  void _toggleAutoApproval() {
    setState(() {
      _isAutoApprovalEnabled = !_isAutoApprovalEnabled;

      if (_isAutoApprovalEnabled) {
        // 5 saniye sonra otomatik onaylama
        _autoApprovalTimer = Timer(const Duration(seconds: 5), _simulateApproval);
      } else {
        _autoApprovalTimer?.cancel();
      }
    });
  }

  void _simulateApproval() {
    if (!mounted) return; // ✅ ekle

    final status = ref.read(onboardingViewModelProvider).status;
    if (status == null || status.approvalStatus != ApprovalStatus.pending) return;

    ref.read(onboardingRepositoryProvider).updateApprovalStatus(
      ApprovalStatus.approved,
    ).then((_) {
      if (!mounted) return; // ✅ ekle
      ref.read(onboardingViewModelProvider.notifier).loadOnboardingStatus();
    });
  }

  void _simulateRejection() {
    if (!mounted) return; // ✅ ekle

    final status = ref.read(onboardingViewModelProvider).status;
    if (status == null || status.approvalStatus != ApprovalStatus.pending) return;

    ref.read(onboardingRepositoryProvider).updateApprovalStatus(
      ApprovalStatus.rejected,
      rejectionReason: 'Hava koşulları uygun değil...',
    ).then((_) {
      if (!mounted) return; // ✅ ekle
      ref.read(onboardingViewModelProvider.notifier).loadOnboardingStatus();
    });
  }


  ApprovalStatus _mapApprovalStatus(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return ApprovalStatus.pending;
      case ApprovalStatus.approved:
        return ApprovalStatus.approved;
      case ApprovalStatus.rejected:
        return ApprovalStatus.rejected;
    }
  }
}