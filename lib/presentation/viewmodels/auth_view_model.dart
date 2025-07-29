import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapadokya_balon_app/domain/entities/user.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/observe_user_changes_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/reset_password_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/sign_in_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/sign_out_usecase.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final bool isPasswordResetSent;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.isPasswordResetSent = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    bool? isPasswordResetSent,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
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
      errorMessage: null,
    );

    final result = await _signInUseCase(email, password);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        isAuthenticated: false,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        errorMessage: null,
      ),
    );
  }

  // Şifre sıfırlama
  Future<void> resetPassword(String email) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isPasswordResetSent: false,
    );

    final result = await _resetPasswordUseCase(email);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        isPasswordResetSent: false,
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        isPasswordResetSent: true,
      ),
    );
  }

  // Çıkış yapma
  Future<void> signOut() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      await _signOutUseCase();
      state = state.copyWith(
        isLoading: false,
        user: null,
        isAuthenticated: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Çıkış yapılırken bir hata oluştu: $e',
      );
    }
  }

  // Hata mesajını temizleme
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // Şifre sıfırlama durumunu sıfırlama
  void resetPasswordResetState() {
    state = state.copyWith(isPasswordResetSent: false);
  }
}
