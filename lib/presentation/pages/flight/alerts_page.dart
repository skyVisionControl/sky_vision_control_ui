// alerts_page.dart
//
// Uçuş sırasında oluşan uyarıları ve alarmları gösteren sayfa.
// Pilotun uyarıları görmesini, onaylamasını ve çözüldü olarak işaretlemesini sağlar.
//
// Yazan: Deniz Dogan
// Tarih: 2025-07-20

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/domain/entities/alert.dart';
import 'package:kapadokya_balon_app/domain/entities/sensor_data.dart';
import 'package:kapadokya_balon_app/presentation/providers/flight_providers.dart';
import 'package:kapadokya_balon_app/presentation/widgets/alerts/alert_detail_card.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/loading_indicator.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/app_message.dart';

class AlertsPage extends ConsumerStatefulWidget {
  const AlertsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends ConsumerState<AlertsPage> {
  // Filtreleme ve sıralama değişkenleri
  bool _showCriticalOnly = false;
  bool _showUnacknowledgedOnly = false;
  bool _showActiveOnly = true;
  String _sortBy = 'time'; // 'time', 'level'

  @override
  void initState() {
    super.initState();
    // Uyarıları yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(flightViewModelProvider.notifier).loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flightViewModelProvider);
    final isLoading = state.isLoading;
    final errorMessage = state.errorMessage;
    final alerts = _filterAlerts(state.activeAlerts);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uyarılar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrele',
          ),
        ],
      ),
      body: isLoading
          ? const PageLoading(message: 'Uyarılar yükleniyor...')
          : _buildContent(errorMessage, alerts),
    );
  }

  Widget _buildContent(String? errorMessage, List<Alert> alerts) {
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

        // Bilgi mesajı ve filtre özeti
        _buildInfoSection(alerts),

        // Uyarı listesi
        Expanded(
          child: alerts.isEmpty
              ? _buildEmptyState()
              : _buildAlertsList(alerts),
        ),
      ],
    );
  }

  Widget _buildInfoSection(List<Alert> alerts) {
    // Kritik uyarı sayısı
    final criticalCount = alerts.where((a) => a.level == AlertLevel.critical).length;
    final warningCount = alerts.where((a) => a.level == AlertLevel.warning).length;
    final infoCount = alerts.where((a) => a.level == AlertLevel.info).length;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: AppColors.cardLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Uyarı sayısı bilgisi
          RichText(
            text: TextSpan(
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              children: [
                const TextSpan(text: 'Toplam '),
                TextSpan(
                  text: '${alerts.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ' uyarı bulunuyor: '),
                if (criticalCount > 0) ...[
                  TextSpan(
                    text: '$criticalCount kritik',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (warningCount > 0 || infoCount > 0)
                    const TextSpan(text: ', '),
                ],
                if (warningCount > 0) ...[
                  TextSpan(
                    text: '$warningCount uyarı',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (infoCount > 0)
                    const TextSpan(text: ', '),
                ],
                if (infoCount > 0) ...[
                  TextSpan(
                    text: '$infoCount bilgi',
                    style: TextStyle(
                      color: AppColors.info,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Aktif filtreler
          Wrap(
            spacing: 8,
            children: [
              if (_showCriticalOnly)
                _buildFilterChip('Sadece Kritik', Icons.priority_high),
              if (_showUnacknowledgedOnly)
                _buildFilterChip('Sadece Görülmeyenler', Icons.visibility_off),
              if (_showActiveOnly)
                _buildFilterChip('Sadece Aktif', Icons.alarm_on),
              _buildFilterChip(
                _sortBy == 'time' ? 'Zamana Göre Sıralı' : 'Önem Düzeyine Göre Sıralı',
                _sortBy == 'time' ? Icons.access_time : Icons.error_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Chip(
      label: Text(label),
      avatar: Icon(
        icon,
        size: 16,
        color: AppColors.primary,
      ),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      visualDensity: VisualDensity.compact,
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Hiç uyarı bulunmuyor',
            style: TextStyles.heading3.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Şu anda aktif bir uyarı veya alarm yok',
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(List<Alert> alerts) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: alerts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return AlertDetailCard(
          alert: alert,
          onAcknowledge: () => _acknowledgeAlert(alert.id),
          onResolve: () => _resolveAlert(alert.id),
        );
      },
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Text(
                'Uyarıları Filtrele',
                style: TextStyles.heading3,
              ),
              const SizedBox(height: 20),

              // Filtre seçenekleri
              SwitchListTile(
                title: const Text('Sadece Kritik Uyarılar'),
                subtitle: const Text('Yalnızca kritik seviye uyarıları göster'),
                value: _showCriticalOnly,
                onChanged: (value) {
                  setState(() => _showCriticalOnly = value);
                  if (mounted) {
                    this.setState(() {});
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Görülmemiş Uyarılar'),
                subtitle: const Text('Yalnızca görülmemiş uyarıları göster'),
                value: _showUnacknowledgedOnly,
                onChanged: (value) {
                  setState(() => _showUnacknowledgedOnly = value);
                  if (mounted) {
                    this.setState(() {});
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Aktif Uyarılar'),
                subtitle: const Text('Yalnızca çözülmemiş uyarıları göster'),
                value: _showActiveOnly,
                onChanged: (value) {
                  setState(() => _showActiveOnly = value);
                  if (mounted) {
                    this.setState(() {});
                  }
                },
              ),

              const Divider(),

              // Sıralama seçenekleri
              const Text(
                'Sıralama',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              RadioListTile<String>(
                title: const Text('Zamana Göre (Yeni → Eski)'),
                value: 'time',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  if (mounted) {
                    this.setState(() {});
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Önem Düzeyine Göre (Kritik → Bilgi)'),
                value: 'level',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  if (mounted) {
                    this.setState(() {});
                  }
                },
              ),

              // Butonlar
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showCriticalOnly = false;
                          _showUnacknowledgedOnly = false;
                          _showActiveOnly = true;
                          _sortBy = 'time';
                        });
                        if (mounted) {
                          this.setState(() {});
                        }
                      },
                      child: const Text('Sıfırla'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tamam'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Alert> _filterAlerts(List<Alert> alerts) {
    // Filtreleme
    var filteredAlerts = alerts.where((alert) {
      // Sadece kritik uyarılar
      if (_showCriticalOnly && alert.level != AlertLevel.critical) {
        return false;
      }

      // Sadece görülmemiş uyarılar
      if (_showUnacknowledgedOnly && alert.isAcknowledged) {
        return false;
      }

      // Sadece aktif (çözülmemiş) uyarılar
      if (_showActiveOnly && alert.isResolved) {
        return false;
      }

      return true;
    }).toList();

    // Sıralama
    if (_sortBy == 'time') {
      // Zamana göre sırala (yeni → eski)
      filteredAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else if (_sortBy == 'level') {
      // Önem düzeyine göre sırala (kritik → bilgi)
      filteredAlerts.sort((a, b) {
        // Önce seviyeye göre
        final levelCompare = b.level.index.compareTo(a.level.index);
        if (levelCompare != 0) return levelCompare;

        // Seviyeler aynıysa zamana göre
        return b.timestamp.compareTo(a.timestamp);
      });
    }

    return filteredAlerts;
  }

  Future<void> _acknowledgeAlert(String alertId) async {
    await ref.read(flightRepositoryProvider).acknowledgeAlert(alertId);
    await ref.read(flightViewModelProvider.notifier).loadInitialData();
  }

  Future<void> _resolveAlert(String alertId) async {
    await ref.read(flightRepositoryProvider).resolveAlert(alertId);
    await ref.read(flightViewModelProvider.notifier).loadInitialData();
  }
}