// user.dart
//
// Kullanıcı varlığını tanımlayan domain katmanı sınıfı.
// Kullanıcı bilgilerini içerir (kimlik, ad, yetki vb.).


import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime? lastLogin;
  final bool isActive;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.lastLogin,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, email, role, lastLogin, isActive];

  bool get isPilot => role == 'pilot';
  bool get isAdmin => role == 'admin';
  bool get isAviation => role == 'aviation';
}