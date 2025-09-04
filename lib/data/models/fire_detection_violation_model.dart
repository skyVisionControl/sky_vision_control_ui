import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/fire_detection_violation.dart';

class FireDetectionViolationModel extends FireDetectionViolation {
  FireDetectionViolationModel({
    required String id,
    required String flightId,
    String? imageUrl,
    required DateTime timestamp,
    required double confidence,
    required String detectionType,
  }) : super(
    id: id,
    flightId: flightId,
    imageUrl: imageUrl,
    timestamp: timestamp,
    confidence: confidence,
    detectionType: detectionType,
  );

  factory FireDetectionViolationModel.fromEntity(FireDetectionViolation entity) {
    return FireDetectionViolationModel(
      id: entity.id,
      flightId: entity.flightId,
      imageUrl: entity.imageUrl,
      timestamp: entity.timestamp,
      confidence: entity.confidence,
      detectionType: entity.detectionType,
    );
  }

  factory FireDetectionViolationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FireDetectionViolationModel(
      id: doc.id,
      flightId: data['flightId'] ?? '',
      imageUrl: data['violationUrl'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      confidence: data['confidence'] ?? 0.0,
      detectionType: data['detectionType'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flightId': flightId,
      'violationUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'confidence': confidence,
      'detectionType': detectionType,
    };
  }
}