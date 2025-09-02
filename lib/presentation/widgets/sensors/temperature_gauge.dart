// widgets/sensors/temperature_gauge.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/sensor_data.dart';
import '../../../core/themes/text_styles.dart';
import '../../../core/themes/app_colors.dart';

class TemperatureGauge extends StatelessWidget {
  final SensorData sensor;
  const TemperatureGauge({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    double percent = (sensor.value / 100).clamp(0.0, 1.0);
    return Card(
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sıcaklık", style: TextStyle(color: AppColors.textPrimaryDark)),
            const SizedBox(height: 8),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 30,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.temperatureGauge),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: percent * 120,
                      color: AppColors.temperatureGauge,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('${sensor.value.toStringAsFixed(1)}°C',
                style: TextStyles.gaugeValueDark),
          ],
        ),
      ),
    );
  }
}
