// auth_repository_impl.dart
//
// AuthRepository arayüzünün implementasyonu.
// Veri kaynağından gelen verileri domain katmanına dönüştürür.


import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/core/utils/logger.dart';
import 'package:kapadokya_balon_app/data/datasources/auth_data_source.dart';
import 'package:kapadokya_balon_app/domain/entities/user.dart';
import 'package:kapadokya_balon_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await dataSource.login(email, password);
      return Right(userModel);
    } catch (e) {
      AppLogger.e('Login failed: $e');
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await dataSource.resetPassword(email);
      return const Right(null);
    } catch (e) {
      AppLogger.e('Reset password failed: $e');
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await dataSource.getCurrentUser();
      return Right(userModel);
    } catch (e) {
      AppLogger.e('Get current user failed: $e');
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await dataSource.logout();
      return const Right(null);
    } catch (e) {
      AppLogger.e('Logout failed: $e');
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final isAuthenticated = await dataSource.isAuthenticated();
      return Right(isAuthenticated);
    } catch (e) {
      AppLogger.e('Check authentication failed: $e');
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }
}