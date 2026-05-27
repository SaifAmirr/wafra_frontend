import 'package:wafra_frontend/core/errors/app_failure.dart';
import 'package:wafra_frontend/core/network/api_service.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await ApiService.instance.login(email, password);
      return res['user'] as Map<String, dynamic>? ?? {};
    } on ApiException catch (e) {
      throw AppFailure(e.message);
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final res = await ApiService.instance.register(email, password, username);
      return res['user'] as Map<String, dynamic>? ?? {};
    } on ApiException catch (e) {
      throw AppFailure(e.message);
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
    }
  }

  Future<void> chooseRole(String role) async {
    try {
      await ApiService.instance.chooseRole(role);
    } on ApiException catch (e) {
      throw AppFailure(e.message);
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
    } on ApiException catch (e) {
      throw AppFailure(e.message);
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
    } on ApiException catch (e) {
      throw AppFailure(e.message);
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
    } on ApiException catch (e) {
      throw AppFailure(e.message);
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final res = await ApiService.instance.getMe();
      return res['user'] as Map<String, dynamic>? ?? {};
    } on ApiException catch (e) {
      throw AppFailure(e.message);
    } catch (_) {
      throw const AppFailure('Could not connect to the server.');
    }
  }
}
