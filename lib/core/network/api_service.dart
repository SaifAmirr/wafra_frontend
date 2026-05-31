import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wafra_frontend/core/constants/api_constants.dart';
import 'package:wafra_frontend/core/errors/app_failure.dart';
import 'http_client.dart';

const _kTokenKey = 'auth_token';

class ApiService {
  ApiService._() : _client = buildHttpClient();
  static final ApiService instance = ApiService._();

  final http.Client _client;

  static const String _base = ApiConstants.baseUrl;

  String? _token;
  String? get token => _token;
  bool get isLoggedIn => _token != null;

  /// Call once at app startup (before runApp) to restore a persisted token.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    instance._token = prefs.getString(_kTokenKey);
  }

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Map<String, String> get _multipartHeaders => {
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Extracts a refreshed JWT from the JSON body whenever the server provides one.
  void _updateToken(Map<String, dynamic> body) {
    final t = body['token'] as String?;
    if (t != null) {
      _token = t;
      SharedPreferences.getInstance().then((prefs) => prefs.setString(_kTokenKey, t));
    }
  }

  Future<Map<String, dynamic>> _handle(http.Response res) async {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw AppFailure(
        body['message'] as String? ??
        body['error'] as String? ??
        'Request failed (${res.statusCode})');
  }

  // ─── Auth ───────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register(
      String email, String password, String username) async {
    final res = await _client.post(
      Uri.parse('$_base/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'email': email, 'password': password, 'username': username}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _client.post(
      Uri.parse('$_base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = await _handle(res);
    _updateToken(body); // no-op if email not verified (no token in response)
    return body;
  }

  Future<void> logout() async {
    await _client.post(Uri.parse('$_base/auth/logout'),
        headers: _authHeaders);
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
  }

  Future<void> sendVerificationCode(int userId) async {
    final res = await _client.post(
      Uri.parse('$_base/auth/send-verification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );
    await _handle(res);
  }

  Future<Map<String, dynamic>> verifyEmail(int userId, String code) async {
    final res = await _client.post(
      Uri.parse('$_base/auth/verify-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'code': code}),
    );
    final body = await _handle(res);
    _updateToken(body);
    return body;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await _client.post(
      Uri.parse('$_base/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return _handle(res);
  }

  Future<void> resetPassword(int userId, String code, String newPassword) async {
    final res = await _client.post(
      Uri.parse('$_base/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'code': code, 'new_password': newPassword}),
    );
    await _handle(res);
  }

  Future<Map<String, dynamic>> chooseRole(String role) async {
    final res = await _client.patch(
      Uri.parse('$_base/auth/choose-role'),
      headers: _authHeaders,
      body: jsonEncode({'role': role}),
    );
    final body = await _handle(res);
    _updateToken(body);
    return body;
  }

  Future<Map<String, dynamic>> completeIndividualProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? birthdate,
  }) async {
    final res = await _client.patch(
      Uri.parse('$_base/auth/complete-profile'),
      headers: _authHeaders,
      body: jsonEncode(<String, dynamic>{
        if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
        if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (birthdate != null) 'birthdate': birthdate,
      }),
    );
    final body = await _handle(res);
    _updateToken(body);
    return body;
  }

  Future<Map<String, dynamic>> completeFoodBankProfile({
    required String organizationName,
    String? registrationNumber,
    String? phone,
    String? location,
  }) async {
    final res = await _client.patch(
      Uri.parse('$_base/auth/complete-profile'),
      headers: _authHeaders,
      body: jsonEncode(<String, dynamic>{
        'organization_name': organizationName,
        if (registrationNumber != null && registrationNumber.isNotEmpty)
          'registration_number': registrationNumber,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (location != null && location.isNotEmpty) 'location': location,
      }),
    );
    final body = await _handle(res);
    _updateToken(body);
    return body;
  }

  Future<Map<String, dynamic>> completeRestaurantProfile({
    required String restaurantName,
    String? cuisineType,
    String? fullAddress,
    String? phone,
    String? businessLicenseNumber,
  }) async {
    final res = await _client.patch(
      Uri.parse('$_base/auth/complete-profile'),
      headers: _authHeaders,
      body: jsonEncode(<String, dynamic>{
        'restaurant_name': restaurantName,
        if (cuisineType != null && cuisineType.isNotEmpty)
          'cuisine_type': cuisineType,
        if (fullAddress != null && fullAddress.isNotEmpty)
          'full_address': fullAddress,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (businessLicenseNumber != null &&
            businessLicenseNumber.isNotEmpty)
          'business_license_number': businessLicenseNumber,
      }),
    );
    final body = await _handle(res);
    _updateToken(body);
    return body;
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _client.get(
      Uri.parse('$_base/users/me'),
      headers: _authHeaders,
    );
    return _handle(res);
  }

  // ─── Listings ───────────────────────────────────────────────────────────────

  Future<List<dynamic>> getListings({
    String? search,
    String? category,
    String? status,
  }) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category != 'All') params['category'] = category;
    if (status != null) params['status'] = status;
    final uri = Uri.parse('$_base/listings')
        .replace(queryParameters: params.isEmpty ? null : params);
    final res = await _client.get(uri, headers: _authHeaders);
    final body = await _handle(res);
    return (body['listings'] as List?) ?? [];
  }

  Future<List<dynamic>> getMyListings() async {
    final res = await _client.get(
      Uri.parse('$_base/listings/my'),
      headers: _authHeaders,
    );
    final body = await _handle(res);
    return (body['listings'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> updateListing(
    int id, {
    String? foodName,
    String? category,
    int? quantity,
    String? pickupTime,
    String? location,
    List<String>? dietaryTags,
  }) async {
    final res = await _client.put(
      Uri.parse('$_base/listings/$id'),
      headers: _authHeaders,
      body: jsonEncode(<String, dynamic>{
        if (foodName != null) 'food_name': foodName,
        if (category != null) 'category': category,
        if (quantity != null) 'quantity': quantity,
        if (pickupTime != null) 'pickup_time': pickupTime,
        if (location != null) 'location': location,
        if (dietaryTags != null) 'dietary_tags': dietaryTags,
      }),
    );
    return _handle(res);
  }

  Future<void> deleteListing(int id) async {
    final res = await _client.delete(
      Uri.parse('$_base/listings/$id'),
      headers: _authHeaders,
    );
    await _handle(res);
  }

  Future<Map<String, dynamic>> createListing({
    required String foodName,
    required String category,
    required int quantity,
    required String pickupTime,
    required String location,
    String? photoPath,
    List<String>? dietaryTags,
  }) async {
    final uri = Uri.parse('$_base/listings');

    if (photoPath != null) {
      final req = http.MultipartRequest('POST', uri)
        ..headers.addAll(_multipartHeaders)
        ..fields['food_name'] = foodName
        ..fields['category'] = category
        ..fields['quantity'] = quantity.toString()
        ..fields['pickup_time'] = pickupTime
        ..fields['location'] = location;
      if (dietaryTags != null && dietaryTags.isNotEmpty) {
        req.fields['dietary_tags'] = jsonEncode(dietaryTags);
      }
      final ext = photoPath.split('.').last.toLowerCase();
      final subtype = ext == 'png' ? 'png' : ext == 'webp' ? 'webp' : 'jpeg';
      req.files.add(await http.MultipartFile.fromPath(
        'photo',
        photoPath,
        contentType: MediaType('image', subtype),
      ));
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);
      return _handle(res);
    }

    final res = await _client.post(
      uri,
      headers: _authHeaders,
      body: jsonEncode(<String, dynamic>{
        'food_name': foodName,
        'category': category,
        'quantity': quantity,
        'pickup_time': pickupTime,
        'location': location,
        if (dietaryTags != null && dietaryTags.isNotEmpty)
          'dietary_tags': dietaryTags,
      }),
    );
    return _handle(res);
  }

  // ─── Reservations ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createReservation(
      int listingId, int requestedQuantity) async {
    final res = await _client.post(
      Uri.parse('$_base/reservations'),
      headers: _authHeaders,
      body: jsonEncode({
        'listing_id': listingId,
        'requested_quantity': requestedQuantity,
      }),
    );
    return _handle(res);
  }

  Future<List<dynamic>> getMyReservations() async {
    final res = await _client.get(
      Uri.parse('$_base/reservations/my'),
      headers: _authHeaders,
    );
    final body = await _handle(res);
    return (body['reservations'] as List?) ?? [];
  }

  Future<List<dynamic>> getRestaurantReservations() async {
    final res = await _client.get(
      Uri.parse('$_base/reservations/restaurant'),
      headers: _authHeaders,
    );
    final body = await _handle(res);
    return (body['reservations'] as List?) ?? [];
  }

  Future<void> cancelReservation(int id) async {
    final res = await _client.patch(
      Uri.parse('$_base/reservations/$id/cancel'),
      headers: _authHeaders,
    );
    await _handle(res);
  }

  Future<void> acceptReservation(int id) async {
    final res = await _client.patch(
      Uri.parse('$_base/reservations/$id/accept'),
      headers: _authHeaders,
    );
    await _handle(res);
  }

  Future<void> declineReservation(int id) async {
    final res = await _client.patch(
      Uri.parse('$_base/reservations/$id/decline'),
      headers: _authHeaders,
    );
    await _handle(res);
  }

  // ─── Notifications ──────────────────────────────────────────────────────────

  Future<List<dynamic>> getNotifications() async {
    final res = await _client.get(
      Uri.parse('$_base/notifications'),
      headers: _authHeaders,
    );
    final body = await _handle(res);
    return (body['notifications'] as List?) ?? [];
  }

  Future<void> markAllNotificationsRead() async {
    final res = await _client.patch(
      Uri.parse('$_base/notifications/read'),
      headers: _authHeaders,
    );
    await _handle(res);
  }

  // ─── Pickups ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> generatePickup(int reservationId) async {
    final res = await _client.post(
      Uri.parse('$_base/pickups/generate'),
      headers: _authHeaders,
      body: jsonEncode({'reservation_id': reservationId}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> confirmPickup(
      String pickupCode, {int? reservationId}) async {
    final res = await _client.post(
      Uri.parse('$_base/pickups/confirm'),
      headers: _authHeaders,
      body: jsonEncode(<String, dynamic>{
        'pickup_code': pickupCode,
        if (reservationId != null) 'reservation_id': reservationId,
      }),
    );
    return _handle(res);
  }

  // ─── Admin ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAdminStats() async {
    final res = await _client.get(
      Uri.parse('$_base/admin/stats'),
      headers: _authHeaders,
    );
    return _handle(res);
  }

  Future<List<dynamic>> getAdminUsers() async {
    final res = await _client.get(
      Uri.parse('$_base/admin/users'),
      headers: _authHeaders,
    );
    final body = await _handle(res);
    return body['users'] as List<dynamic>;
  }

  Future<List<dynamic>> getAdminListings() async {
    final res = await _client.get(
      Uri.parse('$_base/admin/listings'),
      headers: _authHeaders,
    );
    final body = await _handle(res);
    return body['listings'] as List<dynamic>;
  }

  Future<void> adminApproveUser(int userId) async {
    final res = await _client.patch(
      Uri.parse('$_base/admin/users/$userId/approve'),
      headers: _authHeaders,
    );
    _handle(res);
  }

  Future<void> adminRejectUser(int userId) async {
    final res = await _client.patch(
      Uri.parse('$_base/admin/users/$userId/reject'),
      headers: _authHeaders,
    );
    _handle(res);
  }

  Future<void> adminDeleteListing(int listingId) async {
    final res = await _client.delete(
      Uri.parse('$_base/admin/listings/$listingId'),
      headers: _authHeaders,
    );
    _handle(res);
  }

  // ─── Support Tickets ────────────────────────────────────────────────────────

  Future<void> submitSupportTicket({
    required String subject,
    required String message,
  }) async {
    final res = await _client.post(
      Uri.parse('$_base/support/tickets'),
      headers: _authHeaders,
      body: jsonEncode({'subject': subject, 'message': message}),
    );
    await _handle(res);
  }

  Future<List<dynamic>> getAdminSupportTickets() async {
    final res = await _client.get(
      Uri.parse('$_base/admin/support/tickets'),
      headers: _authHeaders,
    );
    final body = await _handle(res);
    return (body['tickets'] as List?) ?? [];
  }

  Future<void> resolveAdminSupportTicket(int ticketId) async {
    final res = await _client.patch(
      Uri.parse('$_base/admin/support/tickets/$ticketId/resolve'),
      headers: _authHeaders,
    );
    await _handle(res);
  }
}

