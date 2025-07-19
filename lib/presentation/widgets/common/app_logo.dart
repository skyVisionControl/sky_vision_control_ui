// app_logo.dart
//
// Uygulama logosu ve başlık bileşeni.
// Farklı boyutlar ve konumlandırmalar destekler.


import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/constants/app_constants.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showTitle;
  final MainAxisAlignment alignment;
  final Axis direction;

  const AppLogo({
    Key? key,
    this.size = 120.0,
    this.showTitle = true,
    this.alignment = MainAxisAlignment.center,
    this.direction = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget logoImage = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.location_on_sharp, // Bu geçici bir ikon, gerçek logo için değiştirilmeli
        color: Colors.white,
        size: 64,
      ),
    );

    final Widget title = Text(
      AppConstants.appName,
      style: TextStyles.heading2.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );

    if (direction == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        children: [
          logoImage,
          if (showTitle) ...[
            const SizedBox(height: 16.0),
            title,
          ],
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        children: [
          logoImage,
          if (showTitle) ...[
            const SizedBox(width: 16.0),
            Flexible(child: title),
          ],
        ],
      );
    }
  }
}