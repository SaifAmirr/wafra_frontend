import 'package:wafra_frontend/core/network/api_service.dart';
import '../../domain/entities/user_stats.dart';

class UserStatsRemoteDataSource {
  const UserStatsRemoteDataSource();

  Future<UserStats> getStats(String role) async {
    if (role == 'restaurant') {
      return _restaurantStats();
    } else {
      return _receiverStats();
    }
  }

  Future<UserStats> _restaurantStats() async {
    final results = await Future.wait([
      ApiService.instance.getMyListings(),
      ApiService.instance.getRestaurantReservations(),
    ]);

    final listings = results[0];
    final reservations = results[1];

    final completed = reservations
        .where((r) => (r['status'] as String?) == 'completed')
        .toList();

    final mealsDonated = completed.fold<double>(
      0,
      (sum, r) => sum + ((r['requested_quantity'] as num?)?.toDouble() ?? 0),
    ).round();

    final partnersServed =
        completed.map((r) => r['user_id']).toSet().length;

    return UserStats(
      listingsPosted: listings.length,
      mealsDonated: mealsDonated,
      partnersServed: partnersServed,
    );
  }

  Future<UserStats> _receiverStats() async {
    final reservations = await ApiService.instance.getMyReservations();

    final completed = reservations
        .where((r) => (r['status'] as String?) == 'completed')
        .toList();

    final mealsReceived = completed.fold<double>(
      0,
      (sum, r) => sum + ((r['requested_quantity'] as num?)?.toDouble() ?? 0),
    ).round();

    final restaurantsVisited =
        completed.map((r) => r['restaurant_name']).toSet().length;

    return UserStats(
      mealsReceived: mealsReceived,
      pickupsCompleted: completed.length,
      restaurantsVisited: restaurantsVisited,
    );
  }
}
