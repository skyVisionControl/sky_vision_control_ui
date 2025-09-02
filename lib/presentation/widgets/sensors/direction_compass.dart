// widgets/sensors/direction_compass.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/sensor_data.dart';
import '../../../core/themes/text_styles.dart';

class DirectionCompass extends StatelessWidget {
  final SensorData sensor;
  const DirectionCompass({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    final angle = sensor.value; // derece
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: angle * 3.1416 / 180,
              child: const Icon(Icons.navigation, size: 60),
            ),
            Text('${angle.toStringAsFixed(0)}°', style: TextStyles.gaugeValue),
          ],
        ),
      ),
    );
  }
}
