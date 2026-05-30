import '../entities/food_listing.dart';

abstract class ListingsRepository {
  Future<List<FoodListing>> getListings({String? category});
  Future<List<FoodListing>> getMyListings();
  Future<void> createListing({
    required String foodName,
    required String category,
    required int quantity,
    required String pickupTime,
    required String location,
    List<String>? dietaryTags,
  });
  Future<void> confirmPickup(String pickupCode, {int? reservationId});
}
