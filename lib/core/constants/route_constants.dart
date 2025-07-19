// route_constants.dart
//
// Uygulama içindeki tüm rota yollarını içeren sabitler.
// Yönlendirme için tutarlı ve merkezi bir tanımlama sağlar.


class RouteConstants {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String register = '/register';

  // Onboarding routes
  static const String faceRecognition = '/onboarding/face-recognition';
  static const String alcoholTest = '/onboarding/alcohol-test';
  static const String checklist = '/onboarding/checklist';
  static const String approvalWaiting = '/onboarding/approval-waiting';

  // Flight routes
  static const String sensorDashboard = '/flight/sensor-dashboard';
  static const String alerts = '/flight/alerts';
  static const String reportIssue = '/flight/report-issue';
  static const String map = '/flight/map';
  static const String flightSummary = '/flight/summary';
  static const String endFlight = '/flight/end-flight';
}