// sensor_dashboard_page.dart
//
// Sensör gösterge paneli sayfası.
// Uçuş sırasında tüm sensör verilerini ve uçuş durumunu gösterir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapadokya_balon_app/core/constants/route_constants.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/domain/entities/flight_status.dart';
import 'package:kapadokya_balon_app/domain/entities/sensor_data.dart';
import 'package:kapadokya_balon_app/presentation/providers/flight_providers.dart';
import 'package:kapadokya_balon_app/presentation/widgets/buttons/app_button.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/loading_indicator.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/app_message.dart';
import 'package:kapadokya_balon_app/presentation/widgets/flight/flight_summary_card.dart';
import 'package:kapadokya_balon_app/presentation/widgets/sensors/altitude_indicator.dart';
import 'package:kapadokya_balon_app/presentation/widgets/sensors/direction_indicator.dart';
import 'package:kapadokya_balon_app/presentation/widgets/sensors/gauge_card.dart';
import 'package:kapadokya_balon_app/domain/entities/alert.dart';
import 'package:kapadokya_balon_app/presentation/widgets/sensors/gps_position_card.dart';

class SensorDashboardPage extends ConsumerStatefulWidget {
  const SensorDashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SensorDashboardPage> createState() => _SensorDashboardPageState();
}

class _SensorDashboardPageState extends ConsumerState<SensorDashboardPage> {
  @override
  void initState() {
    super.initState();
    // İlk veri yüklemesi
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

    // Uçuş tamamlandıysa, uçuş sonuç sayfasına yönlendir
    if (flightStatus != null && flightStatus.currentPhase == FlightPhase.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RouteConstants.flightSummary);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensör Gösterge Paneli'),
        centerTitle: true,
        backgroundColor: _getPhaseColor(flightStatus?.currentPhase),
        actions: [
          // Acil durum butonu
          if (flightStatus != null && flightStatus.isEmergencyMode) ...[
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 16.0,
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    'ACİL DURUM',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Uyarı sayısı göstergesi
          if (state.activeAlerts.isNotEmpty) ...[
            IconButton(
              icon: Badge(
                label: Text(state.activeAlerts.length.toString()),
                backgroundColor: _getCriticalAlertsColor(state.activeAlerts),
                child: const Icon(Icons.notifications),
              ),
              onPressed: () => context.push(RouteConstants.alert),
              tooltip: 'Uyarılar',
            ),
          ],

          // Menü butonu
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMenu(context),
            tooltip: 'Menü',
          ),
        ],
      ),
      body: isLoading
          ? const PageLoading(message: 'Sensör verileri yükleniyor...')
          : _buildContent(errorMessage, flightStatus),
    );
  }

  Widget _buildContent(String? errorMessage, FlightStatus? flightStatus) {
    final state = ref.watch(flightViewModelProvider);

    return Column(
      children: [
        // Hata mesajı (varsa)
        if (errorMessage != null) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppMessage(
              message: errorMessage,
              type: MessageType.error,
              onClose: () => ref.read(flightViewModelProvider.notifier).clearError(),
            ),
          ),
        ],

        // Uçuş özeti
        if (flightStatus != null) ...[
          FlightSummaryCard(
            flightStatus: flightStatus,
            onPhaseChange: _showPhaseChangeDialog,
          ),
        ],

        // Sensör göstergeleri
        Expanded(
          child: _buildSensorGrid(state.sensorData),
        ),

        // Alt butonlar
        _buildBottomButtons(flightStatus),
      ],
    );
  }

  Widget _buildSensorGrid(List<SensorData> sensors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ekran genişliğine göre grid oluştur
        final isWide = constraints.maxWidth > 600;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: isWide ? 3 : 2,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            childAspectRatio: isWide ? 1.3 : 1.0,
            children: [
              // Yükseklik göstergesi
              AltitudeIndicator(
                value: _getSensorValue(SensorType.altitude),
                minValue: _getSensorMinValue(SensorType.altitude),
                maxValue: _getSensorMaxValue(SensorType.altitude),
                alertLevel: _getSensorAlertLevel(SensorType.altitude),
                verticalSpeed: _getSensorValue(SensorType.verticalSpeed),
              ),

              // Yön göstergesi
              DirectionIndicator(
                value: _getSensorValue(SensorType.direction),
                alertLevel: _getSensorAlertLevel(SensorType.direction),
              ),

              // Sıcaklık göstergesi
              GaugeCard(
                title: 'Sıcaklık',
                icon: Icons.thermostat,
                value: _getSensorValue(SensorType.temperature),
                unit: '°C',
                minValue: _getSensorMinValue(SensorType.temperature),
                maxValue: _getSensorMaxValue(SensorType.temperature),
                alertLevel: _getSensorAlertLevel(SensorType.temperature),
              ),

              // Basınç göstergesi
              GaugeCard(
                title: 'Basınç',
                icon: Icons.compress,
                value: _getSensorValue(SensorType.pressure),
                unit: 'hPa',
                minValue: _getSensorMinValue(SensorType.pressure),
                maxValue: _getSensorMaxValue(SensorType.pressure),
                alertLevel: _getSensorAlertLevel(SensorType.pressure),
                decimalPlaces: 1,
              ),

              // Hız göstergesi
              GaugeCard(
                title: 'Hız',
                icon: Icons.speed,
                value: _getSensorValue(SensorType.speed),
                unit: 'km/h',
                minValue: _getSensorMinValue(SensorType.speed),
                maxValue: _getSensorMaxValue(SensorType.speed),
                alertLevel: _getSensorAlertLevel(SensorType.speed),
                decimalPlaces: 1,
              ),

              // Yakıt seviyesi göstergesi
              GaugeCard(
                title: 'Yakıt Seviyesi',
                icon: Icons.local_fire_department,
                value: _getSensorValue(SensorType.fuelLevel),
                unit: '%',
                minValue: _getSensorMinValue(SensorType.fuelLevel),
                maxValue: _getSensorMaxValue(SensorType.fuelLevel),
                alertLevel: _getSensorAlertLevel(SensorType.fuelLevel),
                decimalPlaces: 0,
                isInverted: true, // Düşük değerler kötü
              ),

              // GPS konumu
              GPSPositionCard(
                latitude: _getSensorValue(SensorType.gpsPosition),
                longitude: _getSensorValue(SensorType.gpsPosition, isSecondary: true),
                hasSignal: ref.watch(flightViewModelProvider).flightStatus?.hasGPSSignal ?? true,
                alertLevel: _getSensorAlertLevel(SensorType.gpsPosition),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons(FlightStatus? flightStatus) {
    final state = ref.watch(flightViewModelProvider);

    // Uçuş tamamlandıysa buton gösterme
    if (flightStatus == null || flightStatus.currentPhase == FlightPhase.completed) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(opacity: 0.05),
            blurRadius: 5.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Aktif uyarılar
            if (state.activeAlerts.isNotEmpty) ...[
              _buildAlertIndicator(state.activeAlerts),
              const SizedBox(height: 16.0),
            ],

            // Butonlar
            Row(
              children: [
                // Sorun bildirme butonu
                Expanded(
                  child: AppButton(
                    text: 'Sorun Bildir',
                    icon: Icons.report_problem,
                    onPressed: () => context.push(RouteConstants.reportIssue),
                    type: AppButtonType.secondary,
                  ),
                ),
                const SizedBox(width: 16.0),

                // Uçuşu sonlandırma butonu
                Expanded(
                  child: AppButton(
                    text: 'Uçuşu Sonlandır',
                    icon: Icons.flight_land,
                    onPressed: state.isEndingFlight ? null : _confirmEndFlight,
                    isLoading: state.isEndingFlight,
                    type: AppButtonType.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertIndicator(List<Alert> alerts) {
    final hasCritical = alerts.any((alert) => alert.level == AlertLevel.critical);

    return GestureDetector(
      onTap: () => context.push(RouteConstants.alerts),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: hasCritical ? AppColors.error.withValues(opacity: 0.1) : AppColors.warning.withValues(opacity: 0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(
              hasCritical ? Icons.warning_amber_rounded : Icons.info_outline,
              color: hasCritical ? AppColors.error : AppColors.warning,
              size: 20.0,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                '${alerts.length} ${alerts.length == 1 ? 'aktif uyarı' : 'aktif uyarı'} mevcut',
                style: TextStyle(
                  color: hasCritical ? AppColors.error : AppColors.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14.0,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showPhaseChangeDialog(FlightPhase currentPhase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uçuş Evresi Değiştir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mevcut uçuş evresini değiştirmek istediğinize emin misiniz?'),
            const SizedBox(height: 16.0),
            _buildPhaseSelector(currentPhase),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseSelector(FlightPhase currentPhase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: FlightPhase.values
          .where((phase) => phase != FlightPhase.completed) // Tamamlandı durumuna manuel geçilmez
          .map((phase) => _buildPhaseButton(phase, phase == currentPhase))
          .toList(),
    );
  }

  Widget _buildPhaseButton(FlightPhase phase, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: isSelected
            ? null
            : () {
          Navigator.pop(context);
          ref.read(flightViewModelProvider.notifier).updateFlightPhase(phase);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.grey[300] : _getPhaseColor(phase),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
        child: Text(_getPhaseText(phase)),
      ),
    );
  }

  void _confirmEndFlight() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uçuşu Sonlandır'),
        content: const Text(
            'Uçuşu sonlandırmak istediğinizden emin misiniz?\n\n'
                'Bu işlem, uçuşun tamamlandığını belirtir ve kayıtları kapatır.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(flightViewModelProvider.notifier).endFlight();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Uçuşu Sonlandır'),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('Kontrol Listesi'),
              onTap: () {
                Navigator.pop(context);
                context.push(RouteConstants.checklist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Uyarılar'),
              onTap: () {
                Navigator.pop(context);
                context.push(RouteConstants.alerts);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Harita Görünümü'),
              onTap: () {
                Navigator.pop(context);
                context.push(RouteConstants.map);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Sorun Bildir'),
              onTap: () {
                Navigator.pop(context);
                context.push(RouteConstants.reportIssue);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flight_land),
              title: const Text('Uçuşu Sonlandır'),
              onTap: () {
                Navigator.pop(context);
                _confirmEndFlight();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Uygulamadan Çık'),
              onTap: () {
                Navigator.pop(context);
                _confirmLogout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
            'Uygulamadan çıkmak istediğinizden emin misiniz?\n\n'
                'Uçuş devam ediyorsa, veriler kaydedilecek ancak görüntülenemeyecektir.'
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

  // Sensör değerlerini alma yardımcı metodları
  double _getSensorValue(SensorType type, {bool isSecondary = false}) {
    final sensor = ref.read(flightViewModelProvider.notifier).getSensorData(type);
    if (sensor == null) return 0.0;
    return isSecondary && sensor.secondaryValue != null ? sensor.secondaryValue! : sensor.value;
  }

  double _getSensorMinValue(SensorType type) {
    final sensor = ref.read(flightViewModelProvider.notifier).getSensorData(type);
    return sensor?.minValue ?? 0.0;
  }

  double _getSensorMaxValue(SensorType type) {
    final sensor = ref.read(flightViewModelProvider.notifier).getSensorData(type);
    return sensor?.maxValue ?? 100.0;
  }

  AlertLevel _getSensorAlertLevel(SensorType type) {
    final sensor = ref.read(flightViewModelProvider.notifier).getSensorData(type);
    return sensor?.alertLevel ?? AlertLevel.none;
  }

  // Yardımcı metodlar
  Color _getPhaseColor(FlightPhase? phase) {
    if (phase == null) return AppColors.primary;

    switch (phase) {
      case FlightPhase.preparation:
        return Colors.blue;
      case FlightPhase.inflation:
        return Colors.orange;
      case FlightPhase.takeoff:
        return Colors.purple;
      case FlightPhase.climbing:
        return Colors.green;
      case FlightPhase.cruising:
        return AppColors.primary;
      case FlightPhase.descending:
        return Colors.amber;
      case FlightPhase.landing:
        return Colors.red;
      case FlightPhase.completed:
        return Colors.grey;
    }
  }

  String _getPhaseText(FlightPhase phase) {
    switch (phase) {
      case FlightPhase.preparation:
        return 'Hazırlık';
      case FlightPhase.inflation:
        return 'Şişirme';
      case FlightPhase.takeoff:
        return 'Kalkış';
      case FlightPhase.climbing:
        return 'Yükseliş';
      case FlightPhase.cruising:
        return 'Seyir';
      case FlightPhase.descending:
        return 'Alçalma';
      case FlightPhase.landing:
        return 'İniş';
      case FlightPhase.completed:
        return 'Tamamlandı';
    }
  }

  Color _getCriticalAlertsColor(List<Alert> alerts) {
    if (alerts.any((alert) => alert.level == AlertLevel.critical)) {
      return AppColors.error;
    } else if (alerts.any((alert) => alert.level == AlertLevel.warning)) {
      return AppColors.warning;
    } else {
      return AppColors.info;
    }
  }
}