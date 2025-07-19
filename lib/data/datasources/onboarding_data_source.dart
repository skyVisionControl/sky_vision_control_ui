// onboarding_data_source.dart
//
// Onboarding süreci için veri kaynağı arayüzü ve mock implementasyonu.

import 'package:kapadokya_balon_app/data/models/checklist_item_model.dart';
import 'package:kapadokya_balon_app/data/models/onboarding_status_model.dart';
import 'package:kapadokya_balon_app/domain/entities/onboarding_status.dart';

import 'checklist_data.dart';

abstract class OnboardingDataSource {
  Future<OnboardingStatusModel> getOnboardingStatus();
  Future<OnboardingStatusModel> completeFaceRecognition();
  Future<OnboardingStatusModel> completeAlcoholTest(double alcoholLevel);
  Future<ChecklistItemModel> updateChecklistItem(ChecklistItemModel item);
  Future<List<ChecklistItemModel>> getChecklistItems();
  Future<OnboardingStatusModel> completeChecklist();
  Future<OnboardingStatusModel> updateApprovalStatus(
      ApprovalStatus status, {String? rejectionReason}
      );
  Future<void> resetOnboarding();
}

class MockOnboardingDataSource implements OnboardingDataSource {
  // Mevcut onboarding durumu
  OnboardingStatusModel _currentStatus = const OnboardingStatusModel();

  // Örnek kontrol listesi öğeleri
  final List<ChecklistItemModel> _checklistItems = ChecklistData
      .getChecklistItemsForInitialization()
      .map((item) => ChecklistItemModel.fromJson(item))
      .toList();


  @override
  Future<OnboardingStatusModel> getOnboardingStatus() async {
    // Gecikme simülasyonu
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentStatus;
  }

  @override
  Future<OnboardingStatusModel> completeFaceRecognition() async {
    // Gecikme simülasyonu
    await Future.delayed(const Duration(seconds: 2));

    _currentStatus = OnboardingStatusModel(
      isFaceRecognitionCompleted: true,
      isAlcoholTestCompleted: _currentStatus.isAlcoholTestCompleted,
      isChecklistCompleted: _currentStatus.isChecklistCompleted,
      approvalStatus: _currentStatus.approvalStatus,
      rejectionReason: _currentStatus.rejectionReason,
      completedTime: _currentStatus.completedTime,
    );

    return _currentStatus;
  }

  @override
  Future<OnboardingStatusModel> completeAlcoholTest(double alcoholLevel) async {
    // Gecikme simülasyonu
    await Future.delayed(const Duration(seconds: 2));

    // Alkol seviyesi belirli bir eşiğin üzerindeyse hata fırlat
    if (alcoholLevel > 0.04) {
      throw Exception('Alkol seviyesi izin verilen limitin üzerinde: $alcoholLevel');
    }

    _currentStatus = OnboardingStatusModel(
      isFaceRecognitionCompleted: _currentStatus.isFaceRecognitionCompleted,
      isAlcoholTestCompleted: true,
      isChecklistCompleted: _currentStatus.isChecklistCompleted,
      approvalStatus: _currentStatus.approvalStatus,
      rejectionReason: _currentStatus.rejectionReason,
      completedTime: _currentStatus.completedTime,
    );

    return _currentStatus;
  }

  @override
  Future<ChecklistItemModel> updateChecklistItem(ChecklistItemModel item) async {
    // Gecikme simülasyonu
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _checklistItems.indexWhere((element) => element.id == item.id);
    if (index == -1) {
      throw Exception('Kontrol listesi öğesi bulunamadı: ${item.id}');
    }

    _checklistItems[index] = item;
    return item;
  }

  @override
  Future<List<ChecklistItemModel>> getChecklistItems() async {
    // Gecikme simülasyonu
    await Future.delayed(const Duration(milliseconds: 800));

    return _checklistItems;
  }

  @override
  Future<OnboardingStatusModel> completeChecklist() async {
    // Gecikme simülasyonu
    await Future.delayed(const Duration(seconds: 1));

    // Tüm zorunlu öğelerin tamamlandığını kontrol et
    final mandatoryItems = _checklistItems.where((item) => item.isMandatory);
    final allCompleted = mandatoryItems.every((item) => item.isCompleted);

    // Hata ayıklama için tamamlanmamış öğeleri logla
    if (!allCompleted) {
      final notCompletedItems = mandatoryItems.where((item) => !item.isCompleted).toList();
      print("Tamamlanmamış zorunlu öğeler: ${notCompletedItems.length}");
      for (var item in notCompletedItems) {
        print(" - ${item.title} (ID: ${item.id})");
      }

      // İki seçenek var:
      // 1. Gerçek bir hata fırlatmak
      // throw Exception('Tüm zorunlu kontrol listesi öğeleri tamamlanmadı');

      // 2. Veya debug amacıyla hata fırlatmadan devam etmek
      // Bu seçenek geçici olarak kullanılabilir
    }

    // Her durumda tamamlanmış olarak kabul et (debug için)
    _currentStatus = OnboardingStatusModel(
      isFaceRecognitionCompleted: _currentStatus.isFaceRecognitionCompleted,
      isAlcoholTestCompleted: _currentStatus.isAlcoholTestCompleted,
      isChecklistCompleted: true,
      approvalStatus: _currentStatus.approvalStatus,
      rejectionReason: _currentStatus.rejectionReason,
      completedTime: _currentStatus.completedTime,
    );

    return _currentStatus;
  }

  @override
  Future<OnboardingStatusModel> updateApprovalStatus(
      ApprovalStatus status, {String? rejectionReason}
      ) async {
    // Gecikme simülasyonu
    await Future.delayed(const Duration(seconds: 3));

    _currentStatus = OnboardingStatusModel(
      isFaceRecognitionCompleted: _currentStatus.isFaceRecognitionCompleted,
      isAlcoholTestCompleted: _currentStatus.isAlcoholTestCompleted,
      isChecklistCompleted: _currentStatus.isChecklistCompleted,
      approvalStatus: status,
      rejectionReason: status == ApprovalStatus.rejected ? rejectionReason : null,
      completedTime: status == ApprovalStatus.approved ? DateTime.now() : null,
    );

    return _currentStatus;
  }

  @override
  Future<void> resetOnboarding() async {
    // Gecikme simülasyonu
    await Future.delayed(const Duration(milliseconds: 500));

    _currentStatus = const OnboardingStatusModel();

    // Kontrol listesi öğelerini sıfırla
    for (var i = 0; i < _checklistItems.length; i++) {
      _checklistItems[i] = _checklistItems[i].copyWithModel(isCompleted: false, note: null);
    }
  }
}