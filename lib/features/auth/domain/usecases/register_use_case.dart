import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<User> execute(String username, String email, String password) =>
      _repository.register(username, email, password);
}
