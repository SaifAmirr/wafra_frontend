import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/auth/presentation/pending_verification_screen.dart';
import 'package:wafra_frontend/core/errors/app_failure.dart';
import 'package:wafra_frontend/features/auth/providers/auth_providers.dart';
import 'widgets/profile_form_field.dart';
import 'widgets/profile_progress_dots.dart';

class FoodBankProfileScreen extends StatefulWidget {
  const FoodBankProfileScreen({super.key});

  @override
  State<FoodBankProfileScreen> createState() => _FoodBankProfileScreenState();
}

class _FoodBankProfileScreenState extends State<FoodBankProfileScreen> {
  final _orgNameController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _contactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  bool _loading = false;

  static const _accent = Color(0xFF7C3AED);

  @override
  void dispose() {
    _orgNameController.dispose();
    _regNumberController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final orgName = _orgNameController.text.trim();
    if (orgName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your organisation name.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final phoneLocal = _phoneController.text.trim();
      await AuthProviders.completeFoodBankProfileUseCase.execute(
        organizationName: orgName,
        registrationNumber: _regNumberController.text.trim(),
        phone: phoneLocal.isEmpty ? '' : '+20 $phoneLocal',
        location: _locationController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) =>
                const PendingVerificationScreen(role: 'foodbank')),
        (r) => false,
      );
    } on AppFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.red.shade700),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not connect to server.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.arrow_back_ios,
                              size: 20, color: Color(0xFF0F172A)),
                        ),
                        const Expanded(
                          child: Center(
                            child: ProfileProgressDots(
                              currentStep: 1,
                              totalSteps: 3,
                              activeColor: _accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Icon(Icons.account_balance_outlined,
                            size: 14, color: _accent),
                        const SizedBox(width: 6),
                        Text(
                          'FOOD BANK ROLE',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 11 * 0.05,
                            color: _accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Organisation Details',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        height: 34 / 28,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete your profile to start collecting surplus food for your community.',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 20 / 14,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ProfileFormField(
                      label: 'Organisation Name',
                      controller: _orgNameController,
                      hint: 'e.g. Cairo Food Bank',
                      icon: Icons.account_balance_outlined,
                      focusColor: _accent,
                    ),
                    const SizedBox(height: 20),
                    ProfileFormField(
                      label: 'Official Registration Number',
                      controller: _regNumberController,
                      hint: 'NGO-123456',
                      icon: Icons.badge_outlined,
                      focusColor: _accent,
                    ),
                    const SizedBox(height: 20),
                    ProfileFormField(
                      label: 'Contact Person Name',
                      controller: _contactController,
                      hint: 'Full name of coordinator',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      focusColor: _accent,
                    ),
                    const SizedBox(height: 20),
                    ProfileFormField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      hint: '10 0000 0000',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      prefixText: '+20 ',
                      focusColor: _accent,
                    ),
                    const SizedBox(height: 20),
                    ProfileFormField(
                      label: 'Service Area / Location',
                      controller: _locationController,
                      hint: 'e.g. Maadi, Cairo',
                      icon: Icons.location_on_outlined,
                      keyboardType: TextInputType.streetAddress,
                      focusColor: _accent,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline,
                              size: 18, color: _accent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'We verify food banks to protect our community — review takes up to 48 hours.',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                height: 1.5,
                                color: const Color(0xFF6D28D9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
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
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          'Complete Setup',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
