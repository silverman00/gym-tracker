import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/token_manager.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    final loggedIn = await TokenManager.isLoggedIn();
    if (loggedIn) {
      final userId = await TokenManager.getUserId();
      final username = await TokenManager.getUsername();
      final email = await TokenManager.getEmail();
      final fullName = await TokenManager.getFullName();
      if (userId != null && username != null && email != null) {
        _currentUser = User(
          id: userId,
          username: username,
          email: email,
          fullName: fullName,
        );
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    _setLoading(true);
    try {
      final response =
          await AuthService.login(usernameOrEmail: usernameOrEmail, password: password);
      final userId = response['userId'] as int;
      _currentUser = await AuthService.getProfile(userId);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('ApiException(', '').split('):').last.trim();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    _setLoading(true);
    try {
      await AuthService.signUp(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('ApiException(', '').split('):').last.trim();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? fullName,
    int? age,
    double? weight,
    double? height,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    try {
      _currentUser = await AuthService.updateProfile(
        userId: _currentUser!.id,
        fullName: fullName,
        age: age,
        weight: weight,
        height: height,
      );
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
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
