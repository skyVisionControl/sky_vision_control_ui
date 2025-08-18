import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/firebase_checklist_service.dart';
import '../../data/services/firebase_flight_service.dart';
import '../../data/services/firebase_captain_service.dart';

// Firebase instance provider
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
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