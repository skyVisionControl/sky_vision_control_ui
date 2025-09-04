// onboarding_status.dart
//
// Uçuş öncesi onboarding sürecinin durumunu temsil eden entity.
// Her bir adımın tamamlanma durumunu ve genel durumu içerir.

import 'package:equatable/equatable.dart';

enum OnboardingStep {
  faceRecognition,
  alcoholTest,
  checklist,
  approval
}

enum ApprovalStatus {
  pending,
  approved,
  rejected
}

class OnboardingStatus extends Equatable {
  final bool isFaceRecognitionCompleted;
  final bool isAlcoholTestCompleted;
  final bool isChecklistCompleted;
  final ApprovalStatus approvalStatus;
  final String? rejectionReason;
  final DateTime? completedTime;

  const OnboardingStatus({
    this.isFaceRecognitionCompleted = false,
    this.isAlcoholTestCompleted = false,
    this.isChecklistCompleted = false,
    this.approvalStatus = ApprovalStatus.pending,
    this.rejectionReason,
    this.completedTime,
  });

  bool get isCompleted =>
      isFaceRecognitionCompleted &&
          isAlcoholTestCompleted &&
          isChecklistCompleted &&
          approvalStatus == ApprovalStatus.approved;

  OnboardingStep get currentStep {
    if (!isFaceRecognitionCompleted) return OnboardingStep.faceRecognition;
    if (!isAlcoholTestCompleted) return OnboardingStep.alcoholTest;
    if (!isChecklistCompleted) return OnboardingStep.checklist;
    return OnboardingStep.approval;
  }

  OnboardingStatus copyWith({
    bool? isFaceRecognitionCompleted,
    bool? isAlcoholTestCompleted,
    bool? isChecklistCompleted,
    ApprovalStatus? approvalStatus,
    String? rejectionReason,
    DateTime? completedTime,
  }) {
    return OnboardingStatus(
      isFaceRecognitionCompleted: isFaceRecognitionCompleted ?? this.isFaceRecognitionCompleted,
      isAlcoholTestCompleted: isAlcoholTestCompleted ?? this.isAlcoholTestCompleted,
      isChecklistCompleted: isChecklistCompleted ?? this.isChecklistCompleted,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      completedTime: completedTime ?? this.completedTime,
    );
  }

  @override
  List<Object?> get props => [
    isFaceRecognitionCompleted,
    isAlcoholTestCompleted,
    isChecklistCompleted,
    approvalStatus,
    rejectionReason,
    completedTime
  ];
}