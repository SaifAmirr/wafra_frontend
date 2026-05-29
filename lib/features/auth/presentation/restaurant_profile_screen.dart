import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/auth/presentation/pending_verification_screen.dart';
import 'package:wafra_frontend/features/auth/data/auth_repository.dart';
import 'package:wafra_frontend/core/network/api_service.dart';
import 'widgets/profile_form_field.dart';
import 'widgets/profile_progress_dots.dart';

class RestaurantProfileScreen extends StatefulWidget {
  const RestaurantProfileScreen({super.key});

  @override
  State<RestaurantProfileScreen> createState() =>
      _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState extends State<RestaurantProfileScreen> {
  final _nameController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cuisineController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your restaurant name.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final phoneLocal = _phoneController.text.trim();
      await AuthRepository.instance.completeRestaurantProfile(
        restaurantName: name,
        cuisineType: _cuisineController.text.trim(),
        fullAddress: _addressController.text.trim(),
        phone: phoneLocal.isEmpty ? '' : '+20 $phoneLocal',
        businessLicenseNumber: _licenseController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) =>
                const PendingVerificationScreen(role: 'restaurant')),
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
          SnackBar(
            content: const Text('Could not connect to server.'),
            backgroundColor: Colors.red.shade700,
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
                                currentStep: 1, totalSteps: 3),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Icon(Icons.storefront_outlined,
                            size: 14, color: Color(0xFF1A5C38)),
                        const SizedBox(width: 6),
                        Text(
                          'RESTAURANT ROLE',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 11 * 0.05,
                            color: const Color(0xFF1A5C38),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Business Details',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        height: 34 / 28,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete your profile to start donating surplus food safely.',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 20 / 14,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ProfileFormField(
                      label: 'Restaurant Name',
                      controller: _nameController,
                      hint: 'e.g. The Green Kitchen',
                      icon: Icons.storefront_outlined,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 20),
                    ProfileFormField(
                      label: 'Cuisine Type',
                      controller: _cuisineController,
                      hint: 'e.g. Mediterranean, Fast Food',
                      icon: Icons.restaurant_menu_outlined,
                    ),
                    const SizedBox(height: 20),
                    ProfileFormField(
                      label: 'Full Address',
                      controller: _addressController,
                      hint: 'Street, City, Zip Code',
                      icon: Icons.location_on_outlined,
                      keyboardType: TextInputType.streetAddress,
                    ),
                    const SizedBox(height: 20),
                    ProfileFormField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      hint: '10 0000 0000',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      prefixText: '+20 ',
                    ),
                    const SizedBox(height: 20),
                    ProfileFormField(
                      label: 'Business License Number',
                      controller: _licenseController,
                      hint: 'LIC-987654321',
                      icon: Icons.badge_outlined,
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
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          'Complete Setup',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            height: 27 / 18,
                          ),
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
