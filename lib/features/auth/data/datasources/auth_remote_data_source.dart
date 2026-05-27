import 'package:dio/dio.dart';
import 'package:wafra_frontend/core/errors/app_failure.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  const AuthRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return res.data['user'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AppFailure(_extractError(e));
    }
  }

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
      throw AppFailure(_extractError(e));
    }
  }

  Future<void> chooseRole(String role) async {
    try {
      await _dio.patch('/auth/choose-role', data: {'role': role});
    } on DioException catch (e) {
      throw AppFailure(_extractError(e));
    }
  }

  Future<void> completeRestaurantProfile({
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
      throw AppFailure(_extractError(e));
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
