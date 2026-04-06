import '../models/points.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class PointsService {
  static Future<UserPoints> getUserPoints(int userId) async {
    final data =
        await ApiService.get('${AppConstants.pointsBase}/user/$userId');
    return UserPoints.fromJson(data as Map<String, dynamic>);
  }

  static Future<List<LeaderboardEntry>> getLeaderboard() async {
    final data = await ApiService.get(AppConstants.leaderboardEndpoint);
    return (data as List<dynamic>)
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<UserPoints> addWorkoutPoints({
    required int userId,
    required String username,
    required int workoutId,
  }) async {
    final data = await ApiService.post(
      '${AppConstants.pointsBase}/workout-complete?workoutId=$workoutId',
      {},
      requiresAuth: true,
    );
    return UserPoints.fromJson(data as Map<String, dynamic>);
  }
}
