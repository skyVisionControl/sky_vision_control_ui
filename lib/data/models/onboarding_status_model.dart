// onboarding_status_model.dart
//
// OnboardingStatus entity'sinin data layer modeli.

import 'package:kapadokya_balon_app/domain/entities/onboarding/onboarding_status.dart';

class OnboardingStatusModel extends OnboardingStatus {
  const OnboardingStatusModel({
    bool isFaceRecognitionCompleted = false,
    bool isAlcoholTestCompleted = false,
    bool isChecklistCompleted = false,
    ApprovalStatus approvalStatus = ApprovalStatus.pending,
    String? rejectionReason,
    DateTime? completedTime,
  }) : super(
    isFaceRecognitionCompleted: isFaceRecognitionCompleted,
    isAlcoholTestCompleted: isAlcoholTestCompleted,
    isChecklistCompleted: isChecklistCompleted,
    approvalStatus: approvalStatus,
    rejectionReason: rejectionReason,
    completedTime: completedTime,
  );

  factory OnboardingStatusModel.fromJson(Map<String, dynamic> json) {
    return OnboardingStatusModel(
      isFaceRecognitionCompleted: json['isFaceRecognitionCompleted'] as bool? ?? false,
      isAlcoholTestCompleted: json['isAlcoholTestCompleted'] as bool? ?? false,
      isChecklistCompleted: json['isChecklistCompleted'] as bool? ?? false,
      approvalStatus: _parseApprovalStatus(json['approvalStatus']),
      rejectionReason: json['rejectionReason'] as String?,
      completedTime: json['completedTime'] != null
          ? DateTime.parse(json['completedTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isFaceRecognitionCompleted': isFaceRecognitionCompleted,
      'isAlcoholTestCompleted': isAlcoholTestCompleted,
      'isChecklistCompleted': isChecklistCompleted,
      'approvalStatus': approvalStatus.toString().split('.').last,
      'rejectionReason': rejectionReason,
      'completedTime': completedTime?.toIso8601String(),
    };
  }

  static ApprovalStatus _parseApprovalStatus(dynamic value) {
    if (value == null) return ApprovalStatus.pending;

    if (value is String) {
      switch (value.toLowerCase()) {
        case 'approved':
          return ApprovalStatus.approved;
        case 'rejected':
          return ApprovalStatus.rejected;
        default:
          return ApprovalStatus.pending;
      }
    }

    return ApprovalStatus.pending;
  }
}