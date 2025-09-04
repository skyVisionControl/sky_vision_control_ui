import 'package:equatable/equatable.dart';

/// Yangın algılama ihlali entity'si
class FireDetectionViolation extends Equatable {
  final String id;
  final String flightId;
  final String? imageUrl;
  final DateTime timestamp;
  final double confidence;
  final String detectionType; // 'fire' veya 'smoke'

  const FireDetectionViolation({
    required this.id,
    required this.flightId,
    this.imageUrl,
    required this.timestamp,
    required this.confidence,
    required this.detectionType,
  });

  @override
  List<Object?> get props => [id, flightId, imageUrl, timestamp, confidence, detectionType];
}