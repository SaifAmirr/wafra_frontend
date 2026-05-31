import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;
  const ResetPasswordUseCase(this._repository);

  Future<void> execute(int userId, String code, String newPassword) =>
      _repository.resetPassword(userId, code, newPassword);
}
