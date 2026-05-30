import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/auth/presentation/login_screen.dart';
import 'package:wafra_frontend/core/network/api_service.dart';

class PendingVerificationScreen extends StatelessWidget {
  final String role; // 'restaurant' or 'foodbank'
  const PendingVerificationScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isRestaurant = role == 'restaurant';
    final size = MediaQuery.of(context).size;
    final topPad = (size.height * 0.055).clamp(24.0, 56.0);
    final containerSize = (size.width * 0.30).clamp(88.0, 120.0);
    final iconSize = containerSize * 0.47;
    final vGap = (size.height * 0.03).clamp(16.0, 32.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(28, topPad, 28, 32),
          child: Column(
            children: [
              Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(containerSize / 2),
                ),
                child: Icon(
                  Icons.pending_actions_outlined,
                  size: iconSize,
                  color: const Color(0xFF1A5C38),
                ),
              ),
              SizedBox(height: vGap),
              Text(
                'Your account is\nbeing reviewed',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  height: 1.3,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isRestaurant
                    ? "We're verifying your trade licence. This usually takes up to 24 hours. We'll notify you by SMS and email once approved."
                    : "We're verifying your organisation details. This takes up to 48 hours. We'll notify you once approved.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  height: 1.6,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 40),
              _StepRow(number: 1, label: 'We review your details'),
              const SizedBox(height: 16),
              _StepRow(
                  number: 2, label: 'You get an SMS / email confirmation'),
              const SizedBox(height: 16),
              _StepRow(number: 3, label: 'You can start using the app'),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () async {
                    await ApiService.instance.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                        (r) => false,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8E8E93),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Log Out',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int number;
  final String label;
  const _StepRow({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF1A5C38).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: const Color(0xFF1A5C38),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
