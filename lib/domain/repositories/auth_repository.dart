import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/domain/entities/user.dart';

abstract class AuthRepository {
  User? getCurrentUser();

  Stream<User?> get userChanges;

  Future<Either<Failure, User>> signIn(String email, String password);

  Future<Either<Failure, void>> resetPassword(String email);

  Future<Either<Failure, bool>> checkEmailExists(String email);

  Future<void> signOut();

}