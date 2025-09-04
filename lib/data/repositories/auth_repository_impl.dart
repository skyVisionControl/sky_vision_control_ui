import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/data/datasources/auth/auth_data_source.dart';
import 'package:kapadokya_balon_app/domain/entities/auth/user.dart';
import 'package:kapadokya_balon_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;

  AuthRepositoryImpl(this._authDataSource);

  @override
  User? getCurrentUser() {
    return _authDataSource.getCurrentUser();
  }

  @override
  Stream<User?> get userChanges => _authDataSource.userChanges;

  @override
  Future<Either<Failure, User>> signIn(String email, String password) {
    return _authDataSource.signInWithEmailAndPassword(email, password);
  }


  @override
  Future<Either<Failure, void>> resetPassword(String email) {
    return _authDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> signOut() {
    return _authDataSource.signOut();
  }
}