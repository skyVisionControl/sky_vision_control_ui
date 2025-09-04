// sensor_dashboard_page.dart (güvenli tam sürüm)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/flight/sensor_data.dart';
import '../../providers/flight_providers.dart';

// import ettiğimiz özel widget'lar
import '../../widgets/sensors/accel_pressure_altitude_display.dart';
import '../../widgets/sensors/speed_gauge.dart';
import '../../widgets/sensors/humidity_gauge.dart';
import '../../widgets/sensors/temperature_gauge.dart';
import '../../widgets/sensors/direction_compass.dart';
import '../../widgets/sensors/gps_display.dart';

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

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Üst kısım → hız göstergesi + irtifa
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Expanded(child: _buildOrPlaceholder(_find(sensors, SensorType.speed), (s) => SpeedGauge(sensor: s))),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Orta kısım → nem, sıcaklık, yön, dikey hız
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(child: _buildOrPlaceholder(_find(sensors, SensorType.humidity), (s) => HumidityGauge(sensor: s))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildOrPlaceholder(_find(sensors, SensorType.temperature), (s) => TemperatureGauge(sensor: s))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildOrPlaceholder(_find(sensors, SensorType.direction), (s) => DirectionCompass(sensor: s))),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Alt kısım → GPS, ivme, açısal hız
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: _buildOrPlaceholder(
                        _find(sensors, SensorType.gpsPosition),
                            (s) => GpsDisplay(sensor: s),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: AccelPressureAltitudeDisplay(
                        acceleration: _find(sensors, SensorType.acceleration),
                        pressure: _find(sensors, SensorType.pressure),
                        altitude: _find(sensors, SensorType.altitude),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sensör listesinden istenen tipi bul (bulunamazsa null döner)
  SensorData? _find(List<SensorData> sensors, SensorType type) {
    try {
      return sensors.firstWhere((s) => s.type == type);
    } catch (_) {
      return null;
    }
  }

  /// Eğer sensör varsa widget göster, yoksa placeholder
  Widget _buildOrPlaceholder(SensorData? sensor, Widget Function(SensorData) builder) {
    if (sensor == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            "Veri yok",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    return builder(sensor);
  }
}
