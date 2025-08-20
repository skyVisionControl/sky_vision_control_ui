import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/breathalyzer_view_model.dart';
import 'firebase_providers.dart';

final breathalyzerViewModelProvider = StateNotifierProvider<BreathalyzerViewModel, BreathalyzerState>((ref) {
  final breathalyzerService = ref.watch(firebaseBreathalyzerServiceProvider);
  return BreathalyzerViewModel(breathalyzerService);
});