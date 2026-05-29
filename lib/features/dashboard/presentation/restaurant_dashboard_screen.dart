import 'package:flutter/material.dart';
import 'package:wafra_frontend/features/admin/presentation/manage_requests_screen.dart';
import 'package:wafra_frontend/features/listings/presentation/post_surplus_food_screen.dart';
import 'widgets/restaurant/restaurant_home_tab.dart';
import 'widgets/restaurant/post_surplus_fab.dart';
import 'widgets/restaurant/restaurant_bottom_nav.dart';
import 'profile_screen.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() =>
      _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState
    extends State<RestaurantDashboardScreen> {
  int _navIndex = 0;
  final _homeTabKey = GlobalKey<RestaurantHomeTabState>();

  int get _stackIndex => switch (_navIndex) {
        2 => 1,
        3 => 2,
        _ => 0,
      };

  void _onNavTap(int i) {
    if (i == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (_) => const PostSurplusFoodScreen()))
          .then((_) => _homeTabKey.currentState?.load());
      return;
    }
    setState(() => _navIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _stackIndex,
        children: [
          RestaurantHomeTab(key: _homeTabKey),
          const ManageRequestsScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: _navIndex == 0
          ? PostSurplusFab(
              onPosted: () => _homeTabKey.currentState?.load())
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: RestaurantBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
