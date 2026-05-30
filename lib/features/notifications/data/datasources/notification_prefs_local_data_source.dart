import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/notification_prefs.dart';

const _kNewListings = 'notif_new_listings';
const _kReservationUpdates = 'notif_reservation_updates';
const _kPickupReminders = 'notif_pickup_reminders';
const _kAppAnnouncements = 'notif_app_announcements';

class NotificationPrefsLocalDataSource {
  Future<NotificationPrefs> getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPrefs(
      newListings: prefs.getBool(_kNewListings) ?? true,
      reservationUpdates: prefs.getBool(_kReservationUpdates) ?? true,
      pickupReminders: prefs.getBool(_kPickupReminders) ?? true,
      appAnnouncements: prefs.getBool(_kAppAnnouncements) ?? false,
    );
  }

  Future<void> savePrefs(NotificationPrefs p) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_kNewListings, p.newListings),
      prefs.setBool(_kReservationUpdates, p.reservationUpdates),
      prefs.setBool(_kPickupReminders, p.pickupReminders),
      prefs.setBool(_kAppAnnouncements, p.appAnnouncements),
    ]);
  }
}
