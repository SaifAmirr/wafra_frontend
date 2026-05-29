import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/core/network/api_service.dart';
import 'package:wafra_frontend/features/auth/data/auth_repository.dart';
import 'login_screen.dart';
import 'widgets/auth_input_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final int userId;
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (code.length != 6) {
      _showError('Please enter the 6-digit code.');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      _showError('Passwords do not match.');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthRepository.instance.resetPassword(widget.userId, code, password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully. Please log in.'),
          backgroundColor: Color(0xFF1A5C38),
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (r) => false,
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
              Text(
                'Reset Password',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter the code sent to ${widget.email} and your new password.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),
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
              const SizedBox(height: 20),
              AuthInputField(
                controller: _passwordController,
                label: 'NEW PASSWORD',
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
              const SizedBox(height: 16),
              AuthInputField(
                controller: _confirmController,
                label: 'CONFIRM PASSWORD',
                hint: '••••••••',
                obscureText: _obscureConfirm,
                suffix: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
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
                      : Text('Reset Password',
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
