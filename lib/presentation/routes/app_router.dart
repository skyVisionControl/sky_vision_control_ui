// app_router.dart - düzeltilmiş versiyon
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapadokya_balon_app/core/constants/route_constants.dart';
import 'package:kapadokya_balon_app/presentation/pages/auth/forgot_password_page.dart';
import 'package:kapadokya_balon_app/presentation/pages/auth/login_page.dart';
import 'package:kapadokya_balon_app/presentation/pages/onboarding/approval_waiting_page.dart';
import 'package:kapadokya_balon_app/presentation/pages/onboarding/checklist_page.dart';
import 'package:kapadokya_balon_app/presentation/pages/onboarding/face_recognition_page.dart';
import 'package:kapadokya_balon_app/presentation/pages/onboarding/alcohol_test_page.dart';
import 'package:kapadokya_balon_app/presentation/pages/placeholder_pages.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // İleride auth state listener eklenebilir
  return GoRouter(
    initialLocation: RouteConstants.login,
    debugLogDiagnostics: true,
    routes: [
      // Auth Routes
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Onboarding Routes
      GoRoute(
        path: RouteConstants.faceRecognition,
        builder: (context, state) => const FaceRecognitionPage(),
      ),
      GoRoute(
        path: RouteConstants.alcoholTest,
        builder: (context, state) => const AlcoholTestPage(),
      ),
      GoRoute(
        path: RouteConstants.checklist,
        builder: (context, state) => const ChecklistPage(),
      ),
      GoRoute(
        path: RouteConstants.approvalWaiting,
        builder: (context, state) => const ApprovalWaitingPage(),
      ),

      // Flight Routes
      GoRoute(
        path: RouteConstants.sensorDashboard,
        builder: (context, state) => const SensorDashboardPage(),
      ),
      GoRoute(
        path: RouteConstants.alerts,
        builder: (context, state) => const AlertPage(),
      ),
      GoRoute(
        path: RouteConstants.reportIssue,
        builder: (context, state) => const ReportIssuePage(),
      ),
      GoRoute(
        path: RouteConstants.endFlight,
        builder: (context, state) => const EndFlightPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Sayfa bulunamadı: ${state.error}'),
      ),
    ),
  );
});