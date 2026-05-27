import '../entities/food_listing.dart';
import '../repositories/listings_repository.dart';

class GetListingsUseCase {
  final ListingsRepository _repository;
  const GetListingsUseCase(this._repository);

  Future<List<FoodListing>> execute({String? category}) =>
      _repository.getListings(category: category);
}
