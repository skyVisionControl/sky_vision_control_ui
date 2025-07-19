// gps_position_card.dart - tam düzeltilmiş versiyon
import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/domain/entities/sensor_data.dart';

class GPSPositionCard extends StatelessWidget {
  final double latitude;
  final double longitude;
  final bool hasSignal;
  final AlertLevel alertLevel;

  const GPSPositionCard({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.hasSignal,
    required this.alertLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GPS Konumu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  hasSignal ? Icons.gps_fixed : Icons.gps_off,
                  color: hasSignal ? _getAlertColor() : Colors.grey,
                  size: 20,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // GPS durumu
            if (!hasSignal) ...[
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.signal_cellular_connected_no_internet_0_bar,
                      color: Colors.grey,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GPS sinyali yok. Konum doğru olmayabilir.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Koordinatlar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Enlem: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _formatCoordinate(latitude, true),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'Boylam: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _formatCoordinate(longitude, false),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Harita butonu
            Expanded(
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: hasSignal ? () => _openMap(context) : null,
                  icon: const Icon(Icons.map),
                  label: const Text('Haritada Göster'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: hasSignal ? AppColors.primary : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor() {
    switch (alertLevel) {
      case AlertLevel.warning:
        return AppColors.warning;
      case AlertLevel.critical:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  String _formatCoordinate(double value, bool isLatitude) {
    final direction = isLatitude
        ? (value >= 0 ? 'K' : 'G')
        : (value >= 0 ? 'D' : 'B');

    final absValue = value.abs();
    final degrees = absValue.floor();
    final minutes = ((absValue - degrees) * 60).floor();
    final seconds = (((absValue - degrees) * 60 - minutes) * 60).toStringAsFixed(2);

    return '$degrees° $minutes\' $seconds" $direction';
  }

  void _openMap(BuildContext context) {
    // TODO: Harita görünümünü açma fonksiyonu
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Harita Görünümü'),
        content: const Text('Bu özellik henüz uygulanmadı. Gerçek uygulamada burada harita görünecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}