import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:wafra_frontend/features/dashboard/domain/listing_model.dart';
import 'package:wafra_frontend/features/dashboard/domain/activity_item.dart';
import 'package:wafra_frontend/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:wafra_frontend/features/listings/presentation/edit_listing_screen.dart';
import 'active_listings_section.dart';
import 'sustainability_section.dart';
import 'recent_activity_section.dart';

class RestaurantHomeTab extends StatefulWidget {
  const RestaurantHomeTab({super.key});

  @override
  State<RestaurantHomeTab> createState() => RestaurantHomeTabState();
}

class RestaurantHomeTabState extends State<RestaurantHomeTab> {
  Map<String, dynamic>? _me;
  List<RestaurantListing> _listings = [];
  List<Map<String, dynamic>> _reservations = [];
  bool _loading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    load();
    _timer = Timer.periodic(
        const Duration(seconds: 15), (_) => load(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final results = await Future.wait([
        DashboardRepository.instance.getMe(),
        DashboardRepository.instance.getMyListings(),
        DashboardRepository.instance.getRestaurantReservations(),
      ]);
      if (!mounted) return;
      setState(() {
        _me = results[0] as Map<String, dynamic>;
        _listings = (results[1] as List)
            .map((j) => restaurantListingFromJson(j as Map<String, dynamic>))
            .toList();
        _reservations = (results[2] as List).cast<Map<String, dynamic>>();
      });
    } catch (_) {
    } finally {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  String _restaurantName() {
    final profile = _me?['profile'] as Map<String, dynamic>?;
    final fromProfile = profile?['restaurant_name'] as String?;
    if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;
    final user = _me?['user'] as Map<String, dynamic>?;
    return user?['username'] as String? ?? 'Restaurant';
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  int get _mealsDonated => _reservations
      .where((r) => r['status'] == 'completed')
      .fold<int>(
          0, (sum, r) => sum + ((r['requested_quantity'] as int?) ?? 0));

  int get _activeListings =>
      _listings.where((l) => l.status == ListingStatus.active).length;

  int get _pendingRequests =>
      _reservations.where((r) => r['status'] == 'pending').length;

  List<ActivityItem> _recentActivities() {
    final sorted = [..._reservations]..sort((a, b) {
        final aTime = (a['updated_at'] as String?) ??
            (a['created_at'] as String?) ??
            '';
        final bTime = (b['updated_at'] as String?) ??
            (b['created_at'] as String?) ??
            '';
        return bTime.compareTo(aTime);
      });
    return sorted.take(5).map(_activityFromReservation).toList();
  }

  ActivityItem _activityFromReservation(Map<String, dynamic> r) {
    final status = r['status'] as String? ?? 'pending';
    final receiver = r['receiver_name'] as String? ?? 'Someone';
    final food = r['food_name'] as String? ?? 'a listing';
    final qty = r['requested_quantity'] as int? ?? 0;
    final ts = (r['updated_at'] as String?) ?? (r['created_at'] as String?);
    final ago = _timeAgo(ts);

    switch (status) {
      case 'completed':
        return ActivityItem(
          icon: Icons.volunteer_activism_rounded,
          iconBg: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF3B82F6),
          title: 'Donation Picked Up',
          subtitle: '${qty}x $food · $receiver',
          time: ago,
        );
      case 'accepted':
        return ActivityItem(
          icon: Icons.check_circle_rounded,
          iconBg: const Color(0xFFECFDF5),
          iconColor: const Color(0xFF1A5C38),
          title: 'Request Confirmed',
          subtitle: '$receiver · ${qty}x $food',
          time: ago,
        );
      case 'declined':
      case 'cancelled':
        return ActivityItem(
          icon: Icons.close_rounded,
          iconBg: const Color(0xFFFEF2F2),
          iconColor: const Color(0xFFEF4444),
          title: status == 'declined'
              ? 'Request Declined'
              : 'Request Cancelled',
          subtitle: '$receiver · ${qty}x $food',
          time: ago,
        );
      default:
        return ActivityItem(
          icon: Icons.inbox_rounded,
          iconBg: const Color(0xFFFFF7ED),
          iconColor: const Color(0xFFF59E0B),
          title: 'New Pickup Request',
          subtitle: '$receiver · ${qty}x $food',
          time: ago,
        );
    }
  }

  static String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final diff = DateTime.now().difference(DateTime.parse(iso));
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: load,
      color: const Color(0xFF1A5C38),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
                greeting: _greeting(), name: _restaurantName()),
            const SizedBox(height: 24),
            SustainabilitySection(
              mealsDonated: _mealsDonated,
              activeListings: _activeListings,
              pendingRequests: _pendingRequests,
            ),
            const SizedBox(height: 24),
            ActiveListingsSection(
              listings: _listings,
              loading: _loading,
              onTap: (listing) async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => EditListingScreen(listing: listing),
                  ),
                );
                if (changed == true) load();
              },
            ),
            const SizedBox(height: 24),
            RecentActivitySection(items: _recentActivities()),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String greeting;
  final String name;

  const _Header({required this.greeting, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFDCFCE7),
          child: Icon(Icons.storefront, color: Color(0xFF1A5C38), size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const NotificationBell(),
      ],
    );
  }
}
