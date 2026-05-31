import '../entities/user_stats.dart';
import '../repositories/user_stats_repository.dart';

class GetUserStatsUseCase {
  final UserStatsRepository _repository;
  const GetUserStatsUseCase(this._repository);

  Future<UserStats> execute(String role) => _repository.getStats(role);
}
