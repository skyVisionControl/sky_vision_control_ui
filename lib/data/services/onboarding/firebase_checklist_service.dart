import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_base_service.dart';
import '../../../domain/entities/onboarding/checklist_item.dart';
import '../../../utils/id_generator.dart';

/// Checklist verilerinin Firebase'e kaydedilmesi için servis
class FirebaseChecklistService extends FirebaseBaseService {
  FirebaseChecklistService({FirebaseFirestore? firestore}) : super(firestore: firestore);

  /// Tamamlanan checklist'i Firebase'e kaydet (tek bir belge olarak)
  Future<String> saveCompletedChecklist({
    required List<ChecklistItem> items,
    required String flightId,
    required String captainId,
  }) async {
    try {
      // Checklist için benzersiz bir ID oluştur
      final checklistId = generateChecklistId(captainId);

      // Tamamlanan checklist items sayısını al
      final completedItemsCount = items.where((item) => item.isCompleted).length;

      // Toplam checklist items sayısı
      final totalItemsCount = items.length;

      // Checklist belgesini oluştur
      await firestore.collection('checklists').doc(checklistId).set({
        'id': checklistId,
        'flightId': flightId,
        'isCompleted': completedItemsCount == totalItemsCount,
        'completedItemsCount': completedItemsCount,
        'totalItemsCount': totalItemsCount,
        'checkTime': FieldValue.serverTimestamp(),
      });

      print('Completed checklist saved to Firebase with ID: $checklistId');
      return checklistId;
    } catch (e) {
      print('Error saving completed checklist to Firebase: $e');
      rethrow;
    }
  }
}