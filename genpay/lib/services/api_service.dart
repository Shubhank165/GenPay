import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/constants.dart';
import 'auth_service.dart';
import 'local_storage_service.dart';
import 'navigation_service.dart';

class ApiService {
  static Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${AppConfig.backendBaseUrl}$path').replace(queryParameters: query);
  }

  static Future<Map<String, String>> _headers({String? token, bool withAuth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (withAuth) {
      final bearer = token ?? await AuthService.getToken();
      if (bearer != null && bearer.isNotEmpty) {
        headers['Authorization'] = 'Bearer $bearer';
      }
    }
    return headers;
  }

  static dynamic _decode(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }
    return jsonDecode(response.body);
  }

  static Future<dynamic> _handleResponse(http.Response response) async {
    final decoded = _decode(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final guest = await LocalStorageService.isGuest();
    if (response.statusCode == 401 && !AppConfig.guestModeEnabled && !guest) {
      await AuthService.clearToken();
      await LocalStorageService.setLoggedIn(false);
      NavigationService.redirectToPhoneLogin();
    }

    final message = decoded is Map<String, dynamic>
        ? (decoded['detail']?.toString() ?? decoded['reason']?.toString() ?? 'Request failed')
        : 'Request failed (${response.statusCode})';
    throw Exception(message);
  }

  static Future<void> sendOtp(String phone) async {
    final response = await http.post(
      _uri('/auth/request-otp'),
      headers: await _headers(withAuth: false),
      body: jsonEncode({'phone': phone}),
    );
    await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final response = await http.post(
      _uri('/auth/verify-otp'),
      headers: await _headers(withAuth: false),
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );
    return Map<String, dynamic>.from(await _handleResponse(response) as Map);
  }

  static Future<Map<String, dynamic>> guestLogin() async {
    final response = await http.post(
      _uri('/auth/guest-login'),
      headers: await _headers(withAuth: false),
    );
    return Map<String, dynamic>.from(await _handleResponse(response) as Map);
  }

  static Future<Map<String, dynamic>> getProfile([String? token]) async {
    final response = await http.get(_uri('/auth/me'), headers: await _headers(token: token));
    return Map<String, dynamic>.from(await _handleResponse(response) as Map);
  }

  static Future<List<dynamic>> listTransactions(
    String token, {
    String? search,
    String? type,
    String? status,
  }) async {
    final query = <String, String>{};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (type != null && type.isNotEmpty) query['type'] = type;
    if (status != null && status.isNotEmpty) query['status'] = status;

    final response = await http.get(
      _uri('/api/transactions/', query.isEmpty ? null : query),
      headers: await _headers(token: token),
    );
    final decoded = await _handleResponse(response) as Map<String, dynamic>;
    return List<dynamic>.from(decoded['transactions'] ?? []);
  }

  static Future<Map<String, dynamic>> createTransaction(
    String token, {
    required String type,
    required double amount,
    required String upiPin,
    String? recipientName,
    String? recipientIdentifier,
    String? description,
  }) async {
    final response = await http.post(
      _uri('/api/transactions/'),
      headers: await _headers(token: token),
      body: jsonEncode({
        'type': type,
        'amount': amount,
        'upi_pin': upiPin,
        'recipient_name': recipientName,
        'recipient_identifier': recipientIdentifier,
        'description': description,
      }),
    );
    return Map<String, dynamic>.from(await _handleResponse(response) as Map);
  }

  static Future<List<dynamic>> listBankAccounts(String token) async {
    final response = await http.get(_uri('/api/bank/accounts'), headers: await _headers(token: token));
    return List<dynamic>.from(await _handleResponse(response) as List);
  }

  static Future<List<dynamic>> listBills(
    String token, {
    String? category,
    bool unpaidOnly = false,
  }) async {
    final query = <String, String>{'unpaid_only': unpaidOnly.toString()};
    if (category != null && category.isNotEmpty) query['category'] = category;

    final response = await http.get(_uri('/api/services/bills', query), headers: await _headers(token: token));
    return List<dynamic>.from(await _handleResponse(response) as List);
  }

  static Future<Map<String, dynamic>> payBill(String token, String billId) async {
    final response = await http.post(
      _uri('/api/services/bills/pay'),
      headers: await _headers(token: token),
      body: jsonEncode({'bill_id': billId}),
    );
    return Map<String, dynamic>.from(await _handleResponse(response) as Map);
  }

  static Future<List<dynamic>> listOffers({String? category}) async {
    final query = <String, String>{};
    if (category != null && category.isNotEmpty) query['category'] = category;

    final response = await http.get(
      _uri('/api/services/offers', query.isEmpty ? null : query),
      headers: await _headers(),
    );
    return List<dynamic>.from(await _handleResponse(response) as List);
  }

  static Future<List<dynamic>> listRechargePlans({String? operator, double? maxPrice}) async {
    final query = <String, String>{};
    if (operator != null && operator.isNotEmpty) query['operator'] = operator;
    if (maxPrice != null) query['max_price'] = maxPrice.toString();

    final response = await http.get(
      _uri('/api/services/recharge/plans', query.isEmpty ? null : query),
      headers: await _headers(),
    );
    return List<dynamic>.from(await _handleResponse(response) as List);
  }

  static Future<Map<String, dynamic>> queryAgent(
    String userId,
    String message, {
    bool userConfirmation = false,
    String? upiPin,
    String paymentMode = 'online',
    String? paymentOtpToken,
  }) async {
    final response = await http.post(
      _uri('/api/agent/query'),
      headers: await _headers(),
      body: jsonEncode({
        'user_id': userId,
        'message': message,
        'user_confirmation': userConfirmation,
        if (upiPin != null) 'upi_pin': upiPin,
        'payment_mode': paymentMode,
        if (paymentOtpToken != null) 'payment_otp_token': paymentOtpToken,
      }),
    );
    return Map<String, dynamic>.from(await _handleResponse(response) as Map);
  }

  static Future<Map<String, dynamic>> requestOfflinePaymentOtp(String phone) async {
    final response = await http.post(
      _uri('/api/transactions/offline/request-otp'),
      headers: await _headers(),
      body: jsonEncode({'phone': phone}),
    );
    return Map<String, dynamic>.from(await _handleResponse(response) as Map);
  }

  static Future<Map<String, dynamic>> verifyOfflinePaymentOtp(String phone, String otp) async {
    final response = await http.post(
      _uri('/api/transactions/offline/verify-otp'),
      headers: await _headers(),
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );
    return Map<String, dynamic>.from(await _handleResponse(response) as Map);
  }

  static Future<String> transcribePromptAudio(String filePath, {String language = 'en'}) async {
    final request = http.MultipartRequest('POST', _uri('/api/agent/transcribe'));
    final bearer = await AuthService.getToken();
    if (bearer != null && bearer.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $bearer';
    }
    request.fields['language'] = language;
    request.files.add(await http.MultipartFile.fromPath('audio', filePath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final decoded = await _handleResponse(response);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid transcription response');
    }

    final text = (decoded['text'] ?? '').toString().trim();
    if (text.isEmpty) {
      throw Exception('No speech detected');
    }
    return text;
  }

  static Future<List<dynamic>> searchFlights({
    required String origin,
    required String destination,
    required String date,
    double? maxPrice,
    int? maxStops,
    String cabinClass = 'economy',
    int passengers = 1,
  }) async {
    final response = await http.post(
      _uri('/api/travel/flights/search'),
      headers: await _headers(),
      body: jsonEncode({
        'origin': origin,
        'destination': destination,
        'date': date,
        'max_price': maxPrice,
        'max_stops': maxStops,
        'cabin_class': cabinClass,
        'passengers': passengers,
      }),
    );
    final decoded = Map<String, dynamic>.from(await _handleResponse(response) as Map);
    return List<dynamic>.from(decoded['flights'] ?? []);
  }

  static Future<List<dynamic>> searchBuses({
    required String origin,
    required String destination,
    required String date,
    double? maxPrice,
    String? busType,
  }) async {
    final response = await http.post(
      _uri('/api/travel/buses/search'),
      headers: await _headers(),
      body: jsonEncode({
        'origin': origin,
        'destination': destination,
        'date': date,
        'max_price': maxPrice,
        'bus_type': busType,
      }),
    );
    return List<dynamic>.from(await _handleResponse(response) as List);
  }
}
