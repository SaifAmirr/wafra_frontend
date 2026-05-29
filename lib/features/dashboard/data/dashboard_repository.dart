import 'package:wafra_frontend/core/network/api_service.dart';

class DashboardRepository {
  DashboardRepository._();
  static final instance = DashboardRepository._();

  Future<Map<String, dynamic>> getMe() => ApiService.instance.getMe();

  Future<void> logout() => ApiService.instance.logout();

  Future<List<dynamic>> getMyListings() =>
      ApiService.instance.getMyListings();

  Future<List<dynamic>> getRestaurantReservations() =>
      ApiService.instance.getRestaurantReservations();

  Future<List<dynamic>> getListings({String? category, String? search}) =>
      ApiService.instance.getListings(category: category, search: search);

  Future<List<dynamic>> getMyReservations() =>
      ApiService.instance.getMyReservations();

  Future<Map<String, dynamic>> createReservation(
          int listingId, int quantity) =>
      ApiService.instance.createReservation(listingId, quantity);

  Future<void> cancelReservation(int id) =>
      ApiService.instance.cancelReservation(id);
}
