// complete_face_recognition_usecase.dart
//
// Yüz tanıma adımını tamamlayan use case.

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/entities/onboarding_status.dart';
import 'package:kapadokya_balon_app/domain/repositories/onboarding_repository.dart';

class CompleteFaceRecognitionUseCase {
  final OnboardingRepository repository;

  CompleteFaceRecognitionUseCase(this.repository);

  Future<Either<Failure, OnboardingStatus>> call() {
    return repository.completeFaceRecognition();
  }
}