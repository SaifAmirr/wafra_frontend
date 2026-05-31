import 'package:dio/dio.dart';
import 'package:wafra_frontend/core/constants/api_constants.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const String baseUrl = ApiConstants.baseUrl;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      extra: {'withCredentials': true},
    ),
  );
}
