import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_base_service.dart';

/// Uçuş verilerinin Firebase'e kaydedilmesi için servis
class FirebaseFlightService extends FirebaseBaseService {
  FirebaseFlightService({FirebaseFirestore? firestore}) : super(firestore: firestore);

  /// Uçuş verisi oluştur veya güncelle
  Future<void> createOrUpdateFlight({
    required String flightId,
    required String captainId,
    String approvalStatus = 'bekliyor',
    String flightStatus = 'bekliyor',
  }) async {
    try {
      await firestore.collection('flights').doc(flightId).set({
        'id': flightId,
        'captainId': captainId,
        'approvalStatus': approvalStatus, // bekliyor, onaylandı, reddedildi
        'flightStatus': flightStatus,     // uçuşta, bekliyor, bitirdi
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Flight created/updated in Firebase: $flightId');
    } catch (e) {
      print('Error creating/updating flight in Firebase: $e');
      rethrow;
    }
  }

  /// Uçuş onay durumunu güncelle
  Future<void> updateFlightApprovalStatus({
    required String flightId,
    required String approvalStatus, // bekliyor, onaylandı, reddedildi
  }) async {
    try {
      await firestore.collection('flights').doc(flightId).update({
        'approvalStatus': approvalStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Flight approval status updated: $flightId -> $approvalStatus');
    } catch (e) {
      print('Error updating flight approval status: $e');
      rethrow;
    }
  }

  /// Uçuş durumunu güncelle
  Future<void> updateFlightStatus({
    required String flightId,
    required String flightStatus, // uçuşta, bekliyor, bitirdi
  }) async {
    try {
      await firestore.collection('flights').doc(flightId).update({
        'flightStatus': flightStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Flight status updated: $flightId -> $flightStatus');
    } catch (e) {
      print('Error updating flight status: $e');
      rethrow;
    }
  }

  /// Uçuş tamamlandığında çağrılır
  Future<void> completeChecklist({
    required String flightId,
  }) async {
    try {
      await firestore.collection('flights').doc(flightId).update({
        'checklistCompleted': true,
        'checklistCompletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Flight checklist marked as completed: $flightId');
    } catch (e) {
      print('Error marking checklist as completed: $e');
      rethrow;
    }
  }
}