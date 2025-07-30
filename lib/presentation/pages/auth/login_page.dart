import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapadokya_balon_app/core/constants/route_constants.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/core/utils/validators.dart';
import 'package:kapadokya_balon_app/presentation/providers/auth_providers.dart';
import 'package:kapadokya_balon_app/presentation/widgets/buttons/app_button.dart';
import 'package:kapadokya_balon_app/presentation/widgets/inputs/app_text_field.dart';
import 'package:kapadokya_balon_app/presentation/widgets/dialogs/app_dialogs.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authViewModelProvider.notifier).signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      final authState = ref.read(authViewModelProvider);
      if (authState.isAuthenticated) {
        if (!mounted) return;
        context.go(RouteConstants.home);
      }
    }
  }

  void _forgotPassword() {
    context.push(RouteConstants.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.loginErrorMessage;

    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authViewModelProvider.notifier).clearLoginError();
        if (mounted) {
          AppDialogs.showErrorDialog(
            context: context,
            title: 'Giriş Hatası',
            message: errorMessage,
          );
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
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              height: 100,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sky Vision Control',
                              style: TextStyles.heading2,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kaptan Giriş Paneli',
                              style: TextStyles.heading4.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppEmailField(
                        controller: _emailController,
                        validator: Validators.validateEmail,
                        enabled: !isLoading,
                        width: 300, // Daha dar giriş alanı
                        isFullWidth: false,
                      ),
                      const SizedBox(height: 16),
                      AppPasswordField(
                        controller: _passwordController,
                        labelText: 'Şifre',
                        hintText: '********',
                        validator: Validators.validatePassword,
                        enabled: !isLoading,
                        onSubmitted: (_) => _login(),
                        width: 300, // Daha dar giriş alanı
                        isFullWidth: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: isLoading
                                      ? null
                                      : (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                                const Text('Beni Hatırla'),
                              ],
                            ),
                            TextButton(
                              onPressed: isLoading ? null : _forgotPassword,
                              child: const Text('Şifremi Unuttum'),
                            ),
                          ],
                        ),
                      ),
                      AppButton(
                        text: 'Giriş Yap',
                        icon: Icons.login,
                        isLoading: isLoading,
                        onPressed: _login,
                        isFullWidth: false,
                        width: 180, // Daha dar buton
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0),
                        child: Text(
                          'Demo uygulama için:\nE-posta: demo@example.com\nŞifre: Demo123!',
                          style: TextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
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