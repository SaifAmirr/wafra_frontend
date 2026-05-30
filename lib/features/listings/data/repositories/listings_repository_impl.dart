import '../../domain/entities/food_listing.dart';
import '../../domain/repositories/listings_repository.dart';
import '../datasources/listings_remote_data_source.dart';

class ListingsRepositoryImpl implements ListingsRepository {
  final ListingsRemoteDataSource _dataSource;
  const ListingsRepositoryImpl(this._dataSource);

  @override
  Future<List<FoodListing>> getListings({String? category}) =>
      _dataSource.getListings(category: category);

  @override
  Future<List<FoodListing>> getMyListings() => _dataSource.getMyListings();

  @override
  Future<void> createListing({
    required String foodName,
    required String category,
    required int quantity,
    required String pickupTime,
    required String location,
    List<String>? dietaryTags,
  }) =>
      _dataSource.createListing(
        foodName: foodName,
        category: category,
        quantity: quantity,
        pickupTime: pickupTime,
        location: location,
        dietaryTags: dietaryTags,
      );

  @override
  Future<void> confirmPickup(String pickupCode, {int? reservationId}) =>
      _dataSource.confirmPickup(pickupCode, reservationId: reservationId);
}
