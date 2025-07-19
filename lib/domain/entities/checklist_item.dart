// checklist_item.dart
//
// Uçuş öncesi kontrol listesi öğesini temsil eden entity.

import 'package:equatable/equatable.dart';

class ChecklistItem extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final bool isMandatory;
  final String? note;
  final String category;

  const ChecklistItem({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.isMandatory = true,
    this.note,
    required this.category,
  });

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isMandatory,
    String? note,
    String? category,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isMandatory: isMandatory ?? this.isMandatory,
      note: note ?? this.note,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
    id, title, description, isCompleted, isMandatory, note, category
  ];
}