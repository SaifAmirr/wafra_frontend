import 'package:flutter/material.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/overview_tab.dart';
import 'widgets/users_tab.dart';
import 'widgets/listings_tab.dart';
import 'widgets/tickets_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _tab,
        children: const [
          OverviewTab(),
          UsersTab(),
          ListingsTab(),
          TicketsTab(),
        ],
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}
