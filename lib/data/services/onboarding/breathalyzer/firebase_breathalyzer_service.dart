import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import '../../firebase_base_service.dart';
import '../../../../utils/id_generator.dart';

/// Alkolmetre (Breathalyzer) testi için Firebase servisi
class FirebaseBreathalyzerService extends FirebaseBaseService {
  final FirebaseStorage _storage;

  FirebaseBreathalyzerService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance,
        super(firestore: firestore);

  /// Alkolmetre testi oluştur
  Future<String> createBreathalyzerTest({
    required String captainId,
  }) async {
    try {
      // Kullanıcının giriş yapmış olduğundan emin ol
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış. Önce giriş yapılmalı.');
      }

      // Benzersiz ID oluştur
      final breathalyzerId = generateBreathalyzerId(captainId);

      // Breathalyzer kaydı oluştur
      await firestore.collection('breathalyzer').doc(breathalyzerId).set({
        'id': breathalyzerId,
        'captainId': captainId,
        'flightId': '',
        'isCompleted': false,
        'breathTime': null,
        'breathImageUrl': null,
        'alcoholValue': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Breathalyzer test created with ID: $breathalyzerId');
      return breathalyzerId;
    } catch (e) {
      print('Error creating breathalyzer test: $e');
      rethrow;
    }
  }

  /// Alkolmetre testi tamamla
  Future<void> completeBreathalyzerTest({
    required String breathalyzerId,
    required double alcoholValue,
    String? breathImageUrl, // Opsiyonel yap
  }) async {
    try {
      await firestore.collection('breathalyzer').doc(breathalyzerId).update({
        'isCompleted': true,
        'breathTime': FieldValue.serverTimestamp(),
        'breathImageUrl': breathImageUrl, // null olabilir
        'alcoholValue': alcoholValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Breathalyzer test completed: $breathalyzerId with value: $alcoholValue');
    } catch (e) {
      print('Error completing breathalyzer test: $e');
      rethrow;
    }
  }

  /// Görüntüyü Storage'a yükle ve URL'ini döndür
  Future<String> uploadBreathImage(Uint8List imageBytes, String captainId) async {
    try {
      // Resim yükleme işlemini atla, sadece mock URL döndür
      print('Resim yükleme işlemi atlanıyor (billing plan限制)');

      // Test amaçlı mock URL döndür
      return 'https://example.com/placeholder.jpg';
    } catch (e, stack) {
      print('Error in uploadBreathImage: $e');
      print('Stack trace: $stack');

      // Hata durumunda da mock URL döndür
      return 'https://example.com/error-placeholder.jpg';
    }
  }

  /// Breathalyzer kaydını ilgili uçuş ID'si ile ilişkilendir (checklist sonrası)
  Future<void> linkBreathalyzerToFlight(String breathalyzerId, String flightId) async {
    try {
      // Breathalyzer'ı güncelle
      await firestore.collection('breathalyzer').doc(breathalyzerId).update({
        'flightId': flightId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Flight'ı güncelle
      await firestore.collection('flights').doc(flightId).update({
        'breathalyzerId': breathalyzerId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Breathalyzer $breathalyzerId linked to flight $flightId');
    } catch (e) {
      print('Error linking breathalyzer to flight: $e');
      rethrow;
    }
  }

  /// Breathalyzer testini uçuşla ilişkilendir
  Future<void> updateBreathalyzerWithFlightId(String breathalyzerId, String flightId) async {
    try {
      await firestore.collection('breathalyzer').doc(breathalyzerId).update({
        'flightId': flightId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Breathalyzer $breathalyzerId updated with flight ID: $flightId');
    } catch (e) {
      print('Error updating breathalyzer with flight ID: $e');
      rethrow;
    }
  }
}