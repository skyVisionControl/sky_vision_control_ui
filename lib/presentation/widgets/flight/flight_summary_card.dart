// flight_summary_card.dart

import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/domain/entities/flight/flight_status.dart';

class FlightSummaryCard extends StatelessWidget {
  final FlightStatus flightStatus;
  final Function(FlightPhase) onPhaseChange;

  const FlightSummaryCard({
    Key? key,
    required this.flightStatus,
    required this.onPhaseChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getPhaseColor().withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 24),
            _buildFlightDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getPhaseColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getPhaseColor().withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getPhaseIcon(),
                size: 16,
                color: _getPhaseColor(),
              ),
              const SizedBox(width: 6),
              Text(
                _getPhaseText(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getPhaseColor(),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.edit, size: 18),
          onPressed: () => onPhaseChange(flightStatus.currentPhase),
          tooltip: 'Uçuş Evresini Değiştir',
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
        ),
      ],
    );
  }

  Widget _buildFlightDetails() {
    return Row(
      children: [
        // Uçuş detayları - sol kolon
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Uçuş ID', flightStatus.flightId),
              const SizedBox(height: 8),
              _buildDetailItem('Başlangıç', _formatTime(flightStatus.startTime)),
              const SizedBox(height: 8),
              _buildDetailItem('Süre', _formatDuration(flightStatus.flightDuration)),
            ],
          ),
        ),

        // Uçuş detayları - sağ kolon
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Yükseklik', '${flightStatus.currentAltitude.toStringAsFixed(0)} m'),
              const SizedBox(height: 8),
              _buildDetailItem('Hız', '${flightStatus.groundSpeed.toStringAsFixed(1)} km/h'),
              const SizedBox(height: 8),
              _buildDetailItem('Yakıt', '%${flightStatus.fuelLevel.toStringAsFixed(0)}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Color _getPhaseColor() {
    switch (flightStatus.currentPhase) {
      case FlightPhase.preparation:
        return Colors.blue;
      case FlightPhase.inflation:
        return Colors.orange;
      case FlightPhase.takeoff:
        return Colors.purple;
      case FlightPhase.climbing:
        return Colors.green;
      case FlightPhase.cruising:
        return AppColors.primary;
      case FlightPhase.descending:
        return Colors.amber;
      case FlightPhase.landing:
        return Colors.red;
      case FlightPhase.completed:
        return Colors.grey;
    }
  }

  IconData _getPhaseIcon() {
    switch (flightStatus.currentPhase) {
      case FlightPhase.preparation:
        return Icons.engineering;
      case FlightPhase.inflation:
        return Icons.air;
      case FlightPhase.takeoff:
        return Icons.flight_takeoff;
      case FlightPhase.climbing:
        return Icons.trending_up;
      case FlightPhase.cruising:
        return Icons.explore;
      case FlightPhase.descending:
        return Icons.trending_down;
      case FlightPhase.landing:
        return Icons.flight_land;
      case FlightPhase.completed:
        return Icons.check_circle;
    }
  }

  String _getPhaseText() {
    switch (flightStatus.currentPhase) {
      case FlightPhase.preparation:
        return 'Hazırlık';
      case FlightPhase.inflation:
        return 'Şişirme';
      case FlightPhase.takeoff:
        return 'Kalkış';
      case FlightPhase.climbing:
        return 'Yükseliş';
      case FlightPhase.cruising:
        return 'Seyir';
      case FlightPhase.descending:
        return 'Alçalma';
      case FlightPhase.landing:
        return 'İniş';
      case FlightPhase.completed:
        return 'Tamamlandı';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours saat $minutes dk';
  }
}