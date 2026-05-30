import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/core/network/api_service.dart';
import 'package:wafra_frontend/features/auth/data/auth_repository.dart';
import 'package:wafra_frontend/features/auth/presentation/role_selection_screen.dart';
import 'package:wafra_frontend/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:wafra_frontend/features/dashboard/presentation/restaurant_dashboard_screen.dart';
import 'package:wafra_frontend/features/dashboard/presentation/food_bank_dashboard_screen.dart';
import 'package:wafra_frontend/features/listings/presentation/explore_screen.dart';
import 'package:wafra_frontend/features/auth/presentation/pending_verification_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final int userId;
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  bool _resending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      _showError('Please enter the 6-digit code.');
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await AuthRepository.instance.verifyEmail(widget.userId, code);
      final user = result['user'] as Map<String, dynamic>?;
      final role = user?['role'] as String?;
      final status = user?['verification_status'] as String?;
      if (!mounted) return;
      _routeAfterVerification(role, status);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Could not connect to server.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _routeAfterVerification(String? role, String? status) {
    Widget dest;
    if (role == null) {
      dest = const RoleSelectionScreen();
    } else if (status == 'pending') {
      dest = PendingVerificationScreen(role: role);
    } else if (role == 'admin') {
      dest = const AdminDashboardScreen();
    } else if (role == 'restaurant') {
      dest = const RestaurantDashboardScreen();
    } else if (role == 'foodbank') {
      dest = const FoodBankDashboardScreen();
    } else {
      dest = const ExploreScreen();
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => dest),
      (r) => false,
    );
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await AuthRepository.instance.sendVerificationCode(widget.userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code resent.'),
          backgroundColor: Color(0xFF1A5C38),
        ),
      );
    } catch (_) {
      if (mounted) _showError('Could not resend code.');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPad = (size.height * 0.055).clamp(24.0, 56.0);
    final iconSize = (size.width * 0.18).clamp(48.0, 72.0);
    final titleFontSize = (size.width * 0.065).clamp(20.0, 26.0);
    final vGap = (size.height * 0.025).clamp(14.0, 24.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, topPad, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_unread_outlined,
                  size: iconSize, color: const Color(0xFF1A5C38)),
              SizedBox(height: vGap),
              Text(
                'Check your email',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: titleFontSize,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent a 6-digit code to\n${widget.email}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 12,
                  color: const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '------',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 12,
                    color: const Color(0xFFCBD5E1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF1A5C38), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5C38),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : Text('Verify Email',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _resending ? null : _resend,
                child: _resending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF1A5C38)))
                    : Text(
                        'Resend code',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF1A5C38),
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
