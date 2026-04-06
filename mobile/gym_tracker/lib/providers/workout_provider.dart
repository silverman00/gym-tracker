import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import '../services/points_service.dart';
import '../utils/token_manager.dart';

class WorkoutProvider extends ChangeNotifier {
  List<Workout> _workouts = [];
  bool _isLoading = false;
  String? _error;

  List<Workout> get workouts => List.unmodifiable(_workouts);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWorkouts(int userId) async {
    _setLoading(true);
    try {
      _workouts = await WorkoutService.getUserWorkouts(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createWorkout({
    required String name,
    String? description,
    String type = 'STRENGTH',
    String difficulty = 'INTERMEDIATE',
    int? durationMinutes,
    String? workoutDate,
    bool completed = false,
    int? caloriesBurned,
    String? notes,
    List<Map<String, dynamic>> exercises = const [],
  }) async {
    _setLoading(true);
    try {
      final workout = await WorkoutService.createWorkout({
        'name': name,
        if (description != null) 'description': description,
        'type': type,
        'difficulty': difficulty,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
        if (workoutDate != null) 'workoutDate': workoutDate,
        'completed': completed,
        if (caloriesBurned != null) 'caloriesBurned': caloriesBurned,
        if (notes != null) 'notes': notes,
        'exercises': exercises,
      });

      _workouts.insert(0, workout);
      _error = null;

      // Award points if workout is marked completed
      if (completed && workout.id != null) {
        await _awardPoints(workout.id!);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> markComplete(int workoutId) async {
    try {
      final updated = await WorkoutService.updateWorkout(workoutId, {'completed': true});
      final idx = _workouts.indexWhere((w) => w.id == workoutId);
      if (idx != -1) _workouts[idx] = updated;

      await _awardPoints(workoutId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWorkout(int workoutId) async {
    try {
      await WorkoutService.deleteWorkout(workoutId);
      _workouts.removeWhere((w) => w.id == workoutId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _awardPoints(int workoutId) async {
    final userId = await TokenManager.getUserId();
    final username = await TokenManager.getUsername();
    if (userId != null) {
      await PointsService.addWorkoutPoints(
        userId: userId,
        username: username ?? '',
        workoutId: workoutId,
      );
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
