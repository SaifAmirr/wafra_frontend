import '../entities/notification_prefs.dart';
import '../repositories/notification_prefs_repository.dart';

class SaveNotificationPrefsUseCase {
  final NotificationPrefsRepository _repository;
  SaveNotificationPrefsUseCase(this._repository);

  Future<void> call(NotificationPrefs prefs) => _repository.savePrefs(prefs);
}
