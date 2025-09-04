// alert_detail_card.dart
//
// Uyarı detaylarını gösteren kart bileşeni.
//
// Yazan: Deniz Dogan
// Tarih: 2025-07-20

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/domain/entities/alert.dart';
import 'package:kapadokya_balon_app/domain/entities/flight/sensor_data.dart';

class AlertDetailCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onAcknowledge;
  final VoidCallback onResolve;

  const AlertDetailCard({
    Key? key,
    required this.alert,
    required this.onAcknowledge,
    required this.onResolve,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getAlertColor().withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve seviye
            Row(
              children: [
                _buildAlertIcon(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getAlertColor(),
                    ),
                  ),
                ),
                if (alert.isResolved) ...[
                  _buildStatusBadge('Çözüldü', AppColors.success),
                ] else if (alert.isAcknowledged) ...[
                  _buildStatusBadge('Görüldü', AppColors.info),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Mesaj
            Text(
              alert.message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // Zaman ve ilgili sensör
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(alert.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (alert.relatedSensorType != null) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.sensors,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getSensorName(alert.relatedSensorType!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),

            // İşlem durumu (görüldü/çözüldü)
            if (alert.isAcknowledged && !alert.isResolved) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Görüldü: ${_formatDateTime(alert.acknowledgedAt!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ] else if (alert.isResolved) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.done_all,
                    size: 14,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Çözüldü: ${_formatDateTime(alert.resolvedAt!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],

            // Butonlar
            if (!alert.isResolved) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!alert.isAcknowledged) ...[
                    OutlinedButton.icon(
                      onPressed: onAcknowledge,
                      icon: const Icon(Icons.visibility),
                      label: const Text('Görüldü'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.info,
                        side: const BorderSide(color: AppColors.info),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton.icon(
                    onPressed: onResolve,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Çözüldü'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlertIcon() {
    IconData iconData;

    switch (alert.level) {
      case AlertLevel.critical:
        iconData = Icons.error;
        break;
      case AlertLevel.warning:
        iconData = Icons.warning_amber;
        break;
      case AlertLevel.info:
      default:
        iconData = Icons.info;
        break;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _getAlertColor().withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: _getAlertColor(),
        size: 20,
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getAlertColor() {
    switch (alert.level) {
      case AlertLevel.critical:
        return AppColors.error;
      case AlertLevel.warning:
        return AppColors.warning;
      case AlertLevel.info:
      default:
        return AppColors.info;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm:ss').format(dateTime);
  }

  String _getSensorName(SensorType type) {
    switch (type) {
      case SensorType.altitude:
        return 'Yükseklik';
      case SensorType.temperature:
        return 'Sıcaklık';
      case SensorType.pressure:
        return 'Basınç';
      case SensorType.direction:
        return 'Yön';
      case SensorType.speed:
        return 'Hız';
      case SensorType.fuelLevel:
        return 'Yakıt Seviyesi';
      case SensorType.verticalSpeed:
        return 'Dikey Hız';
      case SensorType.gpsPosition:
        return 'GPS Konumu';
      case SensorType.humidity:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SensorType.acceleration:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SensorType.angularVelocity:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}