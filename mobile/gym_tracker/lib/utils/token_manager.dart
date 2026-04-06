import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey    = 'access_token';
  static const _userIdKey   = 'user_id';
  static const _usernameKey = 'username';
  static const _emailKey    = 'email';
  static const _fullNameKey = 'full_name';

  // ── Write ──────────────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<void> saveUserInfo({
    required int userId,
    required String username,
    required String email,
    String? fullName,
  }) async {
    await _storage.write(key: _userIdKey,   value: userId.toString());
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _emailKey,    value: email);
    if (fullName != null) {
      await _storage.write(key: _fullNameKey, value: fullName);
    }
  }

  // ── Read ───────────────────────────────────────────────────────────────────
  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<int?> getUserId() async {
    final val = await _storage.read(key: _userIdKey);
    return val != null ? int.tryParse(val) : null;
  }

  static Future<String?> getUsername() => _storage.read(key: _usernameKey);

  static Future<String?> getEmail() => _storage.read(key: _emailKey);

  static Future<String?> getFullName() => _storage.read(key: _fullNameKey);

  // ── Clear ──────────────────────────────────────────────────────────────────
  static Future<void> clearAll() => _storage.deleteAll();

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
