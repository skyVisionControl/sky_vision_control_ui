// flight_summary_page.dart
//
// Uçuş tamamlandığında gösterilen özet sayfası.
//
// Yazan: Deniz Dogan
// Tarih: 2025-07-20

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kapadokya_balon_app/core/constants/route_constants.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/domain/entities/alert.dart';
import 'package:kapadokya_balon_app/domain/entities/flight_status.dart';
import 'package:kapadokya_balon_app/presentation/providers/flight_providers.dart';
import 'package:kapadokya_balon_app/presentation/widgets/buttons/app_button.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/loading_indicator.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/app_message.dart';

import '../../../domain/entities/sensor_data.dart';

class FlightSummaryPage extends ConsumerStatefulWidget {
  const FlightSummaryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FlightSummaryPage> createState() => _FlightSummaryPageState();
}

class _FlightSummaryPageState extends ConsumerState<FlightSummaryPage> {
  @override
  void initState() {
    super.initState();
    // Uçuş durumunu yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(flightViewModelProvider.notifier).loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flightViewModelProvider);
    final isLoading = state.isLoading;
    final errorMessage = state.errorMessage;
    final flightStatus = state.flightStatus;
    final alerts = state.activeAlerts;

    // Uçuş tamamlanmadıysa, sensör gösterge paneline yönlendir
    if (flightStatus != null && flightStatus.currentPhase != FlightPhase.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RouteConstants.sensorDashboard);
      });
    }

    return WillPopScope(
      onWillPop: () async => false, // Geri tuşunu devre dışı bırak
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Uçuş Özeti'),
          centerTitle: true,
          automaticallyImplyLeading: false, // Geri butonunu gizle
        ),
        body: isLoading
            ? const PageLoading(message: 'Uçuş verileri yükleniyor...')
            : _buildContent(errorMessage, flightStatus, alerts),
      ),
    );
  }

  Widget _buildContent(String? errorMessage, FlightStatus? flightStatus, List<Alert> alerts) {
    if (flightStatus == null) {
      return const Center(
        child: Text('Uçuş bilgileri bulunamadı.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hata mesajı (varsa)
          if (errorMessage != null) ...[
            AppMessage(
              message: errorMessage,
              type: MessageType.error,
              onClose: () => ref.read(flightViewModelProvider.notifier).clearError(),
            ),
            const SizedBox(height: 16),
          ],

          // Uçuş tamamlandı bildirimi
          _buildCompletionCard(flightStatus),

          const SizedBox(height: 24),

          // Uçuş istatistikleri
          Text(
            'Uçuş İstatistikleri',
            style: TextStyles.heading3,
          ),
          const SizedBox(height: 12),
          _buildStatisticsCard(flightStatus),

          const SizedBox(height: 24),

          // Uyarı özeti
          Text(
            'Uyarı Özeti',
            style: TextStyles.heading3,
          ),
          const SizedBox(height: 12),
          _buildAlertsCard(alerts),

          const SizedBox(height: 32),

          // Yeni uçuş butonu
          AppButton(
            text: 'Ana Menüye Dön',
            icon: Icons.home,
            onPressed: () => context.go(RouteConstants.sensorDashboard),
            isFullWidth: true,
          ),

          const SizedBox(height: 16),

          // Çıkış butonu
          AppButton(
            text: 'Çıkış Yap',
            icon: Icons.exit_to_app,
            onPressed: _confirmLogout,
            isFullWidth: true,
            type: AppButtonType.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard(FlightStatus flightStatus) {
    final duration = flightStatus.flightDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final durationText = hours > 0
        ? '$hours saat ${minutes.toString().padLeft(2, '0')} dakika'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Uçuş Başarıyla Tamamlandı',
              style: TextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Uçuş Süresi: $durationText',
              style: TextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Uçuş ID: ${flightStatus.flightId}',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(FlightStatus flightStatus) {
    final startTime = DateFormat('dd.MM.yyyy HH:mm').format(flightStatus.startTime);
    final endTime = flightStatus.endTime != null
        ? DateFormat('dd.MM.yyyy HH:mm').format(flightStatus.endTime!)
        : '(Bilinmiyor)';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatItem(
              'Başlangıç Zamanı',
              startTime,
              Icons.play_circle_outline,
            ),
            _buildDivider(),
            _buildStatItem(
              'Bitiş Zamanı',
              endTime,
              Icons.stop_circle_outlined,
            ),
            _buildDivider(),
            _buildStatItem(
              'Maksimum Yükseklik',
              '${flightStatus.maxAltitude.toStringAsFixed(0)} m',
              Icons.height,
            ),
            _buildDivider(),
            _buildStatItem(
              'Ortalama Hız',
              '${(flightStatus.groundSpeed).toStringAsFixed(1)} km/s',
              Icons.speed,
            ),
            _buildDivider(),
            _buildStatItem(
              'Kalan Yakıt',
              '${flightStatus.fuelLevel.toStringAsFixed(0)}%',
              Icons.local_fire_department,
            ),
            _buildDivider(),
            _buildStatItem(
              'Konum',
              '${flightStatus.latitude.toStringAsFixed(4)}, ${flightStatus.longitude.toStringAsFixed(4)}',
              Icons.location_on,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsCard(List<Alert> alerts) {
    // Uyarı özeti
    final criticalAlerts = alerts.where((a) => a.level == AlertLevel.critical).length;
    final warningAlerts = alerts.where((a) => a.level == AlertLevel.warning).length;
    final infoAlerts = alerts.where((a) => a.level == AlertLevel.info).length;

    final resolvedAlerts = alerts.where((a) => a.isResolved).length;
    final unresolvedAlerts = alerts.length - resolvedAlerts;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alerts.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 48,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Uçuş sırasında hiç uyarı oluşmadı',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Uyarı sayıları
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAlertCountItem(
                      criticalAlerts,
                      'Kritik',
                      AppColors.error,
                    ),
                    _buildAlertCountItem(
                      warningAlerts,
                      'Uyarı',
                      AppColors.warning,
                    ),
                    _buildAlertCountItem(
                      infoAlerts,
                      'Bilgi',
                      AppColors.info,
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Çözülen/Çözülmeyen uyarılar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAlertCountItem(
                      resolvedAlerts,
                      'Çözüldü',
                      AppColors.success,
                      icon: Icons.check_circle,
                    ),
                    _buildAlertCountItem(
                      unresolvedAlerts,
                      'Çözülmedi',
                      Colors.grey,
                      icon: Icons.pending,
                    ),
                  ],
                ),
              ),

              if (unresolvedAlerts > 0) ...[
                const Divider(),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(RouteConstants.alerts),
                    icon: const Icon(Icons.warning_amber),
                    label: const Text('Çözülmeyen Uyarıları Görüntüle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 32,
    );
  }

  Widget _buildAlertCountItem(int count, String label, Color color, {IconData? icon}) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: icon != null
                ? Icon(
              icon,
              color: color,
              size: 24,
            )
                : Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
            'Uygulamadan çıkmak istediğinizden emin misiniz?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(RouteConstants.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}