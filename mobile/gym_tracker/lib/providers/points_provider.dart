import 'package:flutter/foundation.dart';
import '../models/points.dart';
import '../services/points_service.dart';

class PointsProvider extends ChangeNotifier {
  UserPoints? _userPoints;
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = false;
  String? _error;

  UserPoints? get userPoints => _userPoints;
  List<LeaderboardEntry> get leaderboard => List.unmodifiable(_leaderboard);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserPoints(int userId) async {
    _setLoading(true);
    try {
      _userPoints = await PointsService.getUserPoints(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadLeaderboard() async {
    _setLoading(true);
    try {
      _leaderboard = await PointsService.getLeaderboard();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh(int userId) async {
    await Future.wait([
      loadUserPoints(userId),
      loadLeaderboard(),
    ]);
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
