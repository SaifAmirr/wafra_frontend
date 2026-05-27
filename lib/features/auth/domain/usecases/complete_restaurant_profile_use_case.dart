import '../repositories/auth_repository.dart';

class CompleteRestaurantProfileUseCase {
  final AuthRepository _repository;
  const CompleteRestaurantProfileUseCase(this._repository);

  Future<void> execute({
    required String restaurantName,
    required String cuisineType,
    required String fullAddress,
    required String phone,
    required String businessLicenseNumber,
  }) =>
      _repository.completeRestaurantProfile(
        restaurantName: restaurantName,
        cuisineType: cuisineType,
        fullAddress: fullAddress,
        phone: phone,
        businessLicenseNumber: businessLicenseNumber,
      );
}
