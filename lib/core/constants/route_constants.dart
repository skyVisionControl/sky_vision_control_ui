// route_constants.dart
//
// Uygulama içindeki tüm rota yollarını içeren sabitler.
// Yönlendirme için tutarlı ve merkezi bir tanımlama sağlar.


class RouteConstants {
  // Auth Routes
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // Onboarding Routes
  static const String faceRecognition = '/onboarding/face-recognition';
  static const String alcoholTest = '/onboarding/alcohol-test';
  static const String checklist = '/onboarding/checklist';
  static const String approvalWaiting = '/onboarding/approval-waiting';

  // Flight Routes
  static const String sensorDashboard = '/flight/sensor-dashboard';
  static const String alert = '/flight/alert';
  static const String reportIssue = '/flight/report-issue';
  static const String endFlight = '/flight/end-flight';
}