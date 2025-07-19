// gps_position_card.dart
//
// GPS koordinat bilgilerini gösteren kart bileşeni.
// Enlem, boylam ve bağlantı durumunu görselleştirir.


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';

class GPSPositionCard extends StatelessWidget {
  final double latitude;
  final double longitude;
  final bool hasGPSSignal;
  final bool isWarning;

  const GPSPositionCard({
    Key? key,
    required this.latitude,
    required this.longitude,
    this.hasGPSSignal = true,
    this.isWarning = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedLat = '${latitude.toStringAsFixed(6)}° ${latitude >= 0 ? 'K' : 'G'}';
    final formattedLng = '${longitude.toStringAsFixed(6)}° ${longitude >= 0 ? 'D' : 'B'}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWarning
            ? const BorderSide(color: AppColors.error, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve GPS durum göstergesi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GPS Konumu',
                  style: TextStyles.gaugeTitle,
                ),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasGPSSignal ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hasGPSSignal ? 'Bağlı' : 'Sinyal Yok',
                      style: TextStyle(
                        fontSize: 12,
                        color: hasGPSSignal ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Koordinat değerleri
            _buildCoordinateRow(
              icon: Icons.location_on_outlined,
              label: 'Enlem:',
              value: formattedLat,
              isDisabled: !hasGPSSignal,
            ),

            const SizedBox(height: 8),

            _buildCoordinateRow(
              icon: Icons.location_on_outlined,
              label: 'Boylam:',
              value: formattedLng,
              isDisabled: !hasGPSSignal,
            ),

            const SizedBox(height: 16),

            // Kopyala buton
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: hasGPSSignal ? () => _copyCoordinates(context) : null,
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Koordinatları Kopyala'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinateRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDisabled,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDisabled ? AppColors.textDisabled : AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDisabled ? AppColors.textDisabled : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDisabled ? AppColors.textDisabled : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _copyCoordinates(BuildContext context) async {
    final coordText = '$latitude, $longitude';
    await Clipboard.setData(ClipboardData(text: coordText));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Koordinatlar panoya kopyalandı'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}