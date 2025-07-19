// alert_notification_card.dart
//
// Uyarı ve ihlal bildirimlerini gösteren kart bileşeni.
// Farklı önem seviyelerini ve bildirim türlerini destekler.

import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

class AlertNotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;
  final bool isNew;

  const AlertNotificationCard({
    Key? key,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
    this.isNew = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getSeverityColor(),
          width: severity == AlertSeverity.critical ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Yeni bildirimi belirtmek için üst kısımda çizgi
          if (isNew)
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: _getSeverityColor(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),

          // Bildirim içeriği
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık ve önem seviyesi
                Row(
                  children: [
                    _buildSeverityIndicator(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyles.heading4.copyWith(
                          color: _getSeverityColor(),
                        ),
                      ),
                    ),
                    if (onDismiss != null) ...[
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: onDismiss,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Zaman bilgisi
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (isNew) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getSeverityColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Yeni',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getSeverityColor(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Mesaj
                Text(
                  message,
                  style: TextStyles.bodyMedium,
                ),

                if (onAction != null && actionLabel != null) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getSeverityColor(),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(actionLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityIndicator() {
    IconData iconData;

    switch (severity) {
      case AlertSeverity.low:
        iconData = Icons.info_outline;
        break;
      case AlertSeverity.medium:
        iconData = Icons.warning_amber_outlined;
        break;
      case AlertSeverity.high:
        iconData = Icons.error_outline;
        break;
      case AlertSeverity.critical:
        return _buildFlashingIcon();
    }

    return Icon(
      iconData,
      color: _getSeverityColor(),
      size: 24,
    );
  }

  Widget _buildFlashingIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value > 0.5 ? 2 - (value * 2) : value * 2,
          child: const Icon(
            Icons.error,
            color: AppColors.error,
            size: 24,
          ),
        );
      },
    );
  }

  Color _getSeverityColor() {
    switch (severity) {
      case AlertSeverity.low:
        return AppColors.info;
      case AlertSeverity.medium:
        return AppColors.warning;
      case AlertSeverity.high:
        return Colors.deepOrange;
      case AlertSeverity.critical:
        return AppColors.error;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}