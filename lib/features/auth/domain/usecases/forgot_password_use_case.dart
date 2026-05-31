import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _repository;
  const ForgotPasswordUseCase(this._repository);

  Future<User> execute(String email) => _repository.forgotPassword(email);
}
