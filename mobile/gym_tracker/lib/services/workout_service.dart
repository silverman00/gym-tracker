import '../models/workout.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class WorkoutService {
  static Future<Workout> createWorkout(Map<String, dynamic> body) async {
    final data = await ApiService.post(
      AppConstants.workoutsBase,
      body,
      requiresAuth: true,
    );
    return Workout.fromJson(data as Map<String, dynamic>);
  }

  static Future<List<Workout>> getUserWorkouts(int userId) async {
    final data =
        await ApiService.get('${AppConstants.workoutsBase}/user/$userId');
    return (data as List<dynamic>)
        .map((w) => Workout.fromJson(w as Map<String, dynamic>))
        .toList();
  }

  static Future<Workout> getWorkout(int workoutId) async {
    final data = await ApiService.get('${AppConstants.workoutsBase}/$workoutId');
    return Workout.fromJson(data as Map<String, dynamic>);
  }

  static Future<Workout> updateWorkout(
      int workoutId, Map<String, dynamic> body) async {
    final data =
        await ApiService.put('${AppConstants.workoutsBase}/$workoutId', body);
    return Workout.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteWorkout(int workoutId) =>
      ApiService.delete('${AppConstants.workoutsBase}/$workoutId');
}
