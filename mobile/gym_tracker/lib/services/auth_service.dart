import '../models/user.dart';
import '../utils/constants.dart';
import '../utils/token_manager.dart';
import 'api_service.dart';

class AuthService {
  static Future<User> signUp({
    required String username,
    required String email,
    required String password,
    String? fullName,
    int? age,
    double? weight,
    double? height,
  }) async {
    final data = await ApiService.post(
      AppConstants.signUpEndpoint,
      {
        'username': username,
        'email': email,
        'password': password,
        if (fullName != null) 'fullName': fullName,
        if (age != null) 'age': age,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
      },
    );
    return User.fromJson(data as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final data = await ApiService.post(
      AppConstants.loginEndpoint,
      {'usernameOrEmail': usernameOrEmail, 'password': password},
    );

    final response = data as Map<String, dynamic>;

    // Persist token and user info
    await TokenManager.saveToken(response['accessToken'] as String);
    await TokenManager.saveUserInfo(
      userId:   response['userId'] as int,
      username: response['username'] as String,
      email:    response['email'] as String,
      fullName: response['fullName'] as String?,
    );

    return response;
  }

  static Future<void> logout() => TokenManager.clearAll();

  static Future<User> getProfile(int userId) async {
    final data = await ApiService.get('${AppConstants.userProfileBase}/$userId');
    return User.fromJson(data as Map<String, dynamic>);
  }

  static Future<User> updateProfile({
    required int userId,
    String? fullName,
    int? age,
    double? weight,
    double? height,
  }) async {
    final data = await ApiService.put(
      '${AppConstants.userProfileBase}/$userId',
      {
        if (fullName != null) 'fullName': fullName,
        if (age != null) 'age': age,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
      },
    );
    return User.fromJson(data as Map<String, dynamic>);
  }
}
