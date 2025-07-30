import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/core/utils/validators.dart';
import 'package:kapadokya_balon_app/presentation/providers/auth_providers.dart';
import 'package:kapadokya_balon_app/presentation/widgets/buttons/app_button.dart';
import 'package:kapadokya_balon_app/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:kapadokya_balon_app/presentation/widgets/inputs/app_text_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authViewModelProvider.notifier).resetPassword(
        _emailController.text.trim(),
      );
      final authState = ref.read(authViewModelProvider);
      if (authState.isPasswordResetSent) {
        if (!mounted) return;
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    AppDialogs.showSuccessDialog(
      context: context,
      title: 'İşlem Tamamlandı',
      message: 'Eğer bu e-posta adresine ait bir hesap varsa, şifre sıfırlama bağlantısı gönderilmiştir. '
          'Lütfen e-posta kutunuzu (ve spam klasörünü) kontrol ediniz.',
      onConfirm: () {
        ref.read(authViewModelProvider.notifier).resetPasswordResetState();
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.resetPasswordErrorMessage;
    final isPasswordResetSent = authState.isPasswordResetSent;

    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authViewModelProvider.notifier).clearResetPasswordError();
        if (mounted) {
          AppDialogs.showErrorDialog(
            context: context,
            title: 'Hata',
            message: errorMessage,
          );
        }
      });
    }

    if (isPasswordResetSent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showSuccessDialog();
        }
      });
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400), // Form genişliğini sınırlandır
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.lock_reset,
                              size: 72,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Şifrenizi mi Unuttunuz?',
                              style: TextStyles.heading3,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'E-posta adresinizi girin, size şifre sıfırlama bağlantısı göndereceğiz.',
                              style: TextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      AppEmailField(
                        controller: _emailController,
                        validator: Validators.validateEmail,
                        enabled: !isLoading,
                        onSubmitted: (_) => _resetPassword(),
                        textInputAction: TextInputAction.done,
                        width: 300, // Daha dar giriş alanı
                        isFullWidth: false,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Şifre Sıfırlama Gönder',
                        icon: Icons.send,
                        isLoading: isLoading,
                        onPressed: _resetPassword,
                        isFullWidth: false,
                        width: 220, // Daha dar buton
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: TextButton(
                          onPressed: isLoading ? null : () => context.pop(),
                          child: const Text('Giriş Sayfasına Dön'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}