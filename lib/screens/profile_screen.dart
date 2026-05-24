import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/screens/login_screen.dart';
import 'package:wafra_frontend/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.instance.getMe();
      if (!mounted) return;
      setState(() => _user = data['user'] as Map<String, dynamic>?);
    } catch (_) {
      // show what we have
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _role => _user?['role'] as String? ?? 'individual';
  String get _username => _user?['username'] as String? ?? '—';
  String get _email => _user?['email'] as String? ?? '—';

  Color get _accent {
    switch (_role) {
      case 'restaurant':
        return const Color(0xFF1A5C38);
      case 'foodbank':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF1D4ED8);
    }
  }

  String get _roleLabel {
    switch (_role) {
      case 'restaurant':
        return 'Restaurant';
      case 'foodbank':
        return 'Food Bank';
      default:
        return 'Individual';
    }
  }

  List<_ImpactStat> get _impactStats {
    switch (_role) {
      case 'restaurant':
        return const [
          _ImpactStat(label: 'Meals Donated', value: '—',
              icon: Icons.volunteer_activism_outlined),
          _ImpactStat(label: 'Listings Posted', value: '—',
              icon: Icons.post_add_outlined),
          _ImpactStat(label: 'Food Banks Served', value: '—',
              icon: Icons.account_balance_outlined),
        ];
      case 'foodbank':
        return const [
          _ImpactStat(label: 'Meals Collected', value: '—',
              icon: Icons.kitchen_outlined),
          _ImpactStat(label: 'Meals Distributed', value: '—',
              icon: Icons.people_outline),
          _ImpactStat(label: 'Restaurant Partners', value: '—',
              icon: Icons.storefront_outlined),
        ];
      default:
        return const [
          _ImpactStat(label: 'Meals Received', value: '—',
              icon: Icons.dining_outlined),
          _ImpactStat(label: 'Pickups Completed', value: '—',
              icon: Icons.check_circle_outline),
          _ImpactStat(label: 'Restaurants Visited', value: '—',
              icon: Icons.storefront_outlined),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: _accent))
          : RefreshIndicator(
              onRefresh: _load,
              color: _accent,
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: _buildHeader(),
                  ),

                  // Impact strip
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        children: _impactStats
                            .map((s) => _ImpactCard(stat: s, color: _accent))
                            .expand((w) => [
                                  w,
                                  const SizedBox(width: 10)
                                ])
                            .toList()
                          ..removeLast(),
                      ),
                    ),
                  ),

                  // Badges
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 28, 20, 12),
                      child: Text(
                        'Badges',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100,
                      child: ListView(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        children: _badgesForRole(_role, _accent),
                      ),
                    ),
                  ),

                  // Settings
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 28, 20, 12),
                      child: Text(
                        'Settings',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildSettings(context),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: _accent.withValues(alpha: 0.12),
            child: Text(
              _username.isNotEmpty ? _username[0].toUpperCase() : '?',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 28,
                color: _accent,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _roleLabel,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: _accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
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
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFE2E8F0)),
          _SettingRow(
            icon: Icons.language_outlined,
            label: 'Language',
            trailing: 'English',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFE2E8F0)),
          _SettingRow(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFE2E8F0)),
          _SettingRow(
            icon: Icons.article_outlined,
            label: 'Terms of Service',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFE2E8F0)),
          _SettingRow(
            icon: Icons.help_outline,
            label: 'Help & Support',
            onTap: () {},
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
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700)),
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
                await ApiService.instance.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
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

// ─── Impact helpers ───────────────────────────────────────────────────────────

class _ImpactStat {
  final String label;
  final String value;
  final IconData icon;
  const _ImpactStat(
      {required this.label, required this.value, required this.icon});
}

class _ImpactCard extends StatelessWidget {
  final _ImpactStat stat;
  final Color color;
  const _ImpactCard({required this.stat, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(stat.icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(
              stat.value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              stat.label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 10,
                color: const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Badges ───────────────────────────────────────────────────────────────────

List<Widget> _badgesForRole(String role, Color color) {
  final badges = switch (role) {
    'restaurant' => [
        ('First Listing', Icons.post_add, true),
        ('10 Meals Donated', Icons.volunteer_activism, false),
        ('Food Bank Partner', Icons.handshake_outlined, false),
        ('100 Meals Hero', Icons.emoji_events_outlined, false),
      ],
    'foodbank' => [
        ('First Pickup', Icons.check_circle_outline, true),
        ('100 kg Collected', Icons.scale_outlined, false),
        ('5 Partners', Icons.storefront_outlined, false),
        ('Community Hero', Icons.emoji_events_outlined, false),
      ],
    _ => [
        ('First Meal', Icons.dining_outlined, true),
        ('5 Pickups', Icons.check_circle_outline, false),
        ('Regular Visitor', Icons.repeat_outlined, false),
        ('Community Member', Icons.people_outline, false),
      ],
  };

  return badges.map((b) {
    final (label, icon, unlocked) = b;
    return Container(
      width: 88,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: unlocked ? color.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked ? color.withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 24,
              color: unlocked ? color : const Color(0xFFCBD5E1)),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: unlocked
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }).toList();
}

// ─── Settings row ─────────────────────────────────────────────────────────────

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
            Icon(Icons.chevron_right,
                size: 18, color: const Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
