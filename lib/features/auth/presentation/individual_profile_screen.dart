import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/listings/presentation/explore_screen.dart';
import 'package:wafra_frontend/features/auth/data/auth_repository.dart';
import 'widgets/profile_form_field.dart';
import 'widgets/profile_progress_dots.dart';

class IndividualProfileScreen extends StatefulWidget {
  const IndividualProfileScreen({super.key});

  @override
  State<IndividualProfileScreen> createState() =>
      _IndividualProfileScreenState();
}

class _IndividualProfileScreenState extends State<IndividualProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _birthdate;
  bool _loading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A5C38),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthdate = picked);
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final phoneLocal = _phoneController.text.trim();
      await AuthRepository.instance.completeIndividualProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: phoneLocal.isEmpty ? '' : '+20 $phoneLocal',
        birthdate: _birthdate != null
            ? '${_birthdate!.year}-${_birthdate!.month.toString().padLeft(2, '0')}-${_birthdate!.day.toString().padLeft(2, '0')}'
            : null,
      );
    } catch (_) {
      // Profile save is best-effort; user is already authenticated so proceed.
    }
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ExploreScreen()),
      (r) => false,
    );
  }

  String get _birthdateDisplay {
    if (_birthdate == null) return 'DD / MM / YYYY';
    return '${_birthdate!.day.toString().padLeft(2, '0')} / '
        '${_birthdate!.month.toString().padLeft(2, '0')} / '
        '${_birthdate!.year}';
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
                        const Icon(Icons.person_outline,
                            size: 14, color: Color(0xFF1A5C38)),
                        const SizedBox(width: 6),
                        Text(
                          'INDIVIDUAL ROLE',
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
                      'Complete Profile',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        height: 34 / 28,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Just a few more details to get started.',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 20 / 14,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ProfileFormField(
                      label: 'First Name',
                      controller: _firstNameController,
                      hint: 'e.g. John',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 20),
                    ProfileFormField(
                      label: 'Last Name',
                      controller: _lastNameController,
                      hint: 'e.g. Doe',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Birthdate',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickBirthdate,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 18, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 12),
                                Text(
                                  _birthdateDisplay,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    color: _birthdate == null
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                    disabledBackgroundColor:
                        const Color(0xFF1A5C38).withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
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
