import '../../repositories/person_counter_repository.dart';

class StartPersonCountingUseCase {
  final PersonCounterRepository repository;

  StartPersonCountingUseCase(this.repository);

  Future<void> execute(String flightId, String rtspUrl) { // captainId repository'den
    return repository.startPersonCounting(flightId, rtspUrl);
  }
}