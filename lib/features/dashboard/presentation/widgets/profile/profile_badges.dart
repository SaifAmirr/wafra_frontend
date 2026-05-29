import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

List<Widget> profileBadgesForRole(String role, Color color) {
  final badges = switch (role) {
    'restaurant' => [
        ('First Listing', Icons.post_add, true),
        ('10 Meals Donated', Icons.volunteer_activism, false),
        ('Food Bank Partner', Icons.handshake_outlined, false),
        ('100 Meals Hero', Icons.emoji_events_outlined, false),
      ],
    'foodbank' => [
        ('First Pickup', Icons.check_circle_outline, true),
        ('100 kg Collected', Icons.scale_outlined, false),
        ('5 Partners', Icons.storefront_outlined, false),
        ('Community Hero', Icons.emoji_events_outlined, false),
      ],
    _ => [
        ('First Meal', Icons.dining_outlined, true),
        ('5 Pickups', Icons.check_circle_outline, false),
        ('Regular Visitor', Icons.repeat_outlined, false),
        ('Community Member', Icons.people_outline, false),
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
