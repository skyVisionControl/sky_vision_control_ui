// gauge_card.dart
//
// Sensör verilerini gösteren kart bileşeni.
// Analog gösterge ve dijital değer ile sensör bilgilerini görselleştirir.


import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GaugeCard extends StatelessWidget {
  final String title;
  final double value;
  final double minValue;
  final double maxValue;
  final String unit;
  final Color gaugeColor;
  final bool isWarning;
  final List<GaugeRange>? ranges;

  const GaugeCard({
    Key? key,
    required this.title,
    required this.value,
    this.minValue = 0,
    required this.maxValue,
    required this.unit,
    this.gaugeColor = AppColors.primary,
    this.isWarning = false,
    this.ranges,
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
                Text(
                  title,
                  style: TextStyles.gaugeTitle,
                ),
                // Uyarı durumunda yanıp sönen ikon
                if (isWarning)
                  _buildWarningIndicator(),
              ],
            ),
            const SizedBox(height: 8),

            // Gösterge
            SizedBox(
              height: 120,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: minValue,
                    maximum: maxValue,
                    startAngle: 150,
                    endAngle: 30,
                    radiusFactor: 0.8,
                    showLabels: true,
                    showTicks: true,
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.1,
                      color: gaugeColor.withOpacity(0.3),
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: value,
                        needleColor: gaugeColor,
                        knobStyle: KnobStyle(
                          knobRadius: 0.06,
                          color: gaugeColor,
                        ),
                        tailStyle: const TailStyle(
                          width: 3,
                          length: 0.15,
                        ),
                        needleLength: 0.7,
                        needleStartWidth: 1,
                        needleEndWidth: 3,
                      ),
                    ],
                    ranges: ranges,
                  ),
                ],
              ),
            ),

            // Değer ve birim
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value.toStringAsFixed(1),
                    style: TextStyles.gaugeValue.copyWith(
                      color: isWarning ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
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