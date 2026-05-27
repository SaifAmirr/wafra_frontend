import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String username, String email, String password);
  Future<void> chooseRole(String role);
  Future<void> completeRestaurantProfile({
    required String restaurantName,
    required String cuisineType,
    required String fullAddress,
    required String phone,
    required String businessLicenseNumber,
  });
}
