import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/constants.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static String? _debugOtp;

  static String? get debugOtp => _debugOtp;

  static String normalizeIndianPhone(String phoneInput) {
    final digits = phoneInput.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+91') && digits.length == 13) {
      return digits;
    }
    if (digits.length == 10) {
      return '+91$digits';
    }
    return phoneInput;
  }

  static Future<String> requestOtp(String phone) async {
    final normalized = normalizeIndianPhone(phone);
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/auth/request-otp');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': normalized}),
    );

    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? (decoded['detail']?.toString() ?? 'Failed to request OTP')
          : 'Failed to request OTP';
      throw Exception(message);
    }

    if (decoded is Map<String, dynamic>) {
      final code = decoded['debug_otp']?.toString();
      _debugOtp = (code != null && code.isNotEmpty) ? code : null;
    } else {
      _debugOtp = null;
    }

    return normalized;
  }

  static Future<String> verifyOtp(String phone, String otp) async {
    final normalized = normalizeIndianPhone(phone);
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/auth/verify-otp');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': normalized, 'otp': otp}),
    );

    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? (decoded['detail']?.toString() ?? 'OTP verification failed')
          : 'OTP verification failed';
      throw Exception(message);
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid verify response');
    }

    final token = (decoded['access_token'] ?? '').toString();
    if (token.isEmpty) {
      throw Exception('Missing access token');
    }

    _debugOtp = null;
    await setToken(token);
    return token;
  }

  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
