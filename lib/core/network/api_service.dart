import 'dart:convert';
import 'package:http/http.dart' as http;
import 'http_client.dart';

class ApiService {
  ApiService._() : _client = buildHttpClient();
  static final ApiService instance = ApiService._();

  final http.Client _client;

  // Web: localhost (browser); Android emulator: 10.0.2.2 (host loopback)
  static final String _base =
      isWebPlatform ? 'http://localhost:5000' : 'http://10.0.2.2:5000';

  String? _token;
  String? get token => _token;
  bool get isLoggedIn => _token != null;

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Extracts a refreshed JWT from the JSON body whenever the server provides one.
  void _updateToken(Map<String, dynamic> body) {
    final t = body['token'] as String?;
    if (t != null) _token = t;
  }

  Future<Map<String, dynamic>> _handle(http.Response res) async {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw ApiException(
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
    final body = await _handle(res);
    _updateToken(body);
    return body;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _client.post(
      Uri.parse('$_base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = await _handle(res);
    _updateToken(body);
    return body;
  }

  Future<void> logout() async {
    await _client.post(Uri.parse('$_base/auth/logout'),
        headers: _authHeaders);
    _token = null;
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
    final res = await _client.post(
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
    final res = await _client.post(
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
    final res = await _client.post(
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

  Future<Map<String, dynamic>> createListing({
    required String foodName,
    required String category,
    required int quantity,
    required String pickupTime,
    required String location,
    String? photoUrl,
    List<String>? dietaryTags,
  }) async {
    final res = await _client.post(
      Uri.parse('$_base/listings'),
      headers: _authHeaders,
      body: jsonEncode(<String, dynamic>{
        'food_name': foodName,
        'category': category,
        'quantity': quantity,
        'pickup_time': pickupTime,
        'location': location,
        if (photoUrl != null) 'photo_url': photoUrl,
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

  // ─── Pickups ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> generatePickup(int reservationId) async {
    final res = await _client.post(
      Uri.parse('$_base/pickups/generate'),
      headers: _authHeaders,
      body: jsonEncode({'reservation_id': reservationId}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> confirmPickup(String code) async {
    final res = await _client.post(
      Uri.parse('$_base/pickups/confirm'),
      headers: _authHeaders,
      body: jsonEncode({'code': code}),
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
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
