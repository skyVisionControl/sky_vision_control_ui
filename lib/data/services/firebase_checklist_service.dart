import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/checklist_item.dart';

class FirebaseChecklistService {
  final FirebaseFirestore _firestore;

  FirebaseChecklistService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Bir checklist öğesini Firebase'e kaydet
  Future<void> saveChecklistItem({
    required ChecklistItem item,
    required String flightId,
    required String captainId,
  }) async {
    try {
      await _firestore.collection('checklists').doc(item.id).set({
        'id': item.id,
        'title': item.title,
        'description': item.description,
        'isCompleted': item.isCompleted,
        'flightId': flightId,
        'captainId': captainId,
        'completedAt': item.isCompleted ? FieldValue.serverTimestamp() : null,
      }, SetOptions(merge: true));

      print('Checklist item saved to Firebase: ${item.id}');
    } catch (e) {
      print('Error saving checklist item to Firebase: $e');
    }
  }

  // Tüm checklist öğelerini Firebase'e kaydet
  Future<void> saveCompletedChecklist({
    required List<ChecklistItem> items,
    required String flightId,
    required String captainId,
  }) async {
    try {
      final batch = _firestore.batch();

      for (var item in items) {
        final docRef = _firestore.collection('checklists').doc(item.id);
        batch.set(docRef, {
          'id': item.id,
          'title': item.title,
          'description': item.description,
          'isCompleted': true,
          'flightId': flightId,
          'captainId': captainId,
          'completedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Uçuş durumunu da güncelle
      final flightRef = _firestore.collection('flights').doc(flightId);
      batch.set(flightRef, {
        'id': flightId,
        'captainId': captainId,
        'flightDate': DateTime.now().toIso8601String(),
        'status': 'active',
        'checklistCompleted': true,
        'checklistCompletedAt': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));

      await batch.commit();
      print('Completed checklist saved to Firebase with Flight ID: $flightId');
    } catch (e) {
      print('Error saving completed checklist to Firebase: $e');
    }
  }

  // Uçuş verisi oluştur veya güncelle
  Future<void> createOrUpdateFlight({
    required String flightId,
    required String captainId,
  }) async {
    try {
      await _firestore.collection('flights').doc(flightId).set({
        'id': flightId,
        'captainId': captainId,
        'flightDate': DateTime.now().toIso8601String(),
        'status': 'active',
        'checklistCompleted': false,
        'checklistCompletedAt': null
      }, SetOptions(merge: true));

      print('Flight created/updated in Firebase: $flightId');
    } catch (e) {
      print('Error creating/updating flight in Firebase: $e');
    }
  }
}