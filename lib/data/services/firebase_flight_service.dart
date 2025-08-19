import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_base_service.dart';
import '../../utils/id_generator.dart';

/// Uçuş verilerinin Firebase'e kaydedilmesi için servis
class FirebaseFlightService extends FirebaseBaseService {
  FirebaseFlightService({FirebaseFirestore? firestore}) : super(firestore: firestore);

  /// Uçuş verisi oluştur
  Future<String> createFlight({
    required String captainId,
    String approvalStatus = 'bekliyor',
    String flightStatus = 'bekliyor',
  }) async {
    try {
      // Uçuş için benzersiz bir ID oluştur
      final flightId = generateFlightId(captainId);

      await firestore.collection('flights').doc(flightId).set({
        'id': flightId,
        'captainId': captainId,
        'approvalStatus': approvalStatus, // bekliyor, onaylandı, reddedildi
        'flightStatus': flightStatus,     // uçuşta, bekliyor, bitirdi
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Flight created in Firebase: $flightId');
      return flightId;
    } catch (e) {
      print('Error creating flight in Firebase: $e');
      rethrow;
    }
  }

  /// Uçuş kaydına checklist ID'sini ekle
  Future<void> addChecklistReference({
    required String flightId,
    required String checklistId,
  }) async {
    try {
      await firestore.collection('flights').doc(flightId).update({
        'checklistId': checklistId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Flight updated with checklist reference: $flightId -> $checklistId');
    } catch (e) {
      print('Error updating flight with checklist reference: $e');
      rethrow;
    }
  }
}