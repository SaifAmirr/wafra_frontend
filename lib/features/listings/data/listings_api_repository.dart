import 'package:wafra_frontend/core/network/api_service.dart';

class ListingsApiRepository {
  ListingsApiRepository._();
  static final instance = ListingsApiRepository._();

  Future<List<dynamic>> getListings({String? category, String? search}) =>
      ApiService.instance.getListings(category: category, search: search);

  Future<List<dynamic>> getMyReservations() =>
      ApiService.instance.getMyReservations();

  Future<void> cancelReservation(int id) =>
      ApiService.instance.cancelReservation(id);

  Future<Map<String, dynamic>> getMe() => ApiService.instance.getMe();

  Future<Map<String, dynamic>> generatePickup(int reservationId) =>
      ApiService.instance.generatePickup(reservationId);

  Future<Map<String, dynamic>> confirmPickup(
          int reservationId, String pickupCode) =>
      ApiService.instance.confirmPickup(reservationId, pickupCode);

  Future<Map<String, dynamic>> updateListing(
    int id, {
    String? foodName,
    String? category,
    int? quantity,
    String? pickupTime,
    String? location,
    List<String>? dietaryTags,
  }) =>
      ApiService.instance.updateListing(
        id,
        foodName: foodName,
        category: category,
        quantity: quantity,
        pickupTime: pickupTime,
        location: location,
        dietaryTags: dietaryTags,
      );

  Future<void> deleteListing(int id) => ApiService.instance.deleteListing(id);

  Future<void> createListing({
    required String foodName,
    required String category,
    required int quantity,
    required String pickupTime,
    required String location,
    List<String>? dietaryTags,
  }) =>
      ApiService.instance.createListing(
        foodName: foodName,
        category: category,
        quantity: quantity,
        pickupTime: pickupTime,
        location: location,
        dietaryTags: dietaryTags,
      );
}
