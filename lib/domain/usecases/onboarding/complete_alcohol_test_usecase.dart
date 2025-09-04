// complete_alcohol_test_usecase.dart
//
// Alkolmetre testini tamamlayan use case.

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/entities/onboarding/onboarding_status.dart';
import 'package:kapadokya_balon_app/domain/repositories/onboarding_repository.dart';

class CompleteAlcoholTestUseCase {
  final OnboardingRepository repository;

  CompleteAlcoholTestUseCase(this.repository);

  Future<Either<Failure, OnboardingStatus>> call(double alcoholLevel) {
    return repository.completeAlcoholTest(alcoholLevel);
  }
}