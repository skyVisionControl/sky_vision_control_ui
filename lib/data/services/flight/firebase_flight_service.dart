// lib/data/services/firebase_flight_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_base_service.dart';
import '../../../utils/id_generator.dart';

class FirebaseFlightService extends FirebaseBaseService {
  FirebaseFlightService({FirebaseFirestore? firestore}) : super(firestore: firestore);

  /// Uçuş verisi oluştur
  Future<String> createFlight({
    required String captainId,
    String approvalStatus = 'bekliyor',
    String flightStatus = 'bekliyor',
    String? telemetryUserId, // ✅ RTDB ilişkilendirme için opsiyonel parametre
  }) async {
    try {
      final flightId = generateFlightId(captainId);

      // RTDB yolu: Field_A/{uid}/telemetri
      final String? rtdbUser = telemetryUserId ?? captainId; // istersen burada sabit UID kullanabilirsin
      final telemetry = rtdbUser == null
          ? null
          : {
        'rtdbUserId': rtdbUser,
        'rtdbPath': '$rtdbUser/telemetri',
        'rtdbUrl': 'https://sky-vision-control-5ca1b-default-rtdb.europe-west1.firebasedatabase.app',
      };

      await firestore.collection('flights').doc(flightId).set({
        'id': flightId,
        'captainId': captainId,
        'approvalStatus': approvalStatus, // bekliyor, onaylandı, reddedildi
        'flightStatus': flightStatus,     // uçuşta, bekliyor, bitirdi
        'currentPhase': 'preparation',
        'startTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (telemetry != null) 'telemetry': telemetry, // ✅ RTDB ilişkilendirmesi
      });

      print('Flight created in Firebase: $flightId');
      return flightId;
    } catch (e) {
      print('Error creating flight in Firebase: $e');
      rethrow;
    }
  }

  /// Sonradan telemetri bilgisi bağlamak istersen:
  Future<void> linkTelemetryToFlight({
    required String flightId,
    required String telemetryUserId,
  }) async {
    try {
      await firestore.collection('flights').doc(flightId).update({
        'telemetry': {
          'rtdbUserId': telemetryUserId,
          'rtdbPath': '$telemetryUserId/telemetri',
          'rtdbUrl': 'https://sky-vision-control-5ca1b-default-rtdb.europe-west1.firebasedatabase.app',
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error linking telemetry to flight: $e');
      rethrow;
    }
  }

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
