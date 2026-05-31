import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/user_stats_repository.dart';
import '../datasources/user_stats_remote_data_source.dart';

class UserStatsRepositoryImpl implements UserStatsRepository {
  final UserStatsRemoteDataSource _dataSource;
  const UserStatsRepositoryImpl(this._dataSource);

  @override
  Future<UserStats> getStats(String role) => _dataSource.getStats(role);
}
