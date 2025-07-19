// auth_repository.dart
//
// Kimlik doğrulama işlemleri için repository arayüzü.
// Domain katmanında tanımlanan bu arayüz, veri kaynağından bağımsızdır.


import 'package:kapadokya_balon_app/domain/entities/user.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  /// Kullanıcı girişi yapar
  Future<Either<Failure, User>> login(String email, String password);

  /// Şifre sıfırlama e-postası gönderir
  Future<Either<Failure, void>> resetPassword(String email);

  /// Oturum açmış kullanıcıyı getirir (yoksa null)
  Future<Either<Failure, User?>> getCurrentUser();

  /// Oturumu kapatır
  Future<Either<Failure, void>> logout();

  /// Kullanıcının kimlik doğrulama durumunu kontrol eder
  Future<Either<Failure, bool>> isAuthenticated();
}