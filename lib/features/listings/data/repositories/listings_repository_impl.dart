import '../../domain/entities/food_listing.dart';
import '../../domain/repositories/listings_repository.dart';
import '../datasources/listings_remote_data_source.dart';

class ListingsRepositoryImpl implements ListingsRepository {
  final ListingsRemoteDataSource _dataSource;
  const ListingsRepositoryImpl(this._dataSource);

  @override
  List<FoodListing> getListings() => _dataSource.getListings();
}
