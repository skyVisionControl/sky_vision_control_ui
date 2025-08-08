// checklist_page.dart
//
// Uçuş öncesi kontrol listesi sayfası.
// Pilotun uçuş öncesi tamamlaması gereken kontrolleri içerir.
//
// Yazan: Deniz Dogan
// Tarih: 2025-07-19

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapadokya_balon_app/core/constants/route_constants.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/domain/entities/checklist_item.dart';
import 'package:kapadokya_balon_app/presentation/providers/onboarding_providers.dart';
import 'package:kapadokya_balon_app/presentation/widgets/buttons/app_button.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/loading_indicator.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/app_message.dart';
import '../../../utils/id_generator.dart';
import '../../providers/auth_providers.dart';
import '../../providers/firebase_providers.dart';

class ChecklistPage extends ConsumerStatefulWidget {
  const ChecklistPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends ConsumerState<ChecklistPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _noteController = TextEditingController();
  ChecklistItem? _selectedItem;

  @override
  void initState() {
    super.initState();

    // Tüm async ve provider işlemlerini widget ağacı tamamen oluşturulduktan sonra yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Önce checklist verilerini yükle
      _initChecklistSafely();

      // Sonra Firebase için uçuş verisi oluştur
      _initializeFirebaseSafely();
    });
  }

  // Checklist'i güvenli bir şekilde yükle (widget ağacı dışında)
  void _initChecklistSafely() {
    try {
      ref.read(onboardingViewModelProvider.notifier).loadChecklistItems();
    } catch (e) {
      print('Error loading checklist items: $e');
    }
  }

  // Firebase uçuş kaydını güvenli bir şekilde oluştur (widget ağacı dışında)
  void _initializeFirebaseSafely() {
    try {
      // Kullanıcı bilgisini al
      final userState = ref.read(authViewModelProvider);
      final user = userState.user;

      if (user == null) {
        print('Cannot create flight in Firebase: User is null');
        return;
      }

      // Sabit tarih ve saat bilgisiyle bir uçuş ID'si oluştur
      final flightId = generateFlightId(user.name);

      // Firebase servisini kullanarak uçuş kaydı oluştur
      final firebaseService = ref.read(firebaseChecklistServiceProvider);
      firebaseService.createOrUpdateFlight(
        flightId: flightId,
        captainId: user.id,
      );

      print('Flight created in Firebase with ID: $flightId');
    } catch (e) {
      print('Firebase flight creation error: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);
    final isLoading = state.isLoading;
    final errorMessage = state.errorMessage;

    // Checklist tamamlandıysa bir sonraki sayfaya yönlendir
    if (state.status != null && state.status!.isChecklistCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RouteConstants.approvalWaiting);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uçuş Öncesi Kontrol Listesi'),
        centerTitle: true,
        actions: [
          // Tamamlanma durumu göstergesi
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildCompletionIndicator(state.checklistItems),
          ),
        ],
      ),
      body: isLoading
          ? const PageLoading(message: 'Kontrol listesi yükleniyor...')
          : _buildContent(errorMessage),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildContent(String? errorMessage) {
    final state = ref.watch(onboardingViewModelProvider);
    final checklistItems = state.checklistItems;

    if (checklistItems.isEmpty) {
      return const Center(
        child: Text('Kontrol listesi bulunamadı.'),
      );
    }

    return Column(
      children: [
        // Hata mesajı (varsa)
        if (errorMessage != null) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppMessage(
              message: errorMessage,
              type: MessageType.error,
              onClose: () => ref.read(onboardingViewModelProvider.notifier).clearError(),
            ),
          ),
        ],

        // Checklist öğeleri
        Expanded(
          child: _buildChecklistItems(checklistItems),
        ),
      ],
    );
  }

  Widget _buildChecklistItems(List<ChecklistItem> items) {
    // Kategori bazlı gruplanmış öğeler
    final Map<String, List<ChecklistItem>> groupedItems = {};

    // Öğeleri kategorilere göre grupla
    for (var item in items) {
      if (!groupedItems.containsKey(item.category)) {
        groupedItems[item.category] = [];
      }
      groupedItems[item.category]!.add(item);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final category = groupedItems.keys.elementAt(index);
        final categoryItems = groupedItems[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori başlığı
            _buildCategoryHeader(category),

            // Kategori öğeleri
            ...categoryItems.map((item) => _buildChecklistItemCard(item)).toList(),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildCategoryHeader(String category) {
    return Container(
      margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.playlist_add_check,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              category,
              style: TextStyles.heading4.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItemCard(ChecklistItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () => _toggleItemCompletion(item),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Checkbox(
                value: item.isCompleted,
                onChanged: (_) => _toggleItemCompletion(item),
                activeColor: AppColors.primary,
              ),

              // Task detayı
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                        color: item.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                    ),

                    // Not varsa göster
                    if (item.note != null && item.note!.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.note,
                              size: 16.0,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                item.note!,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Not ekle butonu
              IconButton(
                icon: const Icon(Icons.note_add_outlined, size: 20.0),
                onPressed: () => _showNoteDialog(item),
                color: AppColors.secondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionIndicator(List<ChecklistItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Tamamlanan zorunlu öğelerin sayısı
    final completedMandatory = items.where((item) => item.isCompleted && item.isMandatory).length;
    final totalMandatory = items.where((item) => item.isMandatory).length;

    // Tamamlanma yüzdesi
    final percentage = totalMandatory > 0 ? (completedMandatory / totalMandatory * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: _getCompletionColor(percentage).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCompletionIcon(percentage),
            size: 16.0,
            color: _getCompletionColor(percentage),
          ),
          const SizedBox(width: 4.0),
          Text(
            '$percentage%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getCompletionColor(percentage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final state = ref.watch(onboardingViewModelProvider);
    final isSubmitting = state.isChecklistSubmitting;
    final items = state.checklistItems;

    // Tamamlanan zorunlu öğelerin sayısı
    final completedMandatory = items.where((item) => item.isCompleted && item.isMandatory).length;
    final totalMandatory = items.where((item) => item.isMandatory).length;

    // Tüm zorunlu öğeler tamamlandı mı?
    final allMandatoryCompleted = completedMandatory == totalMandatory;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tamamlanma durumu mesajı
            if (!allMandatoryCompleted) ...[
              const AppMessage(
                message: 'Tüm zorunlu kontrolleri tamamlamanız gerekmektedir.',
                type: MessageType.warning,
                icon: Icons.warning,
              ),
              const SizedBox(height: 16.0),
            ],

            // Tamamla butonu
            AppButton(
              text: 'Kontrol Listesini Tamamla',
              icon: Icons.check_circle,
              onPressed: allMandatoryCompleted && !isSubmitting
                  ? _completeChecklistWithFirebase
                  : null,
              isLoading: isSubmitting,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleItemCompletion(ChecklistItem item) {
    final updatedItem = item.copyWith(isCompleted: !item.isCompleted);

    // Mevcut state güncelleme
    ref.read(onboardingViewModelProvider.notifier).updateChecklistItem(updatedItem);

    // Firebase'e kaydet - widget ağacının dışında
    Future(() {
      _saveItemToFirebaseSafely(updatedItem);
    });
  }

  void _saveItemToFirebaseSafely(ChecklistItem item) {
    try {
      // Kullanıcı bilgisini al
      final userState = ref.read(authViewModelProvider);
      final user = userState.user;

      if (user == null) {
        print('Cannot save item to Firebase: User is null');
        return;
      }

      // Sabit tarih ve saat bilgisiyle bir uçuş ID'si oluştur
      final flightId = generateFlightId(user.name);

      // Firebase servisini kullanarak checklist öğesini kaydet
      final firebaseService = ref.read(firebaseChecklistServiceProvider);
      firebaseService.saveChecklistItem(
        item: item,
        flightId: flightId,
        captainId: user.id,
      );

      print('Checklist item saved to Firebase: ${item.id}');
    } catch (e) {
      print('Firebase item save error: $e');
    }
  }

  void _showNoteDialog(ChecklistItem item) {
    _selectedItem = item;
    _noteController.text = item.note ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not Ekle'),
        content: TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            hintText: 'Not eklemek için buraya yazın...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveNote();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _saveNote() {
    if (_selectedItem == null) return;

    final updatedItem = _selectedItem!.copyWith(
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    // Mevcut state güncelleme
    ref.read(onboardingViewModelProvider.notifier).updateChecklistItem(updatedItem);

    // Firebase'e kaydet - widget ağacının dışında
    Future(() {
      _saveItemToFirebaseSafely(updatedItem);
    });

    _selectedItem = null;
  }

  // Firebase entegrasyonu ile tamamlama işlemi
  void _completeChecklistWithFirebase() {
    // Mevcut checklist tamamlama metodu
    ref.read(onboardingViewModelProvider.notifier).completeChecklist();

    // Firebase'e kaydet - widget ağacının dışında
    Future(() {
      _completeChecklistInFirebaseSafely();
    });
  }

  void _completeChecklistInFirebaseSafely() {
    try {
      // Kullanıcı bilgisini al
      final userState = ref.read(authViewModelProvider);
      final user = userState.user;

      if (user == null) {
        print('Cannot complete checklist in Firebase: User is null');
        return;
      }

      // Sabit tarih ve saat bilgisiyle bir uçuş ID'si oluştur
      final flightId = generateFlightId(user.name);

      // Tüm checklist öğelerini al
      final items = ref.read(onboardingViewModelProvider).checklistItems;

      // Firebase servisini kullanarak işlemleri yap
      final firebaseService = ref.read(firebaseChecklistServiceProvider);

      // Önce uçuş kaydını oluştur
      firebaseService.createOrUpdateFlight(
        flightId: flightId,
        captainId: user.id,
      );

      // Sonra checklist öğelerini kaydet
      firebaseService.saveCompletedChecklist(
        items: items,
        flightId: flightId,
        captainId: user.id,
      );

      print('Checklist completed and saved to Firebase with ID: $flightId');
    } catch (e) {
      print('Firebase checklist completion error: $e');
    }
  }

  Color _getCompletionColor(int percentage) {
    if (percentage < 30) return AppColors.error;
    if (percentage < 70) return AppColors.warning;
    if (percentage < 100) return Colors.orange;
    return AppColors.success;
  }

  IconData _getCompletionIcon(int percentage) {
    if (percentage < 30) return Icons.error_outline;
    if (percentage < 70) return Icons.warning_amber_outlined;
    if (percentage < 100) return Icons.timelapse;
    return Icons.check_circle_outline;
  }
}