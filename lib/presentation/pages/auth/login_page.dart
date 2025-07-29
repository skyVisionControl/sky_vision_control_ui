import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapadokya_balon_app/core/constants/route_constants.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/core/utils/validators.dart';
import 'package:kapadokya_balon_app/presentation/providers/auth_providers.dart';
import 'package:kapadokya_balon_app/presentation/widgets/buttons/app_button.dart';

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
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      // Firebase ile giriş
      await ref.read(authViewModelProvider.notifier).signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Giriş durumunu kontrol et
      final authState = ref.read(authViewModelProvider);

      if (authState.isAuthenticated) {
        if (!mounted) return;
        context.go(RouteConstants.faceRecognition);
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
    final errorMessage = authState.errorMessage;

    // Hata mesajı gösterme
    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showErrorDialog(errorMessage);
          ref.read(authViewModelProvider.notifier).clearError();
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
              AppColors.primary.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 200,
                          ),
                          Text(
                            'Sky Vision Control',
                            style: TextStyles.heading2,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          /*
                          Text(
                            'Kaptan Giriş Paneli',
                            style: TextStyles.heading4.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),

                           */
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // E-posta Alanı
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        hintText: 'captain@example.com',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: Validators.validateEmail,
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Şifre Alanı
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        hintText: '********',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      validator: Validators.validatePassword,
                      enabled: !isLoading,
                    ),

                    // Beni Hatırla & Şifremi Unuttum
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Beni Hatırla
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

                          // Şifremi Unuttum
                          TextButton(
                            onPressed: isLoading ? null : _forgotPassword,
                            child: const Text('Şifremi Unuttum'),
                          ),
                        ],
                      ),
                    ),

                    // Giriş Butonu
                    AppButton(
                      text: 'Giriş Yap',
                      icon: Icons.login,
                      isLoading: isLoading,
                      onPressed: _login,
                      isFullWidth: true,
                    ),

                    // Demo Giriş Notu
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
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Giriş Hatası'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}