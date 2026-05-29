import 'package:wafra_frontend/core/network/api_service.dart';

class AuthRepository {
  AuthRepository._();
  static final instance = AuthRepository._();

  String? get token => ApiService.instance.token;

  Future<Map<String, dynamic>> login(String email, String password) =>
      ApiService.instance.login(email, password);

  Future<Map<String, dynamic>> register(String email, String password, String username) =>
      ApiService.instance.register(email, password, username);

  Future<void> sendVerificationCode(int userId) =>
      ApiService.instance.sendVerificationCode(userId);

  Future<Map<String, dynamic>> verifyEmail(int userId, String code) =>
      ApiService.instance.verifyEmail(userId, code);

  Future<Map<String, dynamic>> forgotPassword(String email) =>
      ApiService.instance.forgotPassword(email);

  Future<void> resetPassword(int userId, String code, String newPassword) =>
      ApiService.instance.resetPassword(userId, code, newPassword);

  Future<Map<String, dynamic>> getMe() => ApiService.instance.getMe();

  Future<void> chooseRole(String role) =>
      ApiService.instance.chooseRole(role);

  Future<void> completeRestaurantProfile({
    required String restaurantName,
    required String cuisineType,
    required String fullAddress,
    required String phone,
    required String businessLicenseNumber,
  }) =>
      ApiService.instance.completeRestaurantProfile(
        restaurantName: restaurantName,
        cuisineType: cuisineType,
        fullAddress: fullAddress,
        phone: phone,
        businessLicenseNumber: businessLicenseNumber,
      );

  Future<void> completeFoodBankProfile({
    required String organizationName,
    required String registrationNumber,
    required String phone,
    required String location,
  }) =>
      ApiService.instance.completeFoodBankProfile(
        organizationName: organizationName,
        registrationNumber: registrationNumber,
        phone: phone,
        location: location,
      );

  Future<void> completeIndividualProfile({
    required String firstName,
    required String lastName,
    required String phone,
    String? birthdate,
  }) =>
      ApiService.instance.completeIndividualProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        birthdate: birthdate,
      );
}
