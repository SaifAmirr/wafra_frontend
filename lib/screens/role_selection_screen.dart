import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/screens/food_bank_profile_screen.dart';
import 'package:wafra_frontend/screens/individual_profile_screen.dart';
import 'package:wafra_frontend/screens/restaurant_profile_screen.dart';
import 'package:wafra_frontend/services/api_service.dart';

enum UserRole { restaurant, individual, foodBank }

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;
  bool _loading = false;

  static const _roleStrings = {
    UserRole.restaurant: 'restaurant',
    UserRole.individual: 'individual',
    UserRole.foodBank: 'foodbank',
  };

  Future<void> _chooseRole() async {
    if (_selectedRole == null) return;
    setState(() => _loading = true);
    try {
      await ApiService.instance.chooseRole(_roleStrings[_selectedRole]!);
      if (!mounted) return;
      switch (_selectedRole) {
        case UserRole.restaurant:
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RestaurantProfileScreen()),
          );
        case UserRole.individual:
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const IndividualProfileScreen()),
          );
        case UserRole.foodBank:
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FoodBankProfileScreen()),
          );
        case null:
      }
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade700),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not connect to server.'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button + progress indicator
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Expanded(
                    child: Center(child: _ProgressDots(currentStep: 0, totalSteps: 3)),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                'Choose your role',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  height: 34 / 28,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Tell us how you want to use the app',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 20 / 14,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 32),

              _RoleCard(
                title: 'Restaurant',
                subtitle: 'Donate surplus food and manage donations',
                icon: Icons.storefront_outlined,
                iconBg: const Color(0xFFF2F2F7),
                iconColor: const Color(0xFF64748B),
                selected: _selectedRole == UserRole.restaurant,
                onTap: () => setState(() => _selectedRole = UserRole.restaurant),
              ),
              const SizedBox(height: 16),

              _RoleCard(
                title: 'Individual',
                subtitle: 'Find food nearby or share with neighbors',
                icon: Icons.person_outline,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                selected: _selectedRole == UserRole.individual,
                onTap: () => setState(() => _selectedRole = UserRole.individual),
              ),
              const SizedBox(height: 16),

              _RoleCard(
                title: 'Food Bank',
                subtitle: 'Coordinate large scale distributions',
                icon: Icons.volunteer_activism_outlined,
                iconBg: const Color(0xFFF5F3FF),
                iconColor: const Color(0xFF8B5CF6),
                selected: _selectedRole == UserRole.foodBank,
                onTap: () => setState(() => _selectedRole = UserRole.foodBank),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_selectedRole == null || _loading) ? null : _chooseRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5C38),
                    disabledBackgroundColor:
                        const Color(0xFF1A5C38).withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Continue',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            height: 27 / 18,
                          ),
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

// ─── Role card ────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFECFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF1A5C38) : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 1.4,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? Container(
                      key: const ValueKey(true),
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A5C38),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    )
                  : Container(
                      key: const ValueKey(false),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 2,
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

// ─── Progress dots ────────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _ProgressDots({required this.currentStep, required this.totalSteps});

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
                  ? const Color(0xFF1A5C38)
                  : const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
