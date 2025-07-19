// gauge_card.dart - tam düzeltilmiş versiyon
import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/domain/entities/sensor_data.dart';

class GaugeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final double value;
  final String unit;
  final double minValue;
  final double maxValue;
  final AlertLevel alertLevel;
  final int decimalPlaces;
  final bool isInverted;

  const GaugeCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.value,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    required this.alertLevel,
    this.decimalPlaces = 0,
    this.isInverted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final valuePercent = ((value - minValue) / (maxValue - minValue))
        .clamp(0.0, 1.0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  icon,
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
                    value.toStringAsFixed(decimalPlaces),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getAlertColor(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // İlerleme çubuğu
            LinearProgressIndicator(
              value: isInverted ? 1.0 - valuePercent : valuePercent,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
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
                    '${minValue.toStringAsFixed(decimalPlaces)} $unit',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${maxValue.toStringAsFixed(decimalPlaces)} $unit',
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

  Color _getProgressColor() {
    if (isInverted) {
      // Düşük değerler daha tehlikeli (yakıt seviyesi gibi)
      if (value < minValue + (maxValue - minValue) * 0.2) {
        return AppColors.error;
      } else if (value < minValue + (maxValue - minValue) * 0.4) {
        return AppColors.warning;
      } else {
        return AppColors.success;
      }
    } else {
      // Yüksek değerler daha tehlikeli (sıcaklık gibi)
      if (value > maxValue - (maxValue - minValue) * 0.2) {
        return AppColors.error;
      } else if (value > maxValue - (maxValue - minValue) * 0.4) {
        return AppColors.warning;
      } else {
        return AppColors.primary;
      }
    }
  }
}