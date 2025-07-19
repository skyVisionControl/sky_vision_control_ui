// failures.dart
//
// Uygulama genelinde kullanılan hata türlerini tanımlar.
// Farklı türdeki hatalar için sınıflar içerir (ağ hataları, kimlik doğrulama hataları vb.).

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

// Sunucu Hataları
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

// Bağlantı Hataları
class ConnectionFailure extends Failure {
  const ConnectionFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

// Kimlik Doğrulama Hataları
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

// Veri Hataları
class DataFailure extends Failure {
  const DataFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

// İzin Hataları
class PermissionFailure extends Failure {
  const PermissionFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

// Cache Hataları
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}