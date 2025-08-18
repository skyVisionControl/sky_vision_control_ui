import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapadokya_balon_app/domain/entities/user.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/observe_user_changes_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/reset_password_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/sign_in_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/sign_out_usecase.dart';

import '../../core/error/failures.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? loginErrorMessage;  // Login sayfası için özel hata
  final String? resetPasswordErrorMessage;  // Şifre sıfırlama sayfası için özel hata
  final bool isAuthenticated;
  final bool isPasswordResetSent;

  AuthState({
    this.user,
    this.isLoading = false,
    this.loginErrorMessage,
    this.resetPasswordErrorMessage,
    this.isAuthenticated = false,
    this.isPasswordResetSent = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? loginErrorMessage,
    String? resetPasswordErrorMessage,
    bool? isAuthenticated,
    bool? isPasswordResetSent,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      loginErrorMessage: loginErrorMessage,  // null ise değiştirmez
      resetPasswordErrorMessage: resetPasswordErrorMessage,  // null ise değiştirmez
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isPasswordResetSent: isPasswordResetSent ?? this.isPasswordResetSent,
    );
  }
}


class AuthViewModel extends StateNotifier<AuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ObserveUserChangesUseCase _observeUserChangesUseCase;
  final SignInUseCase _signInUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final SignOutUseCase _signOutUseCase;

  StreamSubscription<User?>? _userSubscription;

  AuthViewModel(
      this._getCurrentUserUseCase,
      this._observeUserChangesUseCase,
      this._signInUseCase,
      this._resetPasswordUseCase,
      this._signOutUseCase,
      ) : super(AuthState()) {
    _init();
  }

  void _init() {
    // Mevcut kullanıcıyı kontrol et
    final currentUser = _getCurrentUserUseCase();
    if (currentUser != null) {
      state = state.copyWith(
        user: currentUser,
        isAuthenticated: true,
      );
    }

    // Kullanıcı değişikliklerini dinle
    _userSubscription = _observeUserChangesUseCase().listen((user) {
      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
      );
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  // Giriş yapma
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(
      isLoading: true,
      loginErrorMessage: null,  // Sadece login hatası temizlenir
    );

    final result = await _signInUseCase(email, password);

    result.fold(
          (failure) => state = state.copyWith(
        isLoading: false,
        loginErrorMessage: failure.message,  // Login hatası set edilir
        isAuthenticated: false,
      ),
          (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        loginErrorMessage: null,
      ),
    );
  }


// Şifre sıfırlama
  Future<void> resetPassword(String email) async {
    state = state.copyWith(
      isLoading: true,
      resetPasswordErrorMessage: null,
      isPasswordResetSent: false,
    );

    try {
      final result = await _resetPasswordUseCase(email);

      result.fold(
            (failure) {
          state = state.copyWith(
            isLoading: false,
            resetPasswordErrorMessage: failure.message,
            isPasswordResetSent: false,
          );
        },
            (_) {
          // Başarılı işlem - her durumda başarılı göster (güvenlik nedeniyle)
          state = state.copyWith(
            isLoading: false,
            resetPasswordErrorMessage: null,
            isPasswordResetSent: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        resetPasswordErrorMessage: 'Şifre sıfırlama sırasında beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin.',
        isPasswordResetSent: false,
      );
    }
  }

  // Çıkış yapma
  Future<void> signOut() async {
    state = state.copyWith(
      isLoading: true,
      loginErrorMessage: null,
    );

    try {
      await _signOutUseCase();
      state = state.copyWith(
        isLoading: false,
        user: null,
        isAuthenticated: false,
        loginErrorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        loginErrorMessage: 'Çıkış yapılırken bir hata oluştu: $e',
      );
    }
  }

  // Hata mesajını temizleme (login)
  void clearLoginError() {
    state = state.copyWith(loginErrorMessage: null);
  }

  // Hata mesajını temizleme (şifre sıfırlama)
  void clearResetPasswordError() {
    state = state.copyWith(resetPasswordErrorMessage: null);
  }

  // Şifre sıfırlama durumunu sıfırlama
  void resetPasswordResetState() {
    state = state.copyWith(isPasswordResetSent: false);
  }
}