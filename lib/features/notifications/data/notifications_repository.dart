import 'package:wafra_frontend/core/network/api_service.dart';
import '../domain/notification_model.dart';

class NotificationsRepository {
  NotificationsRepository._();
  static final instance = NotificationsRepository._();

  Future<List<AppNotification>> getNotifications() async {
    final raw = await ApiService.instance.getNotifications();
    return raw
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAllRead() => ApiService.instance.markAllNotificationsRead();
}
