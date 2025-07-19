// onboarding_repository.dart
//
// Uçuş öncesi onboarding sürecini yöneten repository arayüzü.

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/entities/checklist_item.dart';
import 'package:kapadokya_balon_app/domain/entities/onboarding_status.dart';

abstract class OnboardingRepository {
  /// Mevcut onboarding durumunu getirir
  Future<Either<Failure, OnboardingStatus>> getOnboardingStatus();

  /// Yüz tanıma adımını tamamlar
  Future<Either<Failure, OnboardingStatus>> completeFaceRecognition();

  /// Alkolmetre testini tamamlar
  Future<Either<Failure, OnboardingStatus>> completeAlcoholTest(double alcoholLevel);

  /// Kontrol listesindeki bir öğeyi günceller
  Future<Either<Failure, ChecklistItem>> updateChecklistItem(ChecklistItem item);

  /// Tüm kontrol listesi öğelerini getirir
  Future<Either<Failure, List<ChecklistItem>>> getChecklistItems();

  /// Tüm kontrol listesini tamamlar
  Future<Either<Failure, OnboardingStatus>> completeChecklist();

  /// Onay durumunu günceller (test için)
  Future<Either<Failure, OnboardingStatus>> updateApprovalStatus(
      ApprovalStatus status, {String? rejectionReason}
      );

  /// Onboarding sürecini sıfırlar
  Future<Either<Failure, void>> resetOnboarding();
}