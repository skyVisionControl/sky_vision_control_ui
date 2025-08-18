import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_base_service.dart';
import '../../domain/entities/checklist_item.dart';

/// Checklist verilerinin Firebase'e kaydedilmesi için servis
class FirebaseChecklistService extends FirebaseBaseService {
  FirebaseChecklistService({FirebaseFirestore? firestore}) : super(firestore: firestore);

  /// Checklist öğesini Firebase'e kaydet
  Future<void> saveChecklistItem({
    required ChecklistItem item,
    required String flightId,
    required String captainId,
  }) async {
    try {
      // Sadece gerekli verileri içeren basit bir yapı
      await firestore.collection('checklists').doc(item.id).set({
        'id': item.id,
        'flightId': flightId,
        'isCompleted': item.isCompleted,
        'checkTime': item.isCompleted ? FieldValue.serverTimestamp() : null,
      }, SetOptions(merge: true));

      print('Checklist item saved to Firebase: ${item.id}');
    } catch (e) {
      print('Error saving checklist item to Firebase: $e');
      rethrow; // Hata yönetimi için hatayı yukarı at
    }
  }

  /// Tamamlanan checklist öğelerini Firebase'e kaydet
  Future<void> saveCompletedChecklist({
    required List<ChecklistItem> items,
    required String flightId,
    required String captainId,
  }) async {
    try {
      final batch = firestore.batch();

      // Her checklist öğesini güncelle
      for (var item in items) {
        final docRef = firestore.collection('checklists').doc(item.id);
        batch.set(docRef, {
          'id': item.id,
          'flightId': flightId,
          'isCompleted': true,
          'checkTime': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      print('Completed checklist saved to Firebase with Flight ID: $flightId');
    } catch (e) {
      print('Error saving completed checklist to Firebase: $e');
      rethrow;
    }
  }
}