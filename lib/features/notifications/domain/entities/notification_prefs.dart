class NotificationPrefs {
  final bool newListings;
  final bool reservationUpdates;
  final bool pickupReminders;
  final bool appAnnouncements;

  const NotificationPrefs({
    this.newListings = true,
    this.reservationUpdates = true,
    this.pickupReminders = true,
    this.appAnnouncements = false,
  });

  NotificationPrefs copyWith({
    bool? newListings,
    bool? reservationUpdates,
    bool? pickupReminders,
    bool? appAnnouncements,
  }) =>
      NotificationPrefs(
        newListings: newListings ?? this.newListings,
        reservationUpdates: reservationUpdates ?? this.reservationUpdates,
        pickupReminders: pickupReminders ?? this.pickupReminders,
        appAnnouncements: appAnnouncements ?? this.appAnnouncements,
      );
}
