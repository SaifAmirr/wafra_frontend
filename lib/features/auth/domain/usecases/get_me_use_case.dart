import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetMeUseCase {
  final AuthRepository _repository;
  const GetMeUseCase(this._repository);

  Future<User> execute() => _repository.getMe();
}
