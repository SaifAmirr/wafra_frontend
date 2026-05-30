import '../../domain/entities/notification_prefs.dart';
import '../../domain/repositories/notification_prefs_repository.dart';
import '../datasources/notification_prefs_local_data_source.dart';

class NotificationPrefsRepositoryImpl implements NotificationPrefsRepository {
  final NotificationPrefsLocalDataSource _dataSource;
  NotificationPrefsRepositoryImpl(this._dataSource);

  @override
  Future<NotificationPrefs> getPrefs() => _dataSource.getPrefs();

  @override
  Future<void> savePrefs(NotificationPrefs prefs) =>
      _dataSource.savePrefs(prefs);
}
