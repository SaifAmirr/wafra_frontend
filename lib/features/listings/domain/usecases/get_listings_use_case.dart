import '../entities/food_listing.dart';
import '../repositories/listings_repository.dart';

class GetListingsUseCase {
  final ListingsRepository _repository;
  const GetListingsUseCase(this._repository);

  List<FoodListing> execute() => _repository.getListings();
}
