class AppConstants {
  // ── API Gateway URL ────────────────────────────────────────────────────────
  static const String baseUrl = 'http://localhost:8080';

  // ── API Endpoints ──────────────────────────────────────────────────────────
  static const String signUpEndpoint      = '/api/auth/signup';
  static const String loginEndpoint       = '/api/auth/login';
  static const String userProfileBase     = '/api/users';
  static const String workoutsBase        = '/api/workouts';
  static const String pointsBase          = '/api/points';
  static const String leaderboardEndpoint = '/api/points/leaderboard';

  // ── UI ─────────────────────────────────────────────────────────────────────
  static const String appName       = 'GymTracker';
  static const double defaultPadding = 16.0;
  static const double borderRadius   = 12.0;

  // ── Points per workout ─────────────────────────────────────────────────────
  static const int pointsPerWorkout = 10;
}