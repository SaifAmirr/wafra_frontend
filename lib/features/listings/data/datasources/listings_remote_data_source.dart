import 'package:wafra_frontend/core/errors/app_failure.dart';
import 'package:wafra_frontend/core/network/api_service.dart';
import '../../domain/entities/food_listing.dart';

class ListingsRemoteDataSource {
  Future<List<FoodListing>> getListings({String? category}) async {
    try {
      final raw = await ApiService.instance.getListings(category: category);
      return raw
          .map((j) => FoodListing.fromJson(j as Map<String, dynamic>))
          .toList();
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not load listings.');
    }
  }

  Future<List<FoodListing>> getMyListings() async {
    try {
      final raw = await ApiService.instance.getMyListings();
      return raw
          .map((j) => FoodListing.fromJson(j as Map<String, dynamic>))
          .toList();
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not load your listings.');
    }
  }

  Future<void> createListing({
    required String foodName,
    required String category,
    required int quantity,
    required String pickupTime,
    required String location,
    String? photoPath,
    List<String>? dietaryTags,
  }) async {
    try {
      await ApiService.instance.createListing(
        foodName: foodName,
        category: category,
        quantity: quantity,
        pickupTime: pickupTime,
        location: location,
        photoPath: photoPath,
        dietaryTags: dietaryTags,
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not create listing.');
    }
  }

  Future<void> confirmPickup(String pickupCode, {int? reservationId}) async {
    try {
      await ApiService.instance.confirmPickup(pickupCode,
          reservationId: reservationId);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not confirm pickup. Please try again.');
    }
  }
}
