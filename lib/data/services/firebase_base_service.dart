import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase servislerinin temel sınıfı
class FirebaseBaseService {
  final FirebaseFirestore _firestore;

  FirebaseBaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Firestore instance'ına erişim
  FirebaseFirestore get firestore => _firestore;

  /// Tarih formatını düzenle
  String formatDate(DateTime date) {
    return date.toIso8601String();
  }

  /// Şu anki tarihi formatla
  String getCurrentDateFormatted() {
    return formatDate(DateTime.now());
  }

  /// Timestamp'i DateTime'a çevir
  DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return null;
  }
}