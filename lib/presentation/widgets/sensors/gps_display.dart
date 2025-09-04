// widgets/sensors/gps_display.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/flight/sensor_data.dart';
import '../../../core/themes/text_styles.dart';

class GpsDisplay extends StatelessWidget {
  final SensorData sensor;
  const GpsDisplay({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("GPS", style: TextStyles.gaugeTitle),
            Text('Enlem - Boylam',
                style: TextStyles.bodyLarge),
            Text('${sensor.value.toStringAsFixed(5)} - ${sensor.secondaryValue?.toStringAsFixed(5) ?? "-"}',
                style: TextStyles.gaugeValue),
          ],
        ),
      ),
    );
  }
}
