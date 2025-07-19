// reset_password_usecase.dart
//
// Şifre sıfırlama işlemini gerçekleştiren use case.


import 'package:kapadokya_balon_app/domain/repositories/auth_repository.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) {
    return repository.resetPassword(email);
  }
}