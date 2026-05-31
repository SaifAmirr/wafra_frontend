import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:wafra_frontend/features/listings/presentation/explore_screen.dart';
import 'package:wafra_frontend/features/dashboard/presentation/food_bank_dashboard_screen.dart';
import 'package:wafra_frontend/features/auth/presentation/pending_verification_screen.dart';
import 'package:wafra_frontend/features/dashboard/presentation/restaurant_dashboard_screen.dart';
import 'package:wafra_frontend/features/auth/presentation/role_selection_screen.dart';
import 'package:wafra_frontend/features/auth/presentation/signup_screen.dart';
import 'package:wafra_frontend/features/auth/presentation/email_verification_screen.dart';
import 'package:wafra_frontend/features/auth/presentation/forgot_password_screen.dart';
import 'package:wafra_frontend/core/errors/app_failure.dart';
import 'package:wafra_frontend/features/auth/providers/auth_providers.dart';
import 'widgets/auth_tab_switcher.dart';
import 'widgets/auth_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }
    setState(() => _loading = true);
    try {
      final loginUser =
          await AuthProviders.loginUseCase.execute(email, password);
      if (!mounted) return;

      if (loginUser.isEmailVerified == false) {
        final userId = loginUser.userId!;
        final userEmail = loginUser.email ?? email;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>
                EmailVerificationScreen(userId: userId, email: userEmail),
          ),
          (r) => false,
        );
        return;
      }

      final me = await AuthProviders.getMeUseCase.execute();
      final role = me.role;
      final status = me.verificationStatus;
      if (!mounted) return;
      if (role == null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          (r) => false,
        );
        return;
      }
      if (status == 'pending') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (_) => PendingVerificationScreen(role: role)),
          (r) => false,
        );
        return;
      }
      if (role == 'admin') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          (r) => false,
        );
      } else if (role == 'restaurant') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RestaurantDashboardScreen()),
          (r) => false,
        );
      } else if (role == 'foodbank') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const FoodBankDashboardScreen()),
          (r) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ExploreScreen()),
          (r) => false,
        );
      }
    } on AppFailure catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Could not connect to server.');
    } finally {
      if (mounted) setState(() => _loading = false);
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
    final logoSize = (size.width * 0.28).clamp(80.0, 120.0);
    final topPad = (size.height * 0.055).clamp(24.0, 56.0);
    final titleFontSize = (size.width * 0.075).clamp(22.0, 30.0);
    final vGap = (size.height * 0.03).clamp(16.0, 32.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, topPad, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/splash_food_illustration.svg',
                width: logoSize,
                height: logoSize,
              ),
              SizedBox(height: vGap * 0.6),
              Text(
                'Welcome',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: titleFontSize,
                  height: 36 / 30,
                  letterSpacing: titleFontSize * -0.025,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your details to get started',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  height: 24 / 16,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              SizedBox(height: vGap),
              AuthTabSwitcher(
                showLogin: true,
                onOtherTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
              ),
              SizedBox(height: vGap),
              AuthInputField(
                controller: _emailController,
                label: 'EMAIL ADDRESS',
                hint: 'email@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              AuthInputField(
                controller: _passwordController,
                label: 'PASSWORD',
                hint: '••••••••',
                obscureText: _obscurePassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen()),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 11),
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 21 / 14,
                      color: const Color(0xFF1A5C38),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5C38),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          'Log In',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            height: 27 / 18,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 19.5 / 12,
                    color: const Color(0xFF8E8E93),
                  ),
                  children: const [
                    TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextSpan(text: '\nand '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
