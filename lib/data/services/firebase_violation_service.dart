import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_base_service.dart';
import '../models/fire_detection_violation_model.dart';
import '../../domain/entities/fire_detection_violation.dart';
import '../../utils/id_generator.dart';

class FirebaseViolationService extends FirebaseBaseService {
  FirebaseViolationService({FirebaseFirestore? firestore}) : super(firestore: firestore);

  /// Yangın algılama ihlalini kaydet
  Future<String> logFireDetection({
    required String flightId,
    required double confidence,
    required String detectionType,
    String? imageUrl,
  }) async {
    try {
      final violationId = generateViolationId(flightId, 'fire');

      await firestore.collection('violations').doc('fireDetection').collection(flightId).doc(violationId).set({
        'id': violationId,
        'flightId': flightId,
        'violationUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'confidence': confidence,
        'detectionType': detectionType,
      });

      print('Fire detection violation logged with ID: $violationId');
      return violationId;
    } catch (e) {
      print('Error logging fire detection violation: $e');
      rethrow;
    }
  }

  /// Belirli bir uçuşa ait yangın algılama ihlallerini getir
  Future<List<FireDetectionViolation>> getFireDetectionsByFlightId(String flightId) async {
    try {
      final snapshot = await firestore
          .collection('violations')
          .doc('fireDetection')
          .collection(flightId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FireDetectionViolationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting fire detections: $e');
      rethrow;
    }
  }
}