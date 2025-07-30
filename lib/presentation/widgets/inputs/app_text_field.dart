import 'package:flutter/material.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLength;
  final int maxLines;
  final bool autofocus;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final double? width; // Özel genişlik
  final bool isFullWidth; // Tam genişlik kontrolü

  const AppTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.maxLength,
    this.maxLines = 1,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onEditingComplete,
    this.onSubmitted,
    this.onChanged,
    this.width,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : (width ?? 320),
      constraints: BoxConstraints(
        maxWidth: isFullWidth ? double.infinity : (width ?? 320),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.5), // Hint text opacity
            fontSize: 14,
          ),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon,
          counterText: maxLength != null ? '' : null,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.primary, width: 2.0),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.error, width: 1.0),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.error, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          isDense: true, // Input alanını daha kompakt yap
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        enabled: enabled,
        maxLength: maxLength,
        maxLines: obscureText ? 1 : maxLines,
        autofocus: autofocus,
        textInputAction: textInputAction,
        focusNode: focusNode,
        onEditingComplete: onEditingComplete,
        onFieldSubmitted: onSubmitted,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14.0),
      ),
    );
  }
}

class AppPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;
  final void Function(String)? onSubmitted;
  final double? width; // Özel genişlik
  final bool isFullWidth; // Tam genişlik kontrolü

  const AppPasswordField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
    this.enabled = true,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.onEditingComplete,
    this.onSubmitted,
    this.width,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      hintText: widget.hintText,
      prefixIcon: Icons.lock,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.primary,
          size: 20,
        ),
        onPressed: _togglePasswordVisibility,
      ),
      obscureText: _obscureText,
      validator: widget.validator,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      width: widget.width,
      isFullWidth: widget.isFullWidth,
    );
  }
}

class AppEmailField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;
  final void Function(String)? onSubmitted;
  final double? width; // Özel genişlik
  final bool isFullWidth; // Tam genişlik kontrolü

  const AppEmailField({
    Key? key,
    required this.controller,
    this.labelText = 'E-posta',
    this.hintText = 'ornek@domain.com',
    this.validator,
    this.enabled = true,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
    this.onSubmitted,
    this.width,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      validator: validator,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      width: width,
      isFullWidth: isFullWidth,
    );
  }
}