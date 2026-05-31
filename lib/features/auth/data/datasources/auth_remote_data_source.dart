import 'package:wafra_frontend/core/errors/app_failure.dart';
import 'package:wafra_frontend/core/network/api_service.dart';
import '../../domain/entities/user.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource();

  Future<User> login(String email, String password) async {
    try {
      final res = await ApiService.instance.login(email, password);
      // When email is not verified the server returns user data at the top
      // level (no 'user' key). When verified it is nested under 'user'.
      final userJson = res['user'] as Map<String, dynamic>? ?? res;
      return User.fromJson(userJson);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
    }
  }

  Future<User> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final res = await ApiService.instance.register(email, password, username);
      return User.fromJson(res['user'] as Map<String, dynamic>? ?? {});
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
    }
  }

  Future<void> sendVerificationCode(int userId) async {
    try {
      await ApiService.instance.sendVerificationCode(userId);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
    }
  }

  Future<User> verifyEmail(int userId, String code) async {
    try {
      final res = await ApiService.instance.verifyEmail(userId, code);
      return User.fromJson(res['user'] as Map<String, dynamic>? ?? res);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
    }
  }

  Future<User> forgotPassword(String email) async {
    try {
      final res = await ApiService.instance.forgotPassword(email);
      return User.fromJson(res);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
    }
  }

  Future<void> resetPassword(
      int userId, String code, String newPassword) async {
    try {
      await ApiService.instance.resetPassword(userId, code, newPassword);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
    }
  }

  Future<void> chooseRole(String role) async {
    try {
      await ApiService.instance.chooseRole(role);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
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
      await ApiService.instance.completeRestaurantProfile(
        restaurantName: restaurantName,
        cuisineType: cuisineType,
        fullAddress: fullAddress,
        phone: phone,
        businessLicenseNumber: businessLicenseNumber,
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
    }
  }

  Future<void> completeIndividualProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? birthdate,
  }) async {
    try {
      await ApiService.instance.completeIndividualProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        birthdate: birthdate,
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
    }
  }

  Future<void> completeFoodBankProfile({
    required String organizationName,
    String? registrationNumber,
    String? phone,
    String? location,
  }) async {
    try {
      await ApiService.instance.completeFoodBankProfile(
        organizationName: organizationName,
        registrationNumber: registrationNumber,
        phone: phone,
        location: location,
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
    }
  }

  Future<User> getMe() async {
    try {
      final res = await ApiService.instance.getMe();
      return User.fromJson(res['user'] as Map<String, dynamic>? ?? {});
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
    }
  }
}
