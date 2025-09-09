
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonCountViolationModel {
  final String detectionType;
  final int headCount;
  final double confidence;
  final String flightId;
  final String id;
  final DateTime timeStamp;
  final String? violationUrl;

  PersonCountViolationModel({
    required this.detectionType,
    required this.headCount,
    required this.confidence,
    required this.flightId,
    required this.id,
    required this.timeStamp,
    this.violationUrl,
  });

  factory PersonCountViolationModel.fromJson(Map<String, dynamic> json) {
    return PersonCountViolationModel(
      detectionType: json['detectionType'] ?? 'personCount',
      headCount: json['headCount'] ?? 0,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      flightId: json['flightId'] ?? '',
      id: json['id'] ?? '',
      timeStamp: (json['timeStamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      violationUrl: json['violationUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detectionType': detectionType,
      'headCount': headCount,
      'confidence': confidence,
      'flightId': flightId,
      'id': id,
      'timeStamp': Timestamp.fromDate(timeStamp),
      'violationUrl': violationUrl,
    };
  }
}