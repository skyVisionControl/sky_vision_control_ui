// flight_summary_card.dart
//
// Uçuş özeti bilgilerini gösteren kart bileşeni.
// Uçuş sonlandırma ekranı için kullanılır.

import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';

class FlightSummaryCard extends StatelessWidget {
  final String flightId;
  final DateTime startTime;
  final DateTime? endTime;
  final String pilotName;
  final String balloonId;
  final double maxAltitude;
  final double avgSpeed;
  final String route;
  final int passengerCount;
  final bool hasIncident;

  const FlightSummaryCard({
    Key? key,
    required this.flightId,
    required this.startTime,
    this.endTime,
    required this.pilotName,
    required this.balloonId,
    required this.maxAltitude,
    required this.avgSpeed,
    required this.route,
    required this.passengerCount,
    this.hasIncident = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Duration? duration = endTime?.difference(startTime);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                const Icon(
                  Icons.flight_takeoff,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Uçuş Özeti',
                  style: TextStyles.heading3,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: endTime != null
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    endTime != null ? 'Tamamlandı' : 'Devam Ediyor',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: endTime != null
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Uçuş detayları
            _buildDetailRow(
              icon: Icons.numbers,
              label: 'Uçuş ID:',
              value: flightId,
            ),

            _buildDetailRow(
              icon: Icons.person,
              label: 'Pilot:',
              value: pilotName,
            ),

            _buildDetailRow(
              icon: Icons.local_offer_outlined,
              label: 'Balon ID:',
              value: balloonId,
            ),

            _buildDetailRow(
              icon: Icons.access_time,
              label: 'Başlangıç:',
              value: _formatDateTime(startTime),
            ),

            if (endTime != null)
              _buildDetailRow(
                icon: Icons.access_time_filled,
                label: 'Bitiş:',
                value: _formatDateTime(endTime!),
              ),

            if (duration != null)
              _buildDetailRow(
                icon: Icons.timelapse,
                label: 'Süre:',
                value: _formatDuration(duration),
              ),

            _buildDetailRow(
              icon: Icons.height,
              label: 'Maks. İrtifa:',
              value: '${maxAltitude.toStringAsFixed(0)} m',
            ),

            _buildDetailRow(
              icon: Icons.speed,
              label: 'Ortalama Hız:',
              value: '${avgSpeed.toStringAsFixed(1)} km/h',
            ),

            _buildDetailRow(
              icon: Icons.route,
              label: 'Rota:',
              value: route,
            ),

            _buildDetailRow(
              icon: Icons.people,
              label: 'Yolcu Sayısı:',
              value: passengerCount.toString(),
            ),

            if (hasIncident)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Bu uçuşta bir olay/kaza rapor edildi.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '$hours saat $minutes dakika';
  }
}
