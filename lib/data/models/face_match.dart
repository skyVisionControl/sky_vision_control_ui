import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/data/models/face_user.dart';

class FaceMatch {
  final FaceUser user;
  final double difference;
  final Rect boundingRect;
  final bool isRecognized;

  FaceMatch({
    required this.user,
    required this.difference,
    required this.boundingRect,
    required this.isRecognized,
  });
}