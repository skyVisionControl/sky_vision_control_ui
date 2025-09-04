// update_checklist_item_usecase.dart
//
// Kontrol listesi öğesini güncelleyen use case.

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/entities/onboarding/checklist_item.dart';
import 'package:kapadokya_balon_app/domain/repositories/onboarding_repository.dart';

class UpdateChecklistItemUseCase {
  final OnboardingRepository repository;

  UpdateChecklistItemUseCase(this.repository);

  Future<Either<Failure, ChecklistItem>> call(ChecklistItem item) {
    return repository.updateChecklistItem(item);
  }
}