// get_current_user_usecase.dart
//
// Mevcut kullanıcıyı döndüren use case.

import 'package:kapadokya_balon_app/domain/entities/auth/user.dart';
import 'package:kapadokya_balon_app/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  User? call() {
    return repository.getCurrentUser();
  }
}