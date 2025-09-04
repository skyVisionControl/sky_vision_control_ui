// onboarding_view_model.dart
//
// Onboarding süreci için view model.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapadokya_balon_app/domain/entities/onboarding/checklist_item.dart';
import 'package:kapadokya_balon_app/domain/entities/onboarding/onboarding_status.dart';
import 'package:kapadokya_balon_app/domain/usecases/onboarding/complete_alcohol_test_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/onboarding/complete_checklist_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/onboarding/complete_face_recognition_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/onboarding/get_checklist_items_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/onboarding/get_onboarding_status_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/onboarding/update_checklist_item_usecase.dart';

class OnboardingState {
  final bool isLoading;
  final String? errorMessage;
  final OnboardingStatus? status;
  final List<ChecklistItem> checklistItems;
  final bool isFaceRecognitionProcessing;
  final bool isAlcoholTestProcessing;
  final bool isChecklistSubmitting;
  final bool isFaceRecognitionCompleted;

  OnboardingState({
    this.isLoading = false,
    this.errorMessage,
    this.status,
    this.checklistItems = const [],
    this.isFaceRecognitionProcessing = false,
    this.isAlcoholTestProcessing = false,
    this.isChecklistSubmitting = false,
    this.isFaceRecognitionCompleted = false,
  });

  OnboardingState copyWith({
    bool? isLoading,
    String? errorMessage,
    OnboardingStatus? status,
    List<ChecklistItem>? checklistItems,
    bool? isFaceRecognitionProcessing,
    bool? isAlcoholTestProcessing,
    bool? isChecklistSubmitting,
    bool? isFaceRecognitionCompleted,
  }) {
    return OnboardingState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      status: status ?? this.status,
      checklistItems: checklistItems ?? this.checklistItems,
      isFaceRecognitionProcessing: isFaceRecognitionProcessing ?? this.isFaceRecognitionProcessing,
      isAlcoholTestProcessing: isAlcoholTestProcessing ?? this.isAlcoholTestProcessing,
      isChecklistSubmitting: isChecklistSubmitting ?? this.isChecklistSubmitting,
      isFaceRecognitionCompleted: isFaceRecognitionCompleted ?? this.isFaceRecognitionCompleted,
    );
  }
}

class OnboardingViewModel extends StateNotifier<OnboardingState> {
  final GetOnboardingStatusUseCase _getOnboardingStatusUseCase;
  final CompleteFaceRecognitionUseCase _completeFaceRecognitionUseCase;
  final CompleteAlcoholTestUseCase _completeAlcoholTestUseCase;
  final GetChecklistItemsUseCase _getChecklistItemsUseCase;
  final UpdateChecklistItemUseCase _updateChecklistItemUseCase;
  final CompleteChecklistUseCase _completeChecklistUseCase;

  OnboardingViewModel(
      this._getOnboardingStatusUseCase,
      this._completeFaceRecognitionUseCase,
      this._completeAlcoholTestUseCase,
      this._getChecklistItemsUseCase,
      this._updateChecklistItemUseCase,
      this._completeChecklistUseCase,
      ) : super(OnboardingState());

  // Onboarding durumunu yükle
  Future<void> loadOnboardingStatus() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getOnboardingStatusUseCase();

    result.fold(
          (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
          (status) => state = state.copyWith(
        isLoading: false,
        status: status,
      ),
    );
  }

  void setFaceRecognitionCompleted(bool isCompleted) {
    state = state.copyWith(
      isFaceRecognitionCompleted: isCompleted,
    );
  }

  // Yüz tanıma adımını tamamla
  Future<void> completeFaceRecognition() async {
    state = state.copyWith(isFaceRecognitionProcessing: true, errorMessage: null);

    final result = await _completeFaceRecognitionUseCase();

    result.fold(
          (failure) => state = state.copyWith(
        isFaceRecognitionProcessing: false,
        errorMessage: failure.message,
      ),
          (status) => state = state.copyWith(
        isFaceRecognitionProcessing: false,
        status: status,
      ),
    );
  }

  // Alkol testini tamamla
  Future<void> completeAlcoholTest(double alcoholLevel) async {
    state = state.copyWith(isAlcoholTestProcessing: true, errorMessage: null);

    final result = await _completeAlcoholTestUseCase(alcoholLevel);

    result.fold(
          (failure) => state = state.copyWith(
        isAlcoholTestProcessing: false,
        errorMessage: failure.message,
      ),
          (status) => state = state.copyWith(
        isAlcoholTestProcessing: false,
        status: status,
      ),
    );
  }

  // Kontrol listesi öğelerini yükle
  Future<void> loadChecklistItems() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getChecklistItemsUseCase();

    result.fold(
          (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
          (items) => state = state.copyWith(
        isLoading: false,
        checklistItems: items,
      ),
    );
  }

  // Kontrol listesi öğesini güncelle
  Future<void> updateChecklistItem(ChecklistItem item) async {
    // Yerel state'i hemen güncelle (optimistik UI güncellemesi)
    final updatedItems = state.checklistItems.map((i) =>
    i.id == item.id ? item : i
    ).toList();

    state = state.copyWith(checklistItems: updatedItems);

    // Gerçek güncellemeyi yap
    final result = await _updateChecklistItemUseCase(item);

    result.fold(
          (failure) {
        // Hata durumunda eski listeye geri dön
        final originalItems = state.checklistItems.map((i) =>
        i.id == item.id ? state.checklistItems.firstWhere((o) => o.id == item.id) : i
        ).toList();

        state = state.copyWith(
          checklistItems: originalItems,
          errorMessage: failure.message,
        );
      },
          (updatedItem) {
        // Başarılı olursa, sunucudan gelen güncel öğeyi kullan
        final serverUpdatedItems = state.checklistItems.map((i) =>
        i.id == updatedItem.id ? updatedItem : i
        ).toList();

        state = state.copyWith(
          checklistItems: serverUpdatedItems,
        );
      },
    );
  }

  // Kontrol listesini tamamla
  Future<void> completeChecklist() async {
    state = state.copyWith(isChecklistSubmitting: true, errorMessage: null);

    final result = await _completeChecklistUseCase();

    result.fold(
          (failure) => state = state.copyWith(
        isChecklistSubmitting: false,
        errorMessage: failure.message,
      ),
          (status) => state = state.copyWith(
        isChecklistSubmitting: false,
        status: status,
      ),
    );
  }

  // Hata mesajını temizle
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}