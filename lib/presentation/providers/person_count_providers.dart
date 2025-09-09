import 'package:kapadokya_balon_app/presentation/providers/sensor_providers.dart';
import 'package:riverpod/riverpod.dart';
import '../../../data/repositories/person_counter_repository_impl.dart';
import '../../../data/services/firebase_violation_service.dart';
import '../../../domain/usecases/person/start_person_counting_usecase.dart';
import '../../../domain/repositories/person_counter_repository.dart';
import '../../../presentation/providers/auth_providers.dart';
import 'fire_detection_providers.dart'; // captainId için auth user'dan al

final personCounterRepositoryProvider = Provider.family<PersonCounterRepository, String>((ref, captainId) {
  return PersonCounterRepositoryImpl(
    captainId: captainId, // Family provider ile captainId geç
    rtdbService: ref.watch(firebaseRtdbServiceProvider),
    violationService: ref.watch(firebaseViolationServiceProvider),
  );
});

final startPersonCountingUseCaseProvider = Provider.family<StartPersonCountingUseCase, String>((ref, captainId) {
  final repo = ref.watch(personCounterRepositoryProvider(captainId));
  return StartPersonCountingUseCase(repo);
});