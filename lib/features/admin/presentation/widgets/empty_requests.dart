import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyRequests extends StatelessWidget {
  const EmptyRequests({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.inbox_outlined,
                size: 40, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 16),
          Text(
            'No requests yet',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your listing is live!',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}
