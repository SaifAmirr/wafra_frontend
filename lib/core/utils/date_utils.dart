import 'package:flutter/material.dart';

class AppDateUtils {
  AppDateUtils._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// DD / MM / YYYY — for date picker displays across the app.
  static String formatDisplayDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')} / '
      '${dt.month.toString().padLeft(2, '0')} / '
      '${dt.year}';

  /// HH:MM (24-hour) — for time picker displays.
  static String formatDisplayTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';

  /// YYYY-MM-DD — ISO date string for API requests.
  static String formatApiDate(DateTime dt) =>
      '${dt.year}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  /// MMM D, YYYY — e.g. "Jan 5, 2025".
  static String formatMonthDayYear(DateTime dt) =>
      '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';

  /// H:MM AM/PM from an ISO string — e.g. "2:30 PM".
  static String formatPickupTimeFromIso(String? iso,
      {String fallback = ''}) {
    if (iso == null) return fallback;
    try {
      return _amPm(DateTime.parse(iso));
    } catch (_) {
      return fallback;
    }
  }

  /// D/M/YYYY · H:MM AM/PM from an ISO string — used in request detail views.
  static String formatPickupDateTimeFromIso(String? iso,
      {String fallback = '—'}) {
    if (iso == null) return fallback;
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}  ·  ${_amPm(dt)}';
    } catch (_) {
      return fallback;
    }
  }

  static String _amPm(DateTime dt) {
    final h = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
            ? 12
            : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }
}
