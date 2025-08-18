import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapadokya_balon_app/data/datasources/auth/auth_data_source.dart';
import 'package:kapadokya_balon_app/data/datasources/auth/firebase_auth_service.dart';
import 'package:kapadokya_balon_app/data/repositories/auth_repository_impl.dart';
import 'package:kapadokya_balon_app/domain/repositories/auth_repository.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/observe_user_changes_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/reset_password_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/sign_in_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/auth/sign_out_usecase.dart';
import 'package:kapadokya_balon_app/presentation/viewmodels/auth_view_model.dart';

// Service Provider
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return FirebaseAuthService();
});

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authDataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(authDataSource);
});

// Use Case Providers
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final observeUserChangesUseCaseProvider = Provider<ObserveUserChangesUseCase>((ref) {
  return ObserveUserChangesUseCase(ref.watch(authRepositoryProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

// ViewModel Provider
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    ref.watch(getCurrentUserUseCaseProvider),
    ref.watch(observeUserChangesUseCaseProvider),
    ref.watch(signInUseCaseProvider),
    ref.watch(resetPasswordUseCaseProvider),
    ref.watch(signOutUseCaseProvider)
  );
});