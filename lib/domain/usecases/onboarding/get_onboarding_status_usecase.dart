// get_onboarding_status_usecase.dart
//
// Mevcut onboarding durumunu getiren use case.
//
// Yazan: Deniz Dogan
// Tarih: 2025-07-18

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/entities/onboarding/onboarding_status.dart';
import 'package:kapadokya_balon_app/domain/repositories/onboarding_repository.dart';

class GetOnboardingStatusUseCase {
  final OnboardingRepository repository;

  GetOnboardingStatusUseCase(this.repository);

  Future<Either<Failure, OnboardingStatus>> call() {
    return repository.getOnboardingStatus();
  }
}