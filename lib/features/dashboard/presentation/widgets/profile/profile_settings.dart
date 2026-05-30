import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/auth/presentation/login_screen.dart';
import 'package:wafra_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:wafra_frontend/features/dashboard/presentation/widgets/profile/language_dialog.dart';
import 'package:wafra_frontend/features/dashboard/presentation/widgets/profile/legal_sheet.dart';
import 'package:wafra_frontend/features/notifications/presentation/widgets/notification_prefs_sheet.dart';
import 'package:wafra_frontend/features/support/presentation/widgets/support_dialog.dart';

class ProfileSettings extends StatelessWidget {
  final Color accent;

  const ProfileSettings({super.key, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _SettingRow(
            icon: Icons.notifications_outlined,
            label: 'Notification Preferences',
            onTap: () => showNotificationPrefsSheet(context, accent),
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFE2E8F0)),
          _SettingRow(
            icon: Icons.language_outlined,
            label: 'Language',
            trailing: 'English',
            onTap: () => showLanguageDialog(context, accent),
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFE2E8F0)),
          _SettingRow(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () => showPrivacyPolicy(context, accent),
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFE2E8F0)),
          _SettingRow(
            icon: Icons.article_outlined,
            label: 'Terms of Service',
            onTap: () => showTermsOfService(context, accent),
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFE2E8F0)),
          _SettingRow(
            icon: Icons.help_outline,
            label: 'Help & Support',
            onTap: () => showSupportDialog(context, accent),
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFE2E8F0)),
          _SettingRow(
            icon: Icons.logout,
            label: 'Log Out',
            color: Colors.red.shade600,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Log Out',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  content: Text('Are you sure you want to log out?',
                      style: GoogleFonts.inter()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Log Out',
                          style: TextStyle(color: Colors.red.shade600)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await DashboardRepository.instance.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (r) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final Color? color;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF0F172A);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: c,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: const Color(0xFF8E8E93),
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 18, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
