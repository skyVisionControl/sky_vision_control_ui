// loading_indicator.dart
//
// Uygulama genelinde kullanılan yükleme göstergesi bileşeni.
// Farklı boyut ve renkler destekler.


import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.size = 40.0,
    this.color = AppColors.primary,
    this.strokeWidth = 3.0,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: strokeWidth,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16.0),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 16.0,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// Tam ekran yükleme göstergesi
class FullScreenLoading extends StatelessWidget {
  final String? message;
  final Color backgroundColor;

  const FullScreenLoading({
    Key? key,
    this.message,
    this.backgroundColor = Colors.white70,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: LoadingIndicator(message: message),
      ),
    );
  }
}

// Sayfa içi yükleme göstergesi
class PageLoading extends StatelessWidget {
  final String? message;

  const PageLoading({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: LoadingIndicator(message: message),
      ),
    );
  }
}