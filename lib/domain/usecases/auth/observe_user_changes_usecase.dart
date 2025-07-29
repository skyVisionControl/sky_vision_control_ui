// observe_user_changes_usecase.dart
//
// Kullanıcı değişikliklerini izleyen use case.

import 'package:kapadokya_balon_app/domain/entities/user.dart';
import 'package:kapadokya_balon_app/domain/repositories/auth_repository.dart';

class ObserveUserChangesUseCase {
  final AuthRepository repository;

  ObserveUserChangesUseCase(this.repository);

  Stream<User?> call() {
    return repository.userChanges;
  }
}