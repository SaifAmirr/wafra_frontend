import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/auth/presentation/login_screen.dart';
import 'package:wafra_frontend/features/auth/presentation/role_selection_screen.dart';
import 'package:wafra_frontend/features/auth/data/auth_repository.dart';
import 'package:wafra_frontend/core/network/api_service.dart';
import 'widgets/auth_tab_switcher.dart';
import 'widgets/auth_input_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      _showError('Please enter a username.');
      return;
    }
    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthRepository.instance.register(email, password, username);
      if (AuthRepository.instance.token == null) {
        await AuthRepository.instance.login(email, password);
      }
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    } on ApiException catch (e) {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/splash_food_illustration.svg',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                  height: 36 / 30,
                  letterSpacing: 30 * -0.025,
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
              const SizedBox(height: 32),
              AuthTabSwitcher(
                showLogin: false,
                onOtherTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
              const SizedBox(height: 32),
              AuthInputField(
                controller: _usernameController,
                label: 'USERNAME',
                hint: 'username',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
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
                          'Continue',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            height: 27 / 18,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Or continue with Email',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 21 / 14,
                    color: const Color(0xFF1A5C38),
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
