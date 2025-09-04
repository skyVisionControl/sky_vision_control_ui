import 'package:flutter_riverpod/flutter_riverpod.dart';

// Uygulama genelinde kullanılacak olan ortak provider'lar

/// Uygulama akışında o an aktif olan uçuşun kimliği.
/// Checklist tamamlandıktan sonra set edilecek.
final currentFlightIdProvider = StateProvider<String?>((ref) => null);