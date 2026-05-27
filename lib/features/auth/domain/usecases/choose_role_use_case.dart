import '../repositories/auth_repository.dart';

class ChooseRoleUseCase {
  final AuthRepository _repository;
  const ChooseRoleUseCase(this._repository);

  Future<void> execute(String role) => _repository.chooseRole(role);
}
