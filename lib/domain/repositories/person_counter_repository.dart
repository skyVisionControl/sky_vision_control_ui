import '../entities/person_count.dart';

abstract class PersonCounterRepository {
  Future<void> startPersonCounting(String flightId, String rtspUrl);
  Future<void> stopPersonCounting();
  Stream<PersonCount?> observePersonCount();
}