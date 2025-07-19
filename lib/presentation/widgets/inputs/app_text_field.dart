// app_text_field.dart
//
// Uygulamada kullanılan özelleştirilmiş form alanı bileşeni.
// Email, şifre ve normal metin girişi gibi farklı tipleri destekler.

import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';

enum AppTextFieldType { text, email, password, number }

class AppTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final String? errorText;
  final TextEditingController controller;
  final AppTextFieldType type;
  final bool isRequired;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextInputAction textInputAction;
  final bool autofocus;
  final bool enabled;

  const AppTextField({
    Key? key,
    required this.label,
    this.hintText,
    this.errorText,
    required this.controller,
    this.type = AppTextFieldType.text,
    this.isRequired = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
    this.autofocus = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiket
        if (widget.label.isNotEmpty) ...[
          Row(
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Text Field
        TextFormField(
          controller: widget.controller,
          obscureText: widget.type == AppTextFieldType.password && _obscureText,
          keyboardType: _getKeyboardType(),
          maxLines: widget.type == AppTextFieldType.password ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.type == AppTextFieldType.password
                ? _buildPasswordToggle()
                : widget.suffixIcon,
            filled: true,
            fillColor: widget.enabled ? Colors.white : AppColors.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordToggle() {
    return IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColors.textSecondary,
      ),
      onPressed: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case AppTextFieldType.email:
        return TextInputType.emailAddress;
      case AppTextFieldType.password:
        return TextInputType.visiblePassword;
      case AppTextFieldType.number:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }
}