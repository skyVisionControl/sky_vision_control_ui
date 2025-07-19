// checklist_item_model.dart
//
// ChecklistItem entity'sinin data layer modeli.

import 'package:kapadokya_balon_app/domain/entities/checklist_item.dart';

class ChecklistItemModel extends ChecklistItem {
  const ChecklistItemModel({
    required String id,
    required String title,
    String? description,
    bool isCompleted = false,
    bool isMandatory = true,
    String? note,
    required String category,
  }) : super(
    id: id,
    title: title,
    description: description,
    isCompleted: isCompleted,
    isMandatory: isMandatory,
    note: note,
    category: category,
  );

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isMandatory: json['isMandatory'] as bool? ?? true,
      note: json['note'] as String?,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'isMandatory': isMandatory,
      'note': note,
      'category': category,
    };
  }

  ChecklistItemModel copyWithModel({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isMandatory,
    String? note,
    String? category,
  }) {
    return ChecklistItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isMandatory: isMandatory ?? this.isMandatory,
      note: note ?? this.note,
      category: category ?? this.category,
    );
  }
}