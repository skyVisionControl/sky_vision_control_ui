// auth_view_model.dart
//
// Kimlik doğrulama ekranları için view model sınıfı.
// Riverpod ile state yönetimini sağlar.


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapadokya_balon_app/domain/entities/user.dart';
import 'package:kapadokya_balon_app/domain/usecases/login_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/reset_password_usecase.dart';

// Auth State
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final User? user;
  final bool isResetEmailSent;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.isResetEmailSent = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    User? user,
    bool? isResetEmailSent,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
      isResetEmailSent: isResetEmailSent ?? this.isResetEmailSent,
    );
  }
}

// Auth ViewModel
class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  AuthViewModel(this._loginUseCase, this._resetPasswordUseCase)
      : super(AuthState());

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        errorMessage: 'E-posta ve şifre alanları boş olamaz',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final params = LoginParams(email: email, password: password);
    final result = await _loginUseCase(params);

    result.fold(
          (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
          (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        errorMessage: null,
      ),
    );
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      state = state.copyWith(
        errorMessage: 'E-posta alanı boş olamaz',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _resetPasswordUseCase(email);

    result.fold(
          (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
          (_) => state = state.copyWith(
        isLoading: false,
        isResetEmailSent: true,
        errorMessage: null,
      ),
    );
  }

  void resetState() {
    state = AuthState();
  }
}