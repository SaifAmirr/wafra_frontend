import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_chip.dart';
import 'action_button.dart';
import 'admin_colors.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const UserCard({
    super.key,
    required this.user,
    required this.onApprove,
    required this.onReject,
  });

  static const _roleColors = {
    'restaurant': Color(0xFF0EA5E9),
    'foodbank': Color(0xFF7C3AED),
    'individual': Color(0xFF1D4ED8),
    'admin': kAdminGreen,
  };

  static const _statusColors = {
    'approved': kAdminGreen,
    'pending': Color(0xFFF59E0B),
    'rejected': Color(0xFFEF4444),
    'incomplete': Color(0xFF94A3B8),
  };

  @override
  Widget build(BuildContext context) {
    final username = user['username'] as String? ?? '—';
    final email = user['email'] as String? ?? '—';
    final role = user['role'] as String? ?? 'individual';
    final status = user['verification_status'] as String? ?? 'incomplete';
    final roleColor = _roleColors[role] ?? const Color(0xFF94A3B8);
    final statusColor = _statusColors[status] ?? const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: roleColor.withValues(alpha: 0.10),
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: roleColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      email,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              AdminChip(label: role, color: roleColor),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              AdminChip(label: status, color: statusColor),
              const Spacer(),
              if (status == 'pending') ...[
                AdminActionButton(
                  label: 'Reject',
                  color: Colors.red.shade600,
                  onTap: onReject,
                ),
                const SizedBox(width: 8),
                AdminActionButton(
                  label: 'Approve',
                  color: kAdminGreen,
                  filled: true,
                  onTap: onApprove,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
