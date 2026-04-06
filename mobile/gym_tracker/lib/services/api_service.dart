import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/token_manager.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  // ── Headers ────────────────────────────────────────────────────────────────

  static Future<Map<String, String>> _authHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> get _publicHeaders =>
      {'Content-Type': 'application/json'};

  // ── Core HTTP methods ──────────────────────────────────────────────────────

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    final headers =
        requiresAuth ? await _authHeaders() : _publicHeaders;
    final response = await http
        .post(
          Uri.parse('${AppConstants.baseUrl}$endpoint'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    return _handleResponse(response);
  }

  static Future<dynamic> get(String endpoint) async {
    final headers = await _authHeaders();
    final response = await http
        .get(Uri.parse('${AppConstants.baseUrl}$endpoint'), headers: headers)
        .timeout(_timeout);

    return _handleResponse(response);
  }

  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _authHeaders();
    final response = await http
        .put(
          Uri.parse('${AppConstants.baseUrl}$endpoint'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    return _handleResponse(response);
  }

  static Future<void> delete(String endpoint) async {
    final headers = await _authHeaders();
    final response = await http
        .delete(Uri.parse('${AppConstants.baseUrl}$endpoint'), headers: headers)
        .timeout(_timeout);

    if (response.statusCode != 204 && response.statusCode != 200) {
      _throwFromResponse(response);
    }
  }

  // ── Response handling ──────────────────────────────────────────────────────

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    _throwFromResponse(response);
  }

  static Never _throwFromResponse(http.Response response) {
    String message = 'Request failed';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message'] as String? ?? body['error'] as String? ?? message;
    } catch (_) {}
    throw ApiException(response.statusCode, message);
  }
}
