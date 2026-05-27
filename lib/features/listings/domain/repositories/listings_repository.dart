import '../entities/food_listing.dart';

abstract class ListingsRepository {
  List<FoodListing> getListings();
}
