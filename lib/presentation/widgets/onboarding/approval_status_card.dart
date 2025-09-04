// approval_status_card.dart
//
// Uçuş onay durumunu gösteren kart bileşeni.
// Onay bekliyor, onaylandı ve reddedildi durumlarını destekler.

// approval_status_card.dart
//
// Uçuş onay durumunu gösteren kart bileşeni.
// Onay bekliyor, onaylandı ve reddedildi durumlarını destekler.
//
// Yazan: Deniz Dogan
// Tarih: 2025-07-19

import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/domain/entities/onboarding/onboarding_status.dart';


class ApprovalStatusCard extends StatelessWidget {
  final ApprovalStatus status;
  final String? approverName;
  final DateTime? approvalTime;
  final String? rejectionReason;

  const ApprovalStatusCard({
    Key? key,
    required this.status,
    this.approverName,
    this.approvalTime,
    this.rejectionReason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getStatusColor().withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Durum ikonu
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor().withOpacity(0.1),
              ),
              child: Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 40,
              ),
            ),

            const SizedBox(height: 16),

            // Durum başlığı
            Text(
              _getStatusTitle(),
              style: TextStyles.heading3.copyWith(
                color: _getStatusColor(),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Durum açıklaması
            Text(
              _getStatusDescription(),
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Onay detayları (onay veya red için)
            if (status != ApprovalStatus.pending) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (approverName != null) ...[
                      _buildDetailRow(
                        icon: Icons.person_outline,
                        label: 'Onaylayan:',
                        value: approverName!,
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (approvalTime != null) ...[
                      _buildDetailRow(
                        icon: Icons.access_time,
                        label: 'Zaman:',
                        value: _formatDate(approvalTime!),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (status == ApprovalStatus.rejected && rejectionReason != null) ...[
                      _buildDetailRow(
                        icon: Icons.info_outline,
                        label: 'Red Nedeni:',
                        value: rejectionReason!,
                        isMultiLine: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Bekleme animasyonu (bekliyor durumu için)
            if (status == ApprovalStatus.pending) ...[
              const SizedBox(height: 16),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
                  strokeWidth: 3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: _getStatusColor(),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case ApprovalStatus.pending:
        return AppColors.warning;
      case ApprovalStatus.approved:
        return AppColors.success;
      case ApprovalStatus.rejected:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case ApprovalStatus.pending:
        return Icons.hourglass_empty;
      case ApprovalStatus.approved:
        return Icons.check_circle_outline;
      case ApprovalStatus.rejected:
        return Icons.cancel_outlined;
    }
  }

  String _getStatusTitle() {
    switch (status) {
      case ApprovalStatus.pending:
        return 'Onay Bekleniyor';
      case ApprovalStatus.approved:
        return 'Uçuş Onaylandı';
      case ApprovalStatus.rejected:
        return 'Uçuş Reddedildi';
    }
  }

  String _getStatusDescription() {
    switch (status) {
      case ApprovalStatus.pending:
        return 'Uçuş talebiniz sivil havacılık yetkilisi tarafından inceleniyor. Lütfen bekleyiniz.';
      case ApprovalStatus.approved:
        return 'Uçuş talebiniz onaylandı. Uçuşa başlayabilirsiniz.';
      case ApprovalStatus.rejected:
        return 'Uçuş talebiniz reddedildi. Lütfen aşağıdaki nedenleri inceleyin.';
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}