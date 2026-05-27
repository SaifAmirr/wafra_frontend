import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // localhost:5000 for Flutter Web / physical machine.
  // Change to http://10.0.2.2:5000 when running on an Android emulator.
  static const String baseUrl = 'http://localhost:5000';

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
