// auth_providers.dart
//
// Kimlik doğrulama ile ilgili provider tanımlamaları.
// Dependency injection için Riverpod kullanılır.


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapadokya_balon_app/data/datasources/auth_data_source.dart';
import 'package:kapadokya_balon_app/data/repositories/auth_repository_impl.dart';
import 'package:kapadokya_balon_app/domain/repositories/auth_repository.dart';
import 'package:kapadokya_balon_app/domain/usecases/login_usecase.dart';
import 'package:kapadokya_balon_app/domain/usecases/reset_password_usecase.dart';
import 'package:kapadokya_balon_app/presentation/viewmodels/auth_view_model.dart';

// Data Source Provider
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return MockAuthDataSource();
});

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

// Use Case Providers
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUseCase(repository);
});

// ViewModel Provider
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final resetPasswordUseCase = ref.watch(resetPasswordUseCaseProvider);
  return AuthViewModel(loginUseCase, resetPasswordUseCase);
});