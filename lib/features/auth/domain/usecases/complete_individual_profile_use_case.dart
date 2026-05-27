import '../repositories/auth_repository.dart';

class CompleteIndividualProfileUseCase {
  final AuthRepository _repository;
  const CompleteIndividualProfileUseCase(this._repository);

  Future<void> execute({
    String? firstName,
    String? lastName,
    String? phone,
    String? birthdate,
  }) =>
      _repository.completeIndividualProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        birthdate: birthdate,
      );
}
