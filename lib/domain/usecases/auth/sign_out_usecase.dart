// sign_out_usecase.dart
//
// Kullanıcı çıkışı yapan use case.

import 'package:kapadokya_balon_app/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}