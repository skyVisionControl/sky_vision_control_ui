// login_page.dart
//
// Uygulama giriş sayfası.
// E-posta ve şifre ile kimlik doğrulama sağlar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapadokya_balon_app/core/constants/route_constants.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/presentation/providers/auth_providers.dart';
import 'package:kapadokya_balon_app/presentation/widgets/buttons/app_button.dart';
import 'package:kapadokya_balon_app/presentation/widgets/common/app_logo.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/app_message.dart';
import 'package:kapadokya_balon_app/presentation/widgets/inputs/app_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final size = MediaQuery.of(context).size;

    // Kullanıcı girişi başarılı olunca otomatik yönlendirme
    if (authState.isAuthenticated) {
      // Yüz tanıma sayfasına yönlendirme
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RouteConstants.faceRecognition);
      });
    }

    return Scaffold(
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
                      Image.asset(
                        'assets/images/balloon_illustration.png',
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.location_pin, size: 200, color: AppColors.primary),
                        width: 300,
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'Kapadokya Balon Kaptanları için\nGüvenli Uçuş Yönetim Sistemi',
                          style: TextStyles.heading2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Sağ taraf: Giriş formu
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
                          const AppLogo(size: 100),
                          const SizedBox(height: 32),

                          // Başlık
                          Text(
                            'Hoş Geldiniz',
                            style: TextStyles.heading2,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lütfen hesabınıza giriş yapın',
                            style: TextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Hata mesajı (varsa)
                          if (authState.errorMessage != null) ...[
                            AppMessage(
                              message: authState.errorMessage!,
                              type: MessageType.error,
                              onClose: () => ref.read(authViewModelProvider.notifier).resetState(),
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
                            textInputAction: TextInputAction.next,
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: 16),

                          // Şifre alanı
                          AppTextField(
                            label: 'Şifre',
                            hintText: 'Şifrenizi girin',
                            controller: _passwordController,
                            type: AppTextFieldType.password,
                            isRequired: true,
                            prefixIcon: const Icon(Icons.lock_outline),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleLogin(),
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: 8),

                          // Şifremi unuttum
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () => context.push(RouteConstants.forgotPassword),
                              child: const Text('Şifremi Unuttum'),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Giriş butonu
                          AppButton(
                            text: 'Giriş Yap',
                            onPressed: _handleLogin,
                            isLoading: authState.isLoading,
                            isFullWidth: true,
                            icon: Icons.login,
                          ),

                          const SizedBox(height: 24),

                          // Test kullanıcısı bilgisi
                          const Divider(),
                          const SizedBox(height: 16),
                          const Text(
                            'Demo Kullanıcı Bilgileri:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'E-posta: pilot@example.com\nŞifre: password123',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
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

  void _handleLogin() {
    final authState = ref.read(authViewModelProvider);
    if (authState.isLoading) return;

    // Form doğrulama
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      ref.read(authViewModelProvider.notifier).login(email, password);
    }
  }
}