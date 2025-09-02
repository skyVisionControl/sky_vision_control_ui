// widgets/sensors/speed_gauge.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../domain/entities/sensor_data.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/text_styles.dart';

class SpeedGauge extends StatelessWidget {
  final SensorData sensor;

  const SpeedGauge({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SfRadialGauge(
        axes: [
          RadialAxis(
            minimum: 0,
            maximum: 120,
            startAngle: 180,
            endAngle: 0,
            axisLabelStyle: GaugeTextStyle(
              color: AppColors.textPrimaryDark,
            ),
            axisLineStyle: const AxisLineStyle(
              thickness: 0.15,
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            pointers: [
              NeedlePointer(
                value: sensor.value,
                needleColor: AppColors.primary,
                knobStyle: const KnobStyle(color: Colors.white),
              ),
            ],
            annotations: [
              GaugeAnnotation(
                widget: Text(
                  '${sensor.value.toStringAsFixed(1)} ${sensor.unit}',
                  style: TextStyles.gaugeValueDark,
                ),
                angle: 90,
                positionFactor: 0.8,
              ),
            ],
          )
        ],
      ),
    );
  }
}
