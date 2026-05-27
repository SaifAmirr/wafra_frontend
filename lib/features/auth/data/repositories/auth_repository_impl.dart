import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<User> login(String email, String password) async {
    final json = await _dataSource.login(email, password);
    return User.fromJson(json);
  }

  @override
  Future<User> register(String username, String email, String password) async {
    final json = await _dataSource.register(username, email, password);
    return User.fromJson(json);
  }

  @override
  Future<void> chooseRole(String role) => _dataSource.chooseRole(role);

  @override
  Future<void> completeRestaurantProfile({
    required String restaurantName,
    required String cuisineType,
    required String fullAddress,
    required String phone,
    required String businessLicenseNumber,
  }) =>
      _dataSource.completeRestaurantProfile(
        restaurantName: restaurantName,
        cuisineType: cuisineType,
        fullAddress: fullAddress,
        phone: phone,
        businessLicenseNumber: businessLicenseNumber,
      );
}
