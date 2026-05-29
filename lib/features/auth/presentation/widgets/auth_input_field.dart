import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffix;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: const Color(0xFFCBD5E1),
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
          borderSide: const BorderSide(color: Color(0xFF1A5C38), width: 1.5),
        ),
      ),
    );
    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.8,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
