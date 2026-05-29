import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logout_button.dart';

class AdminSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AdminSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
          const Spacer(),
          const LogoutButton(),
        ],
      ),
    );
  }
}
