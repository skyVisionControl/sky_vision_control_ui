// forgot_password_page.dart
//
// Şifre sıfırlama sayfası.
// Kullanıcıların şifrelerini sıfırlamak için e-posta göndermelerini sağlar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/presentation/providers/auth_providers.dart';
import 'package:kapadokya_balon_app/presentation/widgets/buttons/app_button.dart';
import 'package:kapadokya_balon_app/presentation/widgets/common/app_logo.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/app_message.dart';
import 'package:kapadokya_balon_app/presentation/widgets/inputs/app_text_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Şifremi Unuttum'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Sol taraf: Görsel kısım (geniş ekran cihazlarda görünür)
            if (size.width > 800)
              Expanded(
                flex: 5,
                child: Container(
                  color: AppColors.primary.withOpacity(0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_reset,
                        size: 120,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'Şifrenizi mi unuttunuz?\nEndişelenmeyin, size yardımcı olacağız.',
                          style: TextStyles.heading3.copyWith(
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Sağ taraf: Şifre sıfırlama formu
            Expanded(
              flex: size.width > 800 ? 5 : 10,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          const AppLogo(size: 80),
                          const SizedBox(height: 32),

                          // Başlık ve açıklama
                          Text(
                            'Şifre Sıfırlama',
                            style: TextStyles.heading3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Şifrenizi sıfırlamak için e-posta adresinizi girin. '
                                'Size şifre sıfırlama bağlantısı içeren bir e-posta göndereceğiz.',
                            style: TextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Hata mesajı veya başarı mesajı (varsa)
                          if (authState.errorMessage != null) ...[
                            AppMessage(
                              message: authState.errorMessage!,
                              type: MessageType.error,
                              onClose: () => ref.read(authViewModelProvider.notifier).resetState(),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (authState.isResetEmailSent) ...[
                            const AppMessage(
                              message: 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi. '
                                  'Lütfen e-postanızı kontrol edin.',
                              type: MessageType.success,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // E-posta alanı
                          AppTextField(
                            label: 'E-posta',
                            hintText: 'E-postanızı girin',
                            controller: _emailController,
                            type: AppTextFieldType.email,
                            isRequired: true,
                            prefixIcon: const Icon(Icons.email_outlined),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleResetPassword(),
                            enabled: !authState.isLoading && !authState.isResetEmailSent,
                          ),
                          const SizedBox(height: 32),

                          // Şifre sıfırlama butonu
                          AppButton(
                            text: 'Şifremi Sıfırla',
                            onPressed: _handleResetPassword,
                            isLoading: authState.isLoading,
                            isFullWidth: true,
                            icon: Icons.lock_reset,
                            type: authState.isResetEmailSent
                                ? AppButtonType.secondary
                                : AppButtonType.primary,
                          ),
                          const SizedBox(height: 16),

                          // Geri dönüş butonu
                          if (authState.isResetEmailSent)
                            AppButton(
                              text: 'Giriş Sayfasına Dön',
                              onPressed: () => context.pop(),
                              type: AppButtonType.text,
                              isFullWidth: true,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleResetPassword() {
    final authState = ref.read(authViewModelProvider);
    if (authState.isLoading || authState.isResetEmailSent) return;

    // Form doğrulama
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      ref.read(authViewModelProvider.notifier).resetPassword(email);
    }
  }
}