import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final String? prefixText;
  final Color focusColor;

  const ProfileFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.prefixText,
    this.focusColor = const Color(0xFF1A5C38),
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
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
            prefixText: prefixText,
            prefixStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: const Color(0xFF0F172A),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              borderSide: BorderSide(color: focusColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
