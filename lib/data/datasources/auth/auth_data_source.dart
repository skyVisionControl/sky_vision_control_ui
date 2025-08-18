import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/data/models/user_model.dart';

abstract class AuthDataSource {
  UserModel? getCurrentUser();

  Stream<UserModel?> get userChanges;

  Future<Either<Failure, UserModel>> signInWithEmailAndPassword(
      String email, String password);

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Future<Either<Failure, UserModel>> registerWithEmailAndPassword(
      String email, String password, String name);

}