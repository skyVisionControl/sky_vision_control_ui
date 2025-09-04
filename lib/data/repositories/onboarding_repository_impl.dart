// onboarding_repository_impl.dart
//
// OnboardingRepository arayüzünün implementasyonu.

import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/core/utils/logger.dart';
import 'package:kapadokya_balon_app/data/datasources/onboarding_data_source.dart';
import 'package:kapadokya_balon_app/data/models/checklist_item_model.dart';
import 'package:kapadokya_balon_app/domain/entities/onboarding/checklist_item.dart';
import 'package:kapadokya_balon_app/domain/entities/onboarding/onboarding_status.dart';
import 'package:kapadokya_balon_app/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingDataSource dataSource;

  OnboardingRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, OnboardingStatus>> getOnboardingStatus() async {
    try {
      final result = await dataSource.getOnboardingStatus();
      return Right(result);
    } catch (e) {
      AppLogger.e('Onboarding durumu alınamadı: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OnboardingStatus>> completeFaceRecognition() async {
    try {
      final result = await dataSource.completeFaceRecognition();
      return Right(result);
    } catch (e) {
      AppLogger.e('Yüz tanıma tamamlanamadı: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OnboardingStatus>> completeAlcoholTest(double alcoholLevel) async {
    try {
      final result = await dataSource.completeAlcoholTest(alcoholLevel);
      return Right(result);
    } catch (e) {
      AppLogger.e('Alkol testi tamamlanamadı: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChecklistItem>> updateChecklistItem(ChecklistItem item) async {
    try {
      // ChecklistItem'dan yeni bir ChecklistItemModel oluştur
      final itemModel = ChecklistItemModel(
        id: item.id,
        title: item.title,
        description: item.description,
        isCompleted: item.isCompleted,
        isMandatory: item.isMandatory,
        note: item.note,
        category: item.category,
      );

      final result = await dataSource.updateChecklistItem(itemModel);
      return Right(result);
    } catch (e) {
      AppLogger.e('Kontrol listesi öğesi güncellenemedi: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChecklistItem>>> getChecklistItems() async {
    try {
      final result = await dataSource.getChecklistItems();
      return Right(result);
    } catch (e) {
      AppLogger.e('Kontrol listesi öğeleri alınamadı: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OnboardingStatus>> completeChecklist() async {
    try {
      final result = await dataSource.completeChecklist();
      return Right(result);
    } catch (e) {
      AppLogger.e('Kontrol listesi tamamlanamadı: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OnboardingStatus>> updateApprovalStatus(
      ApprovalStatus status, {String? rejectionReason}
      ) async {
    try {
      final result = await dataSource.updateApprovalStatus(status, rejectionReason: rejectionReason);
      return Right(result);
    } catch (e) {
      AppLogger.e('Onay durumu güncellenemedi: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetOnboarding() async {
    try {
      await dataSource.resetOnboarding();
      return const Right(null);
    } catch (e) {
      AppLogger.e('Onboarding sıfırlanamadı: $e');
      return Left(DataFailure(message: e.toString()));
    }
  }
}