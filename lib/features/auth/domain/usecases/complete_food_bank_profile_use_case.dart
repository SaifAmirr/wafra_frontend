import '../repositories/auth_repository.dart';

class CompleteFoodBankProfileUseCase {
  final AuthRepository _repository;
  const CompleteFoodBankProfileUseCase(this._repository);

  Future<void> execute({
    required String organizationName,
    String? registrationNumber,
    String? phone,
    String? location,
  }) =>
      _repository.completeFoodBankProfile(
        organizationName: organizationName,
        registrationNumber: registrationNumber,
        phone: phone,
        location: location,
      );
}
