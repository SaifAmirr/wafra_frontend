import 'package:flutter/material.dart';
import 'package:wafra_frontend/features/dashboard/presentation/profile_screen.dart';
import 'widgets/explore/explore_tab.dart';
import 'widgets/explore/explore_bottom_nav.dart';
import 'my_reservations_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _tab,
        children: [
          ExploreTab(onReservationMade: () => setState(() => _tab = 1)),
          MyReservationsScreen(onGoExplore: () => setState(() => _tab = 0)),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: ExploreBottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}
