import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<User> login(String email, String password) =>
      _dataSource.login(email, password);

  @override
  Future<User> register(String username, String email, String password) =>
      _dataSource.register(username, email, password);

  @override
  Future<void> sendVerificationCode(int userId) =>
      _dataSource.sendVerificationCode(userId);

  @override
  Future<User> verifyEmail(int userId, String code) =>
      _dataSource.verifyEmail(userId, code);

  @override
  Future<User> forgotPassword(String email) =>
      _dataSource.forgotPassword(email);

  @override
  Future<void> resetPassword(int userId, String code, String newPassword) =>
      _dataSource.resetPassword(userId, code, newPassword);

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

  @override
  Future<void> completeIndividualProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? birthdate,
  }) =>
      _dataSource.completeIndividualProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        birthdate: birthdate,
      );

  @override
  Future<void> completeFoodBankProfile({
    required String organizationName,
    String? registrationNumber,
    String? phone,
    String? location,
  }) =>
      _dataSource.completeFoodBankProfile(
        organizationName: organizationName,
        registrationNumber: registrationNumber,
        phone: phone,
        location: location,
      );

  @override
  Future<User> getMe() => _dataSource.getMe();
}
