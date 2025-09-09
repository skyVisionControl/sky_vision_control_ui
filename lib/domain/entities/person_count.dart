class PersonCount {
  final int count;
  final double confidence;
  final DateTime timestamp;

  PersonCount({
    required this.count,
    required this.confidence,
    required this.timestamp,
  });

  factory PersonCount.fromJson(Map<String, dynamic> json) {
    return PersonCount(
      count: json['count'] ?? 0,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : DateTime.now(),
    );
  }
}