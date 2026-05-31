import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository _repository;
  const VerifyEmailUseCase(this._repository);

  Future<User> execute(int userId, String code) =>
      _repository.verifyEmail(userId, code);
}
