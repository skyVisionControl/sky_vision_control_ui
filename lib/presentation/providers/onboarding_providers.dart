// onboarding_providers.dart
//
// Onboarding süreci için provider tanımlamaları.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapadokya_balon_app/data/datasources/onboarding_data_source.dart';
import 'package:kapadokya_balon_app/data/repositories/onboarding_repository_impl.dart';
import 'package:kapadokya_balon_app/domain/repositories/onboarding_repository.dart';
import 'package:kapadokya_balon_app/domain/usecases/onboarding/complete_alcohol_test_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/onboarding/complete_checklist_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/onboarding/complete_face_recognition_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/onboarding/get_checklist_items_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/onboarding/get_onboarding_status_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/onboarding/update_checklist_item_usecase.dart';
import 'package:kapadokya_balon_app/presentation/viewmodels/onboarding_view_model.dart';

// Data Source Provider
final onboardingDataSourceProvider = Provider<OnboardingDataSource>((ref) {
  return MockOnboardingDataSource();
});

// Repository Provider
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final dataSource = ref.watch(onboardingDataSourceProvider);
  return OnboardingRepositoryImpl(dataSource);
});

// Use Case Providers
final getOnboardingStatusUseCaseProvider = Provider<GetOnboardingStatusUseCase>((ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return GetOnboardingStatusUseCase(repository);
});

final completeFaceRecognitionUseCaseProvider = Provider<CompleteFaceRecognitionUseCase>((ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return CompleteFaceRecognitionUseCase(repository);
});

final completeAlcoholTestUseCaseProvider = Provider<CompleteAlcoholTestUseCase>((ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return CompleteAlcoholTestUseCase(repository);
});

final getChecklistItemsUseCaseProvider = Provider<GetChecklistItemsUseCase>((ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return GetChecklistItemsUseCase(repository);
});

final updateChecklistItemUseCaseProvider = Provider<UpdateChecklistItemUseCase>((ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return UpdateChecklistItemUseCase(repository);
});

final completeChecklistUseCaseProvider = Provider<CompleteChecklistUseCase>((ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return CompleteChecklistUseCase(repository);
});

// ViewModel Provider
final onboardingViewModelProvider = StateNotifierProvider<OnboardingViewModel, OnboardingState>((ref) {
  return OnboardingViewModel(
    ref.watch(getOnboardingStatusUseCaseProvider),
    ref.watch(completeFaceRecognitionUseCaseProvider),
    ref.watch(completeAlcoholTestUseCaseProvider),
    ref.watch(getChecklistItemsUseCaseProvider),
    ref.watch(updateChecklistItemUseCaseProvider),
    ref.watch(completeChecklistUseCaseProvider),
  );
});