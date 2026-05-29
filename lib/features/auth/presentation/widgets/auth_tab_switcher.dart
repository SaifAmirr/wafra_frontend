import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTabSwitcher extends StatelessWidget {
  final bool showLogin;
  final VoidCallback onOtherTap;

  const AuthTabSwitcher({
    super.key,
    required this.showLogin,
    required this.onOtherTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _AuthTab(
            label: 'Sign Up',
            active: !showLogin,
            onTap: showLogin ? onOtherTap : () {},
          ),
          _AuthTab(
            label: 'Log In',
            active: showLogin,
            onTap: showLogin ? () {} : onOtherTap,
          ),
        ],
      ),
    );
  }
}

class _AuthTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _AuthTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
                ? const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 21 / 14,
              color: active
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF8E8E93),
            ),
          ),
        ),
      ),
    );
  }
}
