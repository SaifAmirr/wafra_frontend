import '../repositories/listings_repository.dart';

class CreateListingUseCase {
  final ListingsRepository _repository;
  const CreateListingUseCase(this._repository);

  Future<void> execute({
    required String foodName,
    required String category,
    required int quantity,
    required String pickupTime,
    required String location,
    List<String>? dietaryTags,
  }) =>
      _repository.createListing(
        foodName: foodName,
        category: category,
        quantity: quantity,
        pickupTime: pickupTime,
        location: location,
        dietaryTags: dietaryTags,
      );
}
