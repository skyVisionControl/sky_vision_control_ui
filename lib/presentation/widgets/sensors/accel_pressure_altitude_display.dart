import 'package:flutter/material.dart';
import '../../../domain/entities/sensor_data.dart';

class AccelPressureAltitudeDisplay extends StatelessWidget {
  final SensorData? acceleration;
  final SensorData? pressure;
  final SensorData? altitude;

  const AccelPressureAltitudeDisplay({
    super.key,
    this.acceleration,
    this.pressure,
    this.altitude,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildRow("İvme", acceleration),
          const SizedBox(height: 8),
          _buildRow("Basınç", pressure),
          const SizedBox(height: 8),
          _buildRow("İrtifa", altitude),
        ],
      ),
    );
  }

  Widget _buildRow(String label, SensorData? data) {
    return Text(
      data != null
          ? "$label: ${data.value.toStringAsFixed(2)} ${data.unit}"
          : "$label: Veri yok",
      style: const TextStyle(color: Colors.white, fontSize: 14),
    );
  }
}
