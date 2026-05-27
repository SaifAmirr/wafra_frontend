import 'package:wafra_frontend/core/network/api_client.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/choose_role_use_case.dart';
import '../domain/usecases/complete_restaurant_profile_use_case.dart';
import '../domain/usecases/login_use_case.dart';
import '../domain/usecases/register_use_case.dart';

class AuthProviders {
  static final AuthRemoteDataSource _dataSource =
      AuthRemoteDataSource(ApiClient.instance.dio);

  static final AuthRepository repository = AuthRepositoryImpl(_dataSource);

  static final LoginUseCase loginUseCase = LoginUseCase(repository);
  static final RegisterUseCase registerUseCase = RegisterUseCase(repository);
  static final ChooseRoleUseCase chooseRoleUseCase =
      ChooseRoleUseCase(repository);
  static final CompleteRestaurantProfileUseCase
      completeRestaurantProfileUseCase =
      CompleteRestaurantProfileUseCase(repository);
}
