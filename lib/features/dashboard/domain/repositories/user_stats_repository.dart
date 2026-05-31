import '../entities/user_stats.dart';

abstract class UserStatsRepository {
  Future<UserStats> getStats(String role);
}
