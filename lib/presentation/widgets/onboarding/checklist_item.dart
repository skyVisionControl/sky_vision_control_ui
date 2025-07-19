// checklist_item.dart
//
// Uçuş öncesi kontrol listesi öğesi bileşeni.
// Tamamlanmış/tamamlanmamış durumları ve not ekleme özelliği içerir.

import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';

class ChecklistItem extends StatelessWidget {
  final String title;
  final String? description;
  final bool isCompleted;
  final bool isMandatory;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onAddNote;
  final String? note;

  const ChecklistItem({
    Key? key,
    required this.title,
    this.description,
    required this.isCompleted,
    this.isMandatory = true,
    required this.onChanged,
    this.onAddNote,
    this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Onay kutusu
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) {
                    if (value != null) {
                      onChanged(value);
                    }
                  },
                  activeColor: AppColors.primary,
                ),

                const SizedBox(width: 8),

                // Başlık ve zorunluluk işareti
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (isMandatory) ...[
                        const SizedBox(width: 4),
                        const Text(
                          '*',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Not ekleme butonu
                if (onAddNote != null)
                  IconButton(
                    icon: const Icon(Icons.note_add_outlined, size: 20),
                    onPressed: onAddNote,
                    color: AppColors.secondary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),

            // Açıklama
            if (description != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],

            // Not varsa göster
            if (note != null && note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(left: 40),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note_outlined,
                      size: 16,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}