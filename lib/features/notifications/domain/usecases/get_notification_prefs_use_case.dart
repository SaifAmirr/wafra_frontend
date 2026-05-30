import '../entities/notification_prefs.dart';
import '../repositories/notification_prefs_repository.dart';

class GetNotificationPrefsUseCase {
  final NotificationPrefsRepository _repository;
  GetNotificationPrefsUseCase(this._repository);

  Future<NotificationPrefs> call() => _repository.getPrefs();
}
