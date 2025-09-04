import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/firebase_violation_service.dart';
import '../../data/services/rtsp_service.dart';
import '../../data/services/yolo_detection_service.dart';
import '../../data/services/fire_detection_service.dart';
import '../../data/repositories/fire_detection_repository_impl.dart';
import '../../domain/repositories/fire_detection_repository.dart';
import '../../domain/usecases/fire_detection/start_fire_detection_service_usecase.dart';
import '../../domain/usecases/fire_detection/stop_fire_detection_service_usecase.dart';
import 'firebase_providers.dart';
import 'common_providers.dart'; // Ortak provider'ları import et

// RTSP ayarları
final rtspUrlProvider = Provider<String>((ref) => 'rtsp://skyvision:sky123456@192.168.1.49:554/stream1');
final captureIntervalProvider = Provider<Duration>((ref) => const Duration(seconds: 5));

// YOLO ayarları
final yoloModelAssetNameProvider = Provider<String>((ref) => 'yolo8n.tflite');
final yoloClassNamesProvider = Provider<List<String>>((ref) => const ['fire', 'smoke']);

// Services
final rtspServiceProvider = Provider<RtspService>((ref) {
  final rtspUrl = ref.watch(rtspUrlProvider);
  final captureInterval = ref.watch(captureIntervalProvider);
  return RtspService(rtspUrl: rtspUrl, captureInterval: captureInterval);
});

final yoloDetectionServiceProvider = Provider<YoloDetectionService>((ref) {
  final modelAssetName = ref.watch(yoloModelAssetNameProvider);
  final classNames = ref.watch(yoloClassNamesProvider);
  return YoloDetectionService(modelAssetName: modelAssetName, classNames: classNames);
});

final firebaseViolationServiceProvider = Provider<FirebaseViolationService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirebaseViolationService(firestore: firestore);
});

final fireDetectionServiceProvider = Provider<FireDetectionService>((ref) {
  final rtspService = ref.watch(rtspServiceProvider);
  final yoloService = ref.watch(yoloDetectionServiceProvider);
  final violationService = ref.watch(firebaseViolationServiceProvider);

  return FireDetectionService(
    rtspService: rtspService,
    yoloService: yoloService,
    violationService: violationService,
  );
});

// Repository
final fireDetectionRepositoryProvider = Provider<FireDetectionRepository>((ref) {
  final fireDetectionService = ref.watch(fireDetectionServiceProvider);
  final violationService = ref.watch(firebaseViolationServiceProvider);

  return FireDetectionRepositoryImpl(fireDetectionService, violationService);
});

// Use Cases
final startFireDetectionServiceUseCaseProvider = Provider<StartFireDetectionServiceUseCase>((ref) {
  final repository = ref.watch(fireDetectionRepositoryProvider);
  return StartFireDetectionServiceUseCase(repository);
});

final stopFireDetectionServiceUseCaseProvider = Provider<StopFireDetectionServiceUseCase>((ref) {
  final repository = ref.watch(fireDetectionRepositoryProvider);
  return StopFireDetectionServiceUseCase(repository);
});

// currentFlightIdProvider common_providers.dart dosyasından kullanılacak