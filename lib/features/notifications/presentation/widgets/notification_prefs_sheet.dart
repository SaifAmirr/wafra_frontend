import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/datasources/notification_prefs_local_data_source.dart';
import '../../data/repositories/notification_prefs_repository_impl.dart';
import '../../domain/entities/notification_prefs.dart';
import '../../domain/usecases/get_notification_prefs_use_case.dart';
import '../../domain/usecases/save_notification_prefs_use_case.dart';

Future<void> showNotificationPrefsSheet(BuildContext context, Color accent) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _NotificationPrefsSheet(accent: accent),
  );
}

class _NotificationPrefsSheet extends StatefulWidget {
  final Color accent;
  const _NotificationPrefsSheet({required this.accent});

  @override
  State<_NotificationPrefsSheet> createState() =>
      _NotificationPrefsSheetState();
}

class _NotificationPrefsSheetState extends State<_NotificationPrefsSheet> {
  late final GetNotificationPrefsUseCase _getPrefs;
  late final SaveNotificationPrefsUseCase _savePrefs;

  NotificationPrefs _prefs = const NotificationPrefs();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final repo = NotificationPrefsRepositoryImpl(
      NotificationPrefsLocalDataSource(),
    );
    _getPrefs = GetNotificationPrefsUseCase(repo);
    _savePrefs = SaveNotificationPrefsUseCase(repo);
    _load();
  }

  Future<void> _load() async {
    final p = await _getPrefs();
    if (!mounted) return;
    setState(() {
      _prefs = p;
      _loading = false;
    });
  }

  Future<void> _toggle(NotificationPrefs updated) async {
    setState(() => _prefs = updated);
    await _savePrefs(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: widget.accent.withValues(alpha: 0.10),
                child: Icon(Icons.notifications_outlined,
                    color: widget.accent, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Preferences',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Choose what you want to be notified about',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else ...[
            _PrefTile(
              icon: Icons.restaurant_menu_outlined,
              title: 'New Listings',
              subtitle: 'Get notified when new food is posted nearby',
              value: _prefs.newListings,
              accent: widget.accent,
              onChanged: (v) =>
                  _toggle(_prefs.copyWith(newListings: v)),
            ),
            _divider(),
            _PrefTile(
              icon: Icons.bookmark_outline,
              title: 'Reservation Updates',
              subtitle: 'When your reservation is accepted or declined',
              value: _prefs.reservationUpdates,
              accent: widget.accent,
              onChanged: (v) =>
                  _toggle(_prefs.copyWith(reservationUpdates: v)),
            ),
            _divider(),
            _PrefTile(
              icon: Icons.access_time_outlined,
              title: 'Pickup Reminders',
              subtitle: 'Reminders before your scheduled pickup time',
              value: _prefs.pickupReminders,
              accent: widget.accent,
              onChanged: (v) =>
                  _toggle(_prefs.copyWith(pickupReminders: v)),
            ),
            _divider(),
            _PrefTile(
              icon: Icons.campaign_outlined,
              title: 'App Announcements',
              subtitle: 'Updates and news from the Wafra team',
              value: _prefs.appAnnouncements,
              accent: widget.accent,
              onChanged: (v) =>
                  _toggle(_prefs.copyWith(appAnnouncements: v)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: Color(0xFFF1F5F9));
}

class _PrefTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color accent;
  final ValueChanged<bool> onChanged;

  const _PrefTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value
                  ? accent.withValues(alpha: 0.08)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: value ? accent : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF8E8E93),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: accent,
          ),
        ],
      ),
    );
  }
}
