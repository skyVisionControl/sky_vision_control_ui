// app_message.dart
//
// Bilgi, başarı, uyarı ve hata mesajları için bileşen.
// Toast, snackbar ve banner gibi farklı gösterim stillerini destekler.


import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';

enum MessageType { info, success, warning, error }

class AppMessage extends StatelessWidget {
  final String message;
  final MessageType type;
  final IconData? icon;
  final VoidCallback? onClose;

  const AppMessage({
    Key? key,
    required this.message,
    this.type = MessageType.info,
    this.icon,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: _getBorderColor(),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          _getIcon(),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14.0,
                color: _getTextColor(),
              ),
            ),
          ),
          if (onClose != null) ...[
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18.0,
                color: _getTextColor(),
              ),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _getIcon() {
    IconData iconData = icon ?? _getDefaultIcon();
    return Icon(
      iconData,
      size: 20.0,
      color: _getIconColor(),
    );
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case MessageType.info:
        return Icons.info_outline;
      case MessageType.success:
        return Icons.check_circle_outline;
      case MessageType.warning:
        return Icons.warning_amber_outlined;
      case MessageType.error:
        return Icons.error_outline;
    }
  }

  Color _getBackgroundColor() {
    switch (type) {
      case MessageType.info:
        return AppColors.info.withOpacity(0.1);
      case MessageType.success:
        return AppColors.success.withOpacity(0.1);
      case MessageType.warning:
        return AppColors.warning.withOpacity(0.1);
      case MessageType.error:
        return AppColors.error.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case MessageType.info:
        return AppColors.info.withOpacity(0.3);
      case MessageType.success:
        return AppColors.success.withOpacity(0.3);
      case MessageType.warning:
        return AppColors.warning.withOpacity(0.3);
      case MessageType.error:
        return AppColors.error.withOpacity(0.3);
    }
  }

  Color _getIconColor() {
    switch (type) {
      case MessageType.info:
        return AppColors.info;
      case MessageType.success:
        return AppColors.success;
      case MessageType.warning:
        return AppColors.warning;
      case MessageType.error:
        return AppColors.error;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case MessageType.info:
        return AppColors.info.withOpacity(0.8);
      case MessageType.success:
        return AppColors.success.withOpacity(0.8);
      case MessageType.warning:
        return AppColors.warning.withOpacity(0.8);
      case MessageType.error:
        return AppColors.error.withOpacity(0.8);
    }
  }
}