import '../entities/notification_prefs.dart';

abstract class NotificationPrefsRepository {
  Future<NotificationPrefs> getPrefs();
  Future<void> savePrefs(NotificationPrefs prefs);
}
