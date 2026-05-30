import '../repositories/listings_repository.dart';

class ConfirmPickupUseCase {
  final ListingsRepository _repository;
  const ConfirmPickupUseCase(this._repository);

  Future<void> call(String pickupCode, {int? reservationId}) =>
      _repository.confirmPickup(pickupCode, reservationId: reservationId);
}
