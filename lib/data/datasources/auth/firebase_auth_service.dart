import 'package:firebase_auth/firebase_auth.dart';
import 'package:kapadokya_balon_app/core/error/failures.dart';
import 'package:kapadokya_balon_app/data/models/user_model.dart';
import 'package:dartz/dartz.dart';
import 'package:kapadokya_balon_app/data/datasources/auth/auth_data_source.dart';

class FirebaseAuthService implements AuthDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  UserModel? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        photoUrl: user.photoURL,
      );
    }
    return null;
  }

  @override
  Stream<UserModel?> get userChanges => _firebaseAuth.authStateChanges().map(
        (user) => user != null
        ? UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      photoUrl: user.photoURL,
    )
        : null,
  );

  @override
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) {
        return Left(AuthenticationFailure(message: 'Giriş yapılamadı. Bilinmeyen hata.'));
      }

      return Right(UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        photoUrl: user.photoURL,
      ));
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Bu e-posta adresi kayıtlı değil.';
          break;
        case 'wrong-password':
          message = 'Hatalı şifre girdiniz.';
          break;
        case 'invalid-email':
          message = 'Geçersiz e-posta formatı.';
          break;
        case 'user-disabled':
          message = 'Bu hesap devre dışı bırakılmış.';
          break;
        default:
          message = 'Giriş yapılamadı: ${e.message}';
      }
      return Left(AuthenticationFailure(message: message));
    } catch (e) {
      return Left(AuthenticationFailure(message: 'Beklenmeyen bir hata oluştu: $e'));
    }
  }


  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      // Sadece gerçekten kritik hataları göster
      if (e.code == 'invalid-email') {
        return Left(AuthenticationFailure(message: 'Geçersiz e-posta formatı.'));
      }

      // "user-not-found" hatasını logla ama kullanıcıya gösterme
      if (e.code == 'user-not-found') {
        // Sadece loglama yapıyoruz, kullanıcıya göstermiyoruz
        print('E-posta bulunamadı: $email');
        // Güvenlik açısından başarılı dönelim
        return const Right(null);
      }

      // Diğer Firebase hataları
      print('Firebase Auth Hatası: ${e.code} - ${e.message}');
      return Left(AuthenticationFailure(
          message: 'İşlem sırasında bir hata oluştu. Lütfen daha sonra tekrar deneyin.'
      ));
    } catch (e) {
      print('Beklenmeyen Hata: $e');
      return Left(AuthenticationFailure(
          message: 'Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin.'
      ));
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<Either<Failure, UserModel>> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) {
        return Left(AuthenticationFailure(message: 'Kayıt yapılamadı. Bilinmeyen hata.'));
      }

      // Kullanıcı adını güncelle
      await user.updateDisplayName(name);

      return Right(UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: name,
        photoUrl: user.photoURL,
      ));
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Bu e-posta adresi zaten kullanılıyor.';
          break;
        case 'invalid-email':
          message = 'Geçersiz e-posta formatı.';
          break;
        case 'weak-password':
          message = 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
          break;
        default:
          message = 'Kayıt yapılamadı: ${e.message}';
      }
      return Left(AuthenticationFailure(message: message));
    } catch (e) {
      return Left(AuthenticationFailure(message: 'Beklenmeyen bir hata oluştu: $e'));
    }
  }
}