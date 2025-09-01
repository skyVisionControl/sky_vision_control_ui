import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/firebase_checklist_service.dart';
import '../../data/services/firebase_flight_service.dart';
import '../../data/services/firebase_captain_service.dart';
import '../../data/services/firebase_breathalyzer_service.dart';

// Firebase instance provider
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Firebase storage provider
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

// Firebase checklist service provider
final firebaseChecklistServiceProvider = Provider<FirebaseChecklistService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirebaseChecklistService(firestore: firestore);
});

// Firebase flight service provider
final firebaseFlightServiceProvider = Provider<FirebaseFlightService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirebaseFlightService(firestore: firestore);
});

// Firebase captain service provider
final firebaseCaptainServiceProvider = Provider<FirebaseCaptainService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirebaseCaptainService(firestore: firestore);
});

// Firebase breathalyzer service provider
final firebaseBreathalyzerServiceProvider = Provider<FirebaseBreathalyzerService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);
  return FirebaseBreathalyzerService(firestore: firestore, storage: storage);
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final rtdbEuProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instanceFor(
    databaseURL: 'https://sky-vision-control-5ca1b-default-rtdb.europe-west1.firebasedatabase.app', app: FirebaseDatabase.instance.app,
  );
});

// Uygulama akışında o an aktif olan uçuşun kimliği.
// Checklist tamamlandıktan sonra set edilecek.
final currentFlightIdProvider = StateProvider<String?>((ref) => null);