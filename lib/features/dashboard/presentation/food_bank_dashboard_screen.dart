import 'package:flutter/material.dart';
import 'widgets/food_bank/food_bank_home_tab.dart';
import 'widgets/food_bank/browse_tab.dart';
import 'widgets/food_bank/orders_tab.dart';
import 'widgets/food_bank/food_bank_bottom_nav.dart';
import 'profile_screen.dart';

class FoodBankDashboardScreen extends StatefulWidget {
  const FoodBankDashboardScreen({super.key});

  @override
  State<FoodBankDashboardScreen> createState() =>
      _FoodBankDashboardScreenState();
}

class _FoodBankDashboardScreenState extends State<FoodBankDashboardScreen> {
  int _tab = 0;

  void _goToBrowse() => setState(() => _tab = 1);
  void _goToOrders() => setState(() => _tab = 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _tab,
        children: [
          FoodBankHomeTab(onGoBrowse: _goToBrowse, onGoOrders: _goToOrders),
          const BrowseTab(),
          OrdersTab(onGoBrowse: _goToBrowse),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: FoodBankBottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}
