// altitude_indicator.dart
//
// Yükseklik gösterge bileşeni.
// İrtifa değerini hem analog gösterge hem de dijital değer olarak görselleştirir.


import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class AltitudeIndicator extends StatelessWidget {
  final double altitude; // metre cinsinden
  final double maxAltitude;
  final bool isWarning;

  const AltitudeIndicator({
    Key? key,
    required this.altitude,
    this.maxAltitude = 3000, // 3000 metre varsayılan maksimum
    this.isWarning = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWarning
            ? const BorderSide(color: AppColors.error, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'İrtifa',
                  style: TextStyles.gaugeTitle,
                ),
                if (isWarning)
                  _buildWarningIndicator(),
              ],
            ),
            const SizedBox(height: 8),

            // Yükseklik göstergesi
            SizedBox(
              height: 140,
              child: SfLinearGauge(
                minimum: 0,
                maximum: maxAltitude,
                orientation: LinearGaugeOrientation.vertical,
                labelPosition: LinearLabelPosition.inside,
                tickPosition: LinearElementPosition.inside,
                showLabels: true,
                showTicks: true,
                interval: maxAltitude / 6,
                axisTrackStyle: const LinearAxisTrackStyle(
                  thickness: 12,
                  color: Colors.black12,
                  borderWidth: 1,
                  borderColor: Colors.grey,
                ),
                barPointers: [
                  LinearBarPointer(
                    value: altitude,
                    thickness: 12,
                    color: isWarning ? AppColors.error : AppColors.altitudeGauge,
                    position: LinearElementPosition.cross,
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.green,
                          Colors.yellow,
                          Colors.orange,
                          Colors.red,
                        ],
                        stops: const [0.25, 0.5, 0.75, 1.0],
                      ).createShader(bounds);
                    },
                  ),
                ],
                markerPointers: [
                  LinearWidgetPointer(
                    value: altitude,
                    position: LinearElementPosition.cross,
                    offset: 16,
                    child: Container(
                      width: 40,
                      height: 25,
                      decoration: BoxDecoration(
                        color: isWarning ? AppColors.error : AppColors.altitudeGauge,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          altitude.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                ranges: [
                  LinearGaugeRange(
                    startValue: 0,
                    endValue: maxAltitude * 0.25,
                    color: Colors.green.withOpacity(0.1),
                    startWidth: 12,
                    endWidth: 12,
                    position: LinearElementPosition.cross,
                  ),
                  LinearGaugeRange(
                    startValue: maxAltitude * 0.25,
                    endValue: maxAltitude * 0.5,
                    color: Colors.yellow.withOpacity(0.1),
                    startWidth: 12,
                    endWidth: 12,
                    position: LinearElementPosition.cross,
                  ),
                  LinearGaugeRange(
                    startValue: maxAltitude * 0.5,
                    endValue: maxAltitude * 0.75,
                    color: Colors.orange.withOpacity(0.1),
                    startWidth: 12,
                    endWidth: 12,
                    position: LinearElementPosition.cross,
                  ),
                  LinearGaugeRange(
                    startValue: maxAltitude * 0.75,
                    endValue: maxAltitude,
                    color: Colors.red.withOpacity(0.1),
                    startWidth: 12,
                    endWidth: 12,
                    position: LinearElementPosition.cross,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Değer gösterimi
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    altitude.toStringAsFixed(0),
                    style: TextStyles.gaugeValue.copyWith(
                      color: isWarning ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'm',
                    style: TextStyles.gaugeUnit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value > 0.5 ? 2 - (value * 2) : value * 2,
          child: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 20,
          ),
        );
      },
    );
  }
}