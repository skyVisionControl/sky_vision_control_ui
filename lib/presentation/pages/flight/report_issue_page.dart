// report_issue_page.dart
//
// Uçuş sırasında karşılaşılan sorunları bildirme sayfası.
//
// Yazan: Deniz Dogan
// Tarih: 2025-07-20

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapadokya_balon_app/core/themes/app_colors.dart';
import 'package:kapadokya_balon_app/core/themes/text_styles.dart';
import 'package:kapadokya_balon_app/domain/entities/flight/sensor_data.dart';
import 'package:kapadokya_balon_app/presentation/providers/flight_providers.dart';
import 'package:kapadokya_balon_app/presentation/widgets/buttons/app_button.dart';
import 'package:kapadokya_balon_app/presentation/widgets/feedback/app_message.dart';

class ReportIssuePage extends ConsumerStatefulWidget {
  const ReportIssuePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends ConsumerState<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  SensorType? _selectedSensorType;
  bool _isEmergency = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorun Bildir'),
        centerTitle: true,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isSuccess) {
      return _buildSuccessScreen();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Text(
              'Uçuş Sırasında Karşılaşılan Sorunu Bildirin',
              style: TextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              'Lütfen sorunun detaylarını belirtin. Acil bir durum varsa, acil durum kutucuğunu işaretleyin.',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            // Hata mesajı (varsa)
            if (_errorMessage != null) ...[
              AppMessage(
                message: _errorMessage!,
                type: MessageType.error,
                onClose: () => setState(() => _errorMessage = null),
              ),
              const SizedBox(height: 16),
            ],

            // Sorun başlığı
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Sorun Başlığı',
                hintText: 'Sorunu kısaca tanımlayın',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen bir başlık girin';
                }
                if (value.trim().length < 5) {
                  return 'Başlık en az 5 karakter olmalıdır';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Sorun açıklaması
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Sorun Açıklaması',
                hintText: 'Sorunu detaylı şekilde açıklayın',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLength: 500,
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen bir açıklama girin';
                }
                if (value.trim().length < 10) {
                  return 'Açıklama en az 10 karakter olmalıdır';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // İlgili sensör seçimi
            DropdownButtonFormField<SensorType?>(
              decoration: const InputDecoration(
                labelText: 'İlgili Sensör/Sistem',
                hintText: 'Sorunla ilgili bir sensör veya sistem seçin',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sensors),
              ),
              value: _selectedSensorType,
              items: [
                const DropdownMenuItem<SensorType?>(
                  value: null,
                  child: Text('Seçilmedi / Bilinmiyor'),
                ),
                ...SensorType.values.map((type) => DropdownMenuItem<SensorType?>(
                  value: type,
                  child: Text(_getSensorName(type)),
                )).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSensorType = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // Acil durum işaretleme
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isEmergency ? AppColors.error.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isEmergency ? AppColors.error : Colors.grey,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: _isEmergency ? AppColors.error : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Acil Durum',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isEmergency ? AppColors.error : AppColors.textPrimary,
                          ),
                        ),
                        const Text(
                          'Bu sorun acil müdahale gerektiriyor',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isEmergency,
                    onChanged: (value) {
                      setState(() {
                        _isEmergency = value;
                      });
                    },
                    activeColor: AppColors.error,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Gönder butonu
            AppButton(
              text: 'Sorunu Bildir',
              icon: Icons.send,
              isLoading: _isSubmitting,
              onPressed: _submitIssue,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.success,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sorun Bildirimi Gönderildi',
              style: TextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Sorun bildirimi başarıyla gönderildi. İlgili ekipler en kısa sürede değerlendirecektir.',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            if (_isEmergency) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.priority_high,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Acil durum bildirimi yapıldı. Operasyon merkezi bilgilendirildi.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            AppButton(
              text: 'Tamam',
              onPressed: () => Navigator.pop(context),
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitIssue() async {
    // Form validasyonu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Sorun bildirimi gönder
      final result = await ref.read(flightRepositoryProvider).reportIssue(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        relatedSensorType: _selectedSensorType,
      );

      // Acil durum modu aktifleştirme
      if (_isEmergency) {
        await ref.read(flightRepositoryProvider).toggleEmergencyMode(true);
      }

      // Sonucu kontrol et
      result.fold(
            (failure) {
          setState(() {
            _isSubmitting = false;
            _errorMessage = 'Sorun bildirimi gönderilemedi: ${failure.message}';
          });
        },
            (_) {
          setState(() {
            _isSubmitting = false;
            _isSuccess = true;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Beklenmeyen bir hata oluştu: $e';
      });
    }
  }

  String _getSensorName(SensorType type) {
    switch (type) {
      case SensorType.altitude:
        return 'Yükseklik Sensörü';
      case SensorType.temperature:
        return 'Sıcaklık Sensörü';
      case SensorType.pressure:
        return 'Basınç Sensörü';
      case SensorType.direction:
        return 'Yön Sensörü';
      case SensorType.speed:
        return 'Hız Sensörü';
      case SensorType.fuelLevel:
        return 'Yakıt Seviyesi';
      case SensorType.verticalSpeed:
        return 'Dikey Hız Sensörü';
      case SensorType.gpsPosition:
        return 'GPS/Konum Sistemi';
      case SensorType.humidity:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SensorType.acceleration:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SensorType.angularVelocity:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}