import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/screens/pending_verification_screen.dart';
import 'package:wafra_frontend/services/api_service.dart';

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
      await ApiService.instance.completeFoodBankProfile(
        organizationName: orgName,
        registrationNumber: _regNumberController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => const PendingVerificationScreen(role: 'foodbank')),
        (r) => false,
      );
    } on ApiException catch (e) {
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
                    // Back + progress
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.arrow_back_ios,
                              size: 20, color: Color(0xFF0F172A)),
                        ),
                        const Expanded(
                          child: Center(
                            child: _ProgressDots(
                                currentStep: 1, totalSteps: 3),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Role tag
                    Row(
                      children: [
                        const Icon(Icons.account_balance_outlined,
                            size: 14, color: Color(0xFF7C3AED)),
                        const SizedBox(width: 6),
                        Text(
                          'FOOD BANK ROLE',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 11 * 0.05,
                            color: const Color(0xFF7C3AED),
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

                    _FormField(
                      label: 'Organisation Name',
                      controller: _orgNameController,
                      hint: 'e.g. Cairo Food Bank',
                      icon: Icons.account_balance_outlined,
                    ),
                    const SizedBox(height: 20),

                    _FormField(
                      label: 'Official Registration Number',
                      controller: _regNumberController,
                      hint: 'NGO-123456',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 20),

                    _FormField(
                      label: 'Contact Person Name',
                      controller: _contactController,
                      hint: 'Full name of coordinator',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 20),

                    _FormField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      hint: '+20 10 0000 0000',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    _FormField(
                      label: 'Service Area / Location',
                      controller: _locationController,
                      hint: 'e.g. Maadi, Cairo',
                      icon: Icons.location_on_outlined,
                      keyboardType: TextInputType.streetAddress,
                    ),

                    // Info note
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
                              size: 18, color: Color(0xFF7C3AED)),
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

            // Fixed button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
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

// ─── Reusable form field ──────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: const Color(0xFFCBD5E1),
            ),
            prefixIcon:
                Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Progress dots ────────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _ProgressDots(
      {required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (i) {
        final isActive = i == currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF7C3AED)
                  : const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
