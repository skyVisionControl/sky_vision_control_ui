/// Alkolmetre testi entity
class BreathalyzerTest {
  final String id;
  final String flightId;
  final bool isCompleted;
  final DateTime? breathTime;
  final String? breathImageUrl;
  final double? alcoholValue;

  const BreathalyzerTest({
    required this.id,
    required this.flightId,
    this.isCompleted = false,
    this.breathTime,
    this.breathImageUrl,
    this.alcoholValue,
  });

  BreathalyzerTest copyWith({
    String? id,
    String? flightId,
    bool? isCompleted,
    DateTime? breathTime,
    String? breathImageUrl,
    double? alcoholValue,
  }) {
    return BreathalyzerTest(
      id: id ?? this.id,
      flightId: flightId ?? this.flightId,
      isCompleted: isCompleted ?? this.isCompleted,
      breathTime: breathTime ?? this.breathTime,
      breathImageUrl: breathImageUrl ?? this.breathImageUrl,
      alcoholValue: alcoholValue ?? this.alcoholValue,
    );
  }
}