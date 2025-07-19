// direction_indicator.dart
//
// Balon yönünü gösteren pusula bileşeni.
// Derece cinsinden yön ve kardinal yön bilgisini görselleştirir.


import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';

class DirectionIndicator extends StatelessWidget {
  final double direction; // 0-360 derece
  final double size;
  final bool isWarning;

  const DirectionIndicator({
    Key? key,
    required this.direction,
    this.size = 160,
    this.isWarning = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWarning
            ? const BorderSide(color: AppColors.error, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yön',
                  style: TextStyles.gaugeTitle,
                ),
                if (isWarning)
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Pusula
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pusula çerçevesi
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.directionGauge.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  ),

                  // Pusula çizgileri ve yön etiketleri
                  Positioned.fill(
                    child: CustomPaint(
                      painter: CompassPainter(),
                    ),
                  ),

                  // Yön oku
                  Transform.rotate(
                    angle: (direction * math.pi / 180) - (math.pi / 2),
                    child: Container(
                      width: size * 0.8,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.directionGauge.withOpacity(0.5),
                            AppColors.directionGauge,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.directionGauge,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Orta nokta
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.directionGauge,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Değer gösterimi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${direction.toStringAsFixed(0)}°',
                  style: TextStyles.gaugeValue.copyWith(
                    color: isWarning ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getCardinalDirection(direction),
                  style: TextStyles.gaugeUnit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getCardinalDirection(double degree) {
    const List<String> cardinals = ['K', 'KD', 'D', 'GD', 'G', 'GB', 'B', 'KB'];
    return cardinals[((degree + 22.5) % 360 ~/ 45)];
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = AppColors.directionGauge.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Ana yönler
    const List<String> mainDirections = ['K', 'D', 'G', 'B'];

    for (int i = 0; i < 360; i += 30) {
      final angle = i * math.pi / 180;
      final isMajor = i % 90 == 0;

      final lineStart = Offset(
        center.dx + (radius - (isMajor ? 20 : 10)) * math.cos(angle),
        center.dy + (radius - (isMajor ? 20 : 10)) * math.sin(angle),
      );

      final lineEnd = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.drawLine(lineStart, lineEnd, paint);

      if (isMajor) {
        final dirIndex = i ~/ 90;
        textPainter.text = TextSpan(
          text: mainDirections[dirIndex],
          style: TextStyle(
            color: AppColors.directionGauge.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );

        textPainter.layout();

        final textOffset = Offset(
          center.dx + (radius - 35) * math.cos(angle) - textPainter.width / 2,
          center.dy + (radius - 35) * math.sin(angle) - textPainter.height / 2,
        );

        textPainter.paint(canvas, textOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}