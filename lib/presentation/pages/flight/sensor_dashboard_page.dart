import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/sensor_data.dart';
import '../../providers/flight_providers.dart';

class SensorDashboardPage extends ConsumerWidget {
  const SensorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flightState = ref.watch(flightViewModelProvider);

    if (flightState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (flightState.errorMessage != null) {
      return Scaffold(body: Center(child: Text(flightState.errorMessage!)));
    }

    final sensors = flightState.sensorData;
    final phase = flightState.flightStatus?.currentPhase ?? 'Bilinmiyor';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balon Kaptanı Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mevcut Uçuş Aşaması: $phase', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Sensör Verileri:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: sensors.length,
              itemBuilder: (context, index) {
                final sensor = sensors[index];
                return _buildSensorCard(sensor);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(SensorData sensor) {
    final color = _getAlertColor(sensor.alertLevel);
    final icon = _getSensorIcon(sensor.type);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              '${sensor.type.toString().split('.').last}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${sensor.value.toStringAsFixed(2)} ${sensor.unit}',
              style: const TextStyle(fontSize: 18),
            ),
            if (sensor.secondaryValue != null)
              Text(
                'İkincil: ${sensor.secondaryValue!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor(AlertLevel level) {
    switch (level) {
      case AlertLevel.none:
        return Colors.green;
      case AlertLevel.info:
        return Colors.blue;
      case AlertLevel.warning:
        return Colors.orange;
      case AlertLevel.critical:
        return Colors.red;
    }
  }

  IconData _getSensorIcon(SensorType type) {
    switch (type) {
      case SensorType.altitude:
        return Icons.height;
      case SensorType.temperature:
        return Icons.thermostat;
      case SensorType.pressure:
        return Icons.compress;
      case SensorType.direction:
        return Icons.explore;
      case SensorType.speed:
        return Icons.speed;
      case SensorType.fuelLevel:
        return Icons.local_gas_station;
      case SensorType.verticalSpeed:
        return Icons.trending_up;
      case SensorType.gpsPosition:
        return Icons.location_on;
      case SensorType.humidity:
        return Icons.water_drop;
      case SensorType.acceleration:
        return Icons.directions_run;
      case SensorType.angularVelocity:
        return Icons.rotate_right;
    }
  }
}