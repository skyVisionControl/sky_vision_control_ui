import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';

enum AppButtonType {
  primary,
  secondary,
  outline,
  text,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonType type;
  final AppButtonSize size;
  final double? width; // Özel genişlik

  const AppButton({
    Key? key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Butonun boyutlarını belirle
    double buttonHeight;
    double fontSize;
    double iconSize;
    double horizontalPadding;
    EdgeInsets padding;

    switch (size) {
      case AppButtonSize.small:
        buttonHeight = 36.0;
        fontSize = 12.0;
        iconSize = 16.0;
        horizontalPadding = 12.0;
        padding = const EdgeInsets.symmetric(horizontal: 12.0);
        break;
      case AppButtonSize.large:
        buttonHeight = 54.0;
        fontSize = 16.0;
        iconSize = 24.0;
        horizontalPadding = 24.0;
        padding = const EdgeInsets.symmetric(horizontal: 24.0);
        break;
      case AppButtonSize.medium:
      default:
        buttonHeight = 46.0;
        fontSize = 14.0;
        iconSize = 20.0;
        horizontalPadding = 16.0;
        padding = const EdgeInsets.symmetric(horizontal: 16.0);
    }

    // Buton içeriği
    Widget buttonContent = isLoading
        ? SizedBox(
      width: iconSize,
      height: iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          type == AppButtonType.primary
              ? Colors.white
              : AppColors.primary,
        ),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: iconSize,
          ),
          SizedBox(width: text.isNotEmpty ? 8.0 : 0),
        ],
        if (text.isNotEmpty)
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );

    // Buton stilini belirle
    ButtonStyle buttonStyle;
    switch (type) {
      case AppButtonType.secondary:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: padding,
          minimumSize: Size(isFullWidth ? double.infinity : (width ?? 120.0), buttonHeight),
          maximumSize: Size(isFullWidth ? double.infinity : (width ?? 250.0), buttonHeight),
        );
        break;
      case AppButtonType.outline:
        buttonStyle = OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: padding,
          minimumSize: Size(isFullWidth ? double.infinity : (width ?? 120.0), buttonHeight),
          maximumSize: Size(isFullWidth ? double.infinity : (width ?? 250.0), buttonHeight),
        );
        break;
      case AppButtonType.text:
        buttonStyle = TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: padding,
          minimumSize: Size(isFullWidth ? double.infinity : (width ?? 120.0), buttonHeight),
          maximumSize: Size(isFullWidth ? double.infinity : (width ?? 250.0), buttonHeight),
        );
        break;
      case AppButtonType.primary:
      default:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: padding,
          minimumSize: Size(isFullWidth ? double.infinity : (width ?? 120.0), buttonHeight),
          maximumSize: Size(isFullWidth ? double.infinity : (width ?? 250.0), buttonHeight),
        );
    }

    // Buton türüne göre widget oluştur
    switch (type) {
      case AppButtonType.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
      case AppButtonType.secondary:
      case AppButtonType.primary:
      default:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
    }
  }
}