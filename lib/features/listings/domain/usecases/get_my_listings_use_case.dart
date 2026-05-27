import '../entities/food_listing.dart';
import '../repositories/listings_repository.dart';

class GetMyListingsUseCase {
  final ListingsRepository _repository;
  const GetMyListingsUseCase(this._repository);

  Future<List<FoodListing>> execute() => _repository.getMyListings();
}
