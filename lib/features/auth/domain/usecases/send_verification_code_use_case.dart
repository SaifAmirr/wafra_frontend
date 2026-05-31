import '../repositories/auth_repository.dart';

class SendVerificationCodeUseCase {
  final AuthRepository _repository;
  const SendVerificationCodeUseCase(this._repository);

  Future<void> execute(int userId) => _repository.sendVerificationCode(userId);
}
