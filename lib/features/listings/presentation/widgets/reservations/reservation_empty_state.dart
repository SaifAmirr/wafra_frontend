import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/core/constants/app_colors.dart';

class ReservationEmptyState extends StatelessWidget {
  final String tabLabel;
  final VoidCallback onBrowse;

  const ReservationEmptyState({
    super.key,
    required this.tabLabel,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        const SizedBox(height: 40),
        const Center(child: _BagIllustration()),
        const SizedBox(height: 28),
        Text(
          'No reservations yet',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "You haven't made any food\nreservations. Start browsing surplus\nfood from nearby restaurants.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.65,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 36),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onBrowse,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.individualBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
            ),
            child: Text(
              'Browse Food',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _BagIllustration extends StatelessWidget {
  const _BagIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: const BoxDecoration(
        color: Color(0xFFEFF6FF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            size: 50,
            color: Color(0xFF93C5FD),
          ),
        ),
      ),
    );
  }
}
