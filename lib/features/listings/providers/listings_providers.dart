import '../data/datasources/listings_remote_data_source.dart';
import '../data/repositories/listings_repository_impl.dart';
import '../domain/repositories/listings_repository.dart';
import '../domain/usecases/create_listing_use_case.dart';
import '../domain/usecases/get_listings_use_case.dart';
import '../domain/usecases/get_my_listings_use_case.dart';

class ListingsProviders {
  static final ListingsRemoteDataSource _dataSource =
      ListingsRemoteDataSource();

  static final ListingsRepository repository =
      ListingsRepositoryImpl(_dataSource);

  static final GetListingsUseCase getListingsUseCase =
      GetListingsUseCase(repository);
  static final GetMyListingsUseCase getMyListingsUseCase =
      GetMyListingsUseCase(repository);
  static final CreateListingUseCase createListingUseCase =
      CreateListingUseCase(repository);
}
