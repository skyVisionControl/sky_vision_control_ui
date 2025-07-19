// direction_indicator.dart - tam düzeltilmiş versiyon
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/domain/entities/sensor_data.dart';

class DirectionIndicator extends StatelessWidget {
  final double direction;
  final AlertLevel alertLevel;

  const DirectionIndicator({
    Key? key,
    required this.direction,
    required this.alertLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yön',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.explore,
                  color: _getAlertColor(),
                  size: 20,
                ),
              ],
            ),

            // Ana değer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${direction.toStringAsFixed(0)}°',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getAlertColor(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getDirectionText(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Pusula göstergesi
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dış çember
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),

                    // Yön işaretleri
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CustomPaint(
                        painter: CompassPainter(),
                      ),
                    ),

                    // Ok
                    Transform.rotate(
                      angle: direction * math.pi / 180,
                      child: Container(
                        width: 80,
                        height: 80,
                        child: CustomPaint(
                          painter: ArrowPainter(color: _getAlertColor()),
                        ),
                      ),
                    ),

                    // Merkez nokta
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getAlertColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor() {
    switch (alertLevel) {
      case AlertLevel.warning:
        return AppColors.warning;
      case AlertLevel.critical:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  String _getDirectionText() {
    if (direction >= 337.5 || direction < 22.5) {
      return 'K';
    } else if (direction >= 22.5 && direction < 67.5) {
      return 'KD';
    } else if (direction >= 67.5 && direction < 112.5) {
      return 'D';
    } else if (direction >= 112.5 && direction < 157.5) {
      return 'GD';
    } else if (direction >= 157.5 && direction < 202.5) {
      return 'G';
    } else if (direction >= 202.5 && direction < 247.5) {
      return 'GB';
    } else if (direction >= 247.5 && direction < 292.5) {
      return 'B';
    } else {
      return 'KB';
    }
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Kuzey
    _drawDirectionMark(canvas, center, radius, 0, 'K', paint);
    // Doğu
    _drawDirectionMark(canvas, center, radius, 90, 'D', paint);
    // Güney
    _drawDirectionMark(canvas, center, radius, 180, 'G', paint);
    // Batı
    _drawDirectionMark(canvas, center, radius, 270, 'B', paint);
  }

  void _drawDirectionMark(Canvas canvas, Offset center, double radius, double angle, String text, Paint paint) {
    final radian = angle * math.pi / 180;
    final dx = math.cos(radian);
    final dy = math.sin(radian);

    final outerPoint = Offset(
      center.dx + dx * radius,
      center.dy + dy * radius,
    );

    final innerPoint = Offset(
      center.dx + dx * (radius - 15),
      center.dy + dy * (radius - 15),
    );

    // Çizgi çiz
    canvas.drawLine(innerPoint, outerPoint, paint);

    // Metni çiz
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final textOffset = Offset(
      center.dx + dx * (radius - 25) - textPainter.width / 2,
      center.dy + dy * (radius - 25) - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ArrowPainter extends CustomPainter {
  final Color color;

  ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();

    // Ok başı (kuzey yönü)
    path.moveTo(center.dx, center.dy - size.height / 2 + 5); // Üst nokta
    path.lineTo(center.dx - 8, center.dy - 5); // Sol alt
    path.lineTo(center.dx + 8, center.dy - 5); // Sağ alt
    path.close();

    canvas.drawPath(path, paint);

    // Ok kuyruğu (güney yönü)
    final tailPath = Path();
    tailPath.moveTo(center.dx, center.dy + size.height / 2 - 5); // Alt nokta
    tailPath.lineTo(center.dx - 5, center.dy + 5); // Sol üst
    tailPath.lineTo(center.dx + 5, center.dy + 5); // Sağ üst
    tailPath.close();

    canvas.drawPath(tailPath, paint..color = color.withOpacity(0.4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}