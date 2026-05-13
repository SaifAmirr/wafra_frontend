import 'package:dio/dio.dart';
import 'package:wafra_frontend/services/api_client.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final Dio _dio = ApiClient.instance.dio;

  /// Returns the user object from the server on success.
  /// Throws [AuthException] with a human-readable message on failure.
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final res = await _dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      return res.data['user'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AuthException(_extractError(e));
    }
  }

  Future<void> chooseRole(String role) async {
    try {
      await _dio.patch('/auth/choose-role', data: {'role': role});
    } on DioException catch (e) {
      throw AuthException(_extractError(e));
    }
  }

  Future<void> completeProfileRestaurant({
    required String restaurantName,
    required String cuisineType,
    required String fullAddress,
    required String phone,
    required String businessLicenseNumber,
  }) async {
    try {
      await _dio.post('/auth/complete-profile', data: {
        'restaurant_name': restaurantName,
        'cuisine_type': cuisineType,
        'full_address': fullAddress,
        'phone': phone,
        'business_license_number': businessLicenseNumber,
      });
    } on DioException catch (e) {
      throw AuthException(_extractError(e));
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return res.data['user'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AuthException(_extractError(e));
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) return data['error'] as String;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Could not reach the server. Check your connection.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Could not connect to the server.';
    }
    return 'Something went wrong. Please try again.';
  }
}
