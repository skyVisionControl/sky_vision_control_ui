// widgets/sensors/humidity_gauge.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../domain/entities/sensor_data.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/text_styles.dart';

class HumidityGauge extends StatelessWidget {
  final SensorData sensor;
  const HumidityGauge({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SfRadialGauge(
        axes: [
          RadialAxis(
            minimum: 0,
            maximum: 100,
            showLabels: false,
            showTicks: false,
            startAngle: 270,
            endAngle: 270,
            axisLineStyle: const AxisLineStyle(
              thickness: 0.15,
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            pointers: [
              RangePointer(
                value: sensor.value,
                color: AppColors.humidityGauge,
                width: 0.15,
                sizeUnit: GaugeSizeUnit.factor,
              )
            ],
            annotations: [
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Nem", style: TextStyles.gaugeTitle),
                    Text(
                      '${sensor.value.toStringAsFixed(1)}%',
                      style: TextStyles.gaugeValue,
                    ),
                  ],
                ),
                angle: 90,
                positionFactor: 0.1,
              )
            ],
          )
        ],
      ),
    );
  }
}
