import '../data/datasources/user_stats_remote_data_source.dart';
import '../data/repositories/user_stats_repository_impl.dart';
import '../domain/repositories/user_stats_repository.dart';
import '../domain/usecases/get_user_stats_use_case.dart';

class DashboardProviders {
  static final UserStatsRepository _userStatsRepository =
      UserStatsRepositoryImpl(const UserStatsRemoteDataSource());

  static final GetUserStatsUseCase getUserStatsUseCase =
      GetUserStatsUseCase(_userStatsRepository);
}
