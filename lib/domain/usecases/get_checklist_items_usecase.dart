// get_checklist_items_usecase.dart
//
// Kontrol listesi öğelerini getiren use case.

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/entities/checklist_item.dart';
import 'package:kapadokya_balon_app/domain/repositories/onboarding_repository.dart';

class GetChecklistItemsUseCase {
  final OnboardingRepository repository;

  GetChecklistItemsUseCase(this.repository);

  Future<Either<Failure, List<ChecklistItem>>> call() {
    return repository.getChecklistItems();
  }
}