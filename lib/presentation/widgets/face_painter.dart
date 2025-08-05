// This file for painting detected faces on an image in a Flutter application.

import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/data/models/face_match.dart';
import 'package:kapadokya_balon_app/core/utils/coordinates_translator.dart';
import 'dart:ui' as ui;

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
      this.faces,
      this.imageSize,
      this.image,
      );
  final ui.Image image;
  final List<FaceMatch> faces;
  final Size imageSize;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
    for (final FaceMatch faceMeta in faces) {
      final faceBounding = faceMeta.boundingRect;
      final isCaptain = faceMeta.isRecognized;
      final accuracy = faceMeta.difference;
      final left = translateX(faceBounding.left, size, imageSize);
      final top = translateY(faceBounding.top, size, imageSize);
      final right = translateX(faceBounding.right, size, imageSize);
      final bottom = translateY(faceBounding.bottom, size, imageSize);

      var path = Path();

      path
        ..moveTo(left, top)
        ..lineTo(right, top)
        ..lineTo(right, bottom)
        ..lineTo(left, bottom)
        ..lineTo(left, top);

      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = isCaptain ? Colors.green : Colors.red
            ..strokeWidth = 2.5);

      final textPainter = TextPainter(textDirection: TextDirection.ltr)
        ..text = TextSpan(
            text: isCaptain ? "Kaptan tanındı" : "Kaptan tanınmadı",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                background: Paint()..color = isCaptain ? Colors.green : Colors.red,
                foreground: Paint()
                  ..color = Colors.white
                  ..isAntiAlias = true))
        ..layout(maxWidth: 200);

      textPainter.paint(canvas, Offset(left, top - 25));
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}