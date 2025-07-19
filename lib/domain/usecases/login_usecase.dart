// login_usecase.dart
//
// Kullanıcı giriş işlemini gerçekleştiren use case.


import 'package:kapadokya_balon_app/domain/entities/user.dart';
import 'package:kapadokya_balon_app/domain/repositories/auth_repository.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams({
    required this.email,
    required this.password,
  });
}

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}