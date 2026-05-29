import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/core/network/api_service.dart';
import 'package:wafra_frontend/features/auth/data/auth_repository.dart';
import 'reset_password_screen.dart';
import 'widgets/auth_input_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email address.');
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await AuthRepository.instance.forgotPassword(email);
      final userId = result['user_id'] as int;
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(userId: userId, email: email),
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back_ios,
                    size: 20, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 32),
              const Icon(Icons.lock_reset_outlined,
                  size: 56, color: Color(0xFF1A5C38)),
              const SizedBox(height: 20),
              Text(
                'Forgot Password?',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter the email linked to your account and we\'ll send you a reset code.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),
              AuthInputField(
                controller: _emailController,
                label: 'EMAIL ADDRESS',
                hint: 'email@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 28),
              SizedBox(
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
                              strokeWidth: 2.5, color: Colors.white))
                      : Text('Send Reset Code',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
