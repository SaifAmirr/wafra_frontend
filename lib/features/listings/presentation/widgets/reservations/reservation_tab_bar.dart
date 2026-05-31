import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/core/constants/app_colors.dart';

class ReservationTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const ReservationTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicatorColor: AppColors.individualBlue,
      indicatorWeight: 2.5,
      dividerColor: const Color(0xFFE2E8F0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      labelStyle:
          GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
      unselectedLabelStyle:
          GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
      labelColor: AppColors.individualBlue,
      unselectedLabelColor: const Color(0xFF94A3B8),
      tabs: tabs.map((t) => Tab(text: t)).toList(),
    );
  }
}
