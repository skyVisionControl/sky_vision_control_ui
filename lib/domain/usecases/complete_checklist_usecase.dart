// complete_checklist_usecase.dart
//
// Kontrol listesini tamamlayan use case.

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/entities/onboarding_status.dart';
import 'package:kapadokya_balon_app/domain/repositories/onboarding_repository.dart';

class CompleteChecklistUseCase {
  final OnboardingRepository repository;

  CompleteChecklistUseCase(this.repository);

  Future<Either<Failure, OnboardingStatus>> call() {
    return repository.completeChecklist();
  }
}