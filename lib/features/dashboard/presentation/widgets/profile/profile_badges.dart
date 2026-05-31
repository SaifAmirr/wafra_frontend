import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/dashboard/domain/entities/user_stats.dart';

List<Widget> profileBadgesForRole(
    String role, Color color, UserStats? stats) {
  final badges = switch (role) {
    'restaurant' => [
        (
          'First Listing',
          Icons.post_add,
          (stats?.listingsPosted ?? 0) >= 1,
        ),
        (
          '10 Meals Donated',
          Icons.volunteer_activism,
          (stats?.mealsDonated ?? 0) >= 10,
        ),
        (
          'Food Bank Partner',
          Icons.handshake_outlined,
          (stats?.partnersServed ?? 0) >= 1,
        ),
        (
          '100 Meals Hero',
          Icons.emoji_events_outlined,
          (stats?.mealsDonated ?? 0) >= 100,
        ),
      ],
    'foodbank' => [
        (
          'First Pickup',
          Icons.check_circle_outline,
          (stats?.pickupsCompleted ?? 0) >= 1,
        ),
        (
          '100 Meals Collected',
          Icons.scale_outlined,
          (stats?.mealsReceived ?? 0) >= 100,
        ),
        (
          '5 Partners',
          Icons.storefront_outlined,
          (stats?.restaurantsVisited ?? 0) >= 5,
        ),
        (
          'Community Hero',
          Icons.emoji_events_outlined,
          (stats?.mealsReceived ?? 0) >= 500,
        ),
      ],
    _ => [
        (
          'First Meal',
          Icons.dining_outlined,
          (stats?.pickupsCompleted ?? 0) >= 1,
        ),
        (
          '5 Pickups',
          Icons.check_circle_outline,
          (stats?.pickupsCompleted ?? 0) >= 5,
        ),
        (
          'Regular Visitor',
          Icons.repeat_outlined,
          (stats?.restaurantsVisited ?? 0) >= 3,
        ),
        (
          'Community Member',
          Icons.people_outline,
          (stats?.pickupsCompleted ?? 0) >= 10,
        ),
      ],
  };

  return badges.map((b) {
    final (label, icon, unlocked) = b;
    return Container(
      width: 88,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: unlocked ? color.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked
              ? color.withValues(alpha: 0.25)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 24, color: unlocked ? color : const Color(0xFFCBD5E1)),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: unlocked
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }).toList();
}
