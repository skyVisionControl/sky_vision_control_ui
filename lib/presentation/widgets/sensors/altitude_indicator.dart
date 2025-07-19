// altitude_indicator.dart - tam düzeltilmiş versiyon
import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/domain/entities/sensor_data.dart';

class AltitudeIndicator extends StatelessWidget {
  final double altitude;
  final double minValue;
  final double maxValue;
  final AlertLevel alertLevel;
  final double verticalSpeed;

  const AltitudeIndicator({
    Key? key,
    required this.altitude,
    required this.minValue,
    required this.maxValue,
    required this.alertLevel,
    required this.verticalSpeed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final altitudePercent = ((altitude - minValue) / (maxValue - minValue))
        .clamp(0.0, 1.0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yükseklik',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.height,
                  color: _getAlertColor(),
                  size: 20,
                ),
              ],
            ),

            // Ana değer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${altitude.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _getAlertColor(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Dikey hız göstergesi
            Row(
              children: [
                Icon(
                  verticalSpeed > 0.2
                      ? Icons.arrow_upward
                      : (verticalSpeed < -0.2 ? Icons.arrow_downward : Icons.arrow_forward),
                  color: _getVerticalSpeedColor(),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${verticalSpeed.abs().toStringAsFixed(1)} m/s',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getVerticalSpeedColor(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // İlerleme çubuğu
            LinearProgressIndicator(
              value: altitudePercent,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_getAlertColor()),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),

            // Min/Max değerler
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${minValue.toInt()} m',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${maxValue.toInt()} m',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor() {
    switch (alertLevel) {
      case AlertLevel.warning:
        return AppColors.warning;
      case AlertLevel.critical:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  Color _getVerticalSpeedColor() {
    if (verticalSpeed > 2.5 || verticalSpeed < -2.5) {
      return AppColors.error;
    } else if (verticalSpeed > 1.5 || verticalSpeed < -1.5) {
      return AppColors.warning;
    } else {
      return Colors.grey;
    }
  }
}