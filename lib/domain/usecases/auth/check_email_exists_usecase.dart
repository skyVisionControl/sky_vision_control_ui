import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/repositories/auth_repository.dart';

class CheckEmailExistsUseCase {
  final AuthRepository repository;

  CheckEmailExistsUseCase(this.repository);

  Future<Either<Failure, bool>> call(String email) {
    return repository.checkEmailExists(email);
  }
}