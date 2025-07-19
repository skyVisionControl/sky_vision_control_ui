// auth_data_source.dart
//
// Kimlik doğrulama işlemleri için veri kaynağı arayüzü ve mock implementasyonu.
// İleride Firebase ile değiştirilecektir.

import 'package:kapadokya_balon_app/data/models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> resetPassword(String email);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<bool> isAuthenticated();
}

class MockAuthDataSource implements AuthDataSource {
  // Mock kullanıcı verisi
  final _mockUsers = [
    {
      'id': '1',
      'name': 'Test Pilot',
      'email': 'pilot@example.com',
      'password': 'password123',
      'role': 'pilot',
      'lastLogin': DateTime.now().toIso8601String(),
      'isActive': true,
    },
    {
      'id': '2',
      'name': 'Admin User',
      'email': 'admin@example.com',
      'password': 'admin123',
      'role': 'admin',
      'lastLogin': DateTime.now().toIso8601String(),
      'isActive': true,
    },
  ];

  UserModel? _currentUser;

  @override
  Future<UserModel> login(String email, String password) async {
    // Gecikme simülasyonu
    await Future.delayed(const Duration(seconds: 1));

    final user = _mockUsers.firstWhere(
          (user) => user['email'] == email && user['password'] == password,
      orElse: () => throw Exception('Geçersiz e-posta veya şifre'),
    );

    _currentUser = UserModel.fromJson(user);
    return _currentUser!;
  }

  @override
  Future<void> resetPassword(String email) async {
    // Gecikme simülasyonu
    await Future.delayed(const Duration(seconds: 1));

    final userExists = _mockUsers.any((user) => user['email'] == email);
    if (!userExists) {
      throw Exception('Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı');
    }

    // Gerçek uygulamada burada şifre sıfırlama e-postası gönderilecek
    return;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Gecikme simülasyonu
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    // Gecikme simülasyonu
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    return;
  }

  @override
  Future<bool> isAuthenticated() async {
    // Gecikme simülasyonu
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser != null;
  }
}