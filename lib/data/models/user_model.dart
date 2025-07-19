// user_model.dart
//
// User entity'sinin veri katmanı modellemesi.
// API'den gelen verileri domain katmanı entity'sine dönüştürür.


import 'package:kapadokya_balon_app/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String name,
    required String email,
    required String role,
    DateTime? lastLogin,
    bool isActive = true,
  }) : super(
    id: id,
    name: name,
    email: email,
    role: role,
    lastLogin: lastLogin,
    isActive: isActive,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
    };
  }
}