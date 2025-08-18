import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_base_service.dart';

/// Kaptan bilgilerinin Firebase'e kaydedilmesi için servis
class FirebaseCaptainService extends FirebaseBaseService {
  FirebaseCaptainService({FirebaseFirestore? firestore}) : super(firestore: firestore);

  /// Kaptan bilgilerini oluştur veya güncelle
  Future<void> createOrUpdateCaptain({
    required String captainId,
    required String email,
    String? password, // Şifre doğrudan veritabanında saklanmamalı, bu sadece demo amaçlı
    String? company,
  }) async {
    try {
      // Şifre doğrudan veritabanında saklanmamalı
      // Bu sadece demo amaçlı
      await firestore.collection('captains').doc(captainId).set({
        'id': captainId,
        'email': email,
        'company': company,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Captain created/updated in Firebase: $captainId');
    } catch (e) {
      print('Error creating/updating captain in Firebase: $e');
      rethrow;
    }
  }

  /// Kaptan bilgilerini ID'ye göre getir
  Future<Map<String, dynamic>?> getCaptainById(String captainId) async {
    try {
      final docSnapshot = await firestore.collection('captains').doc(captainId).get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      print('Error getting captain by ID: $e');
      rethrow;
    }
  }
}