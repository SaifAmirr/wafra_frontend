import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:wafra_frontend/features/dashboard/domain/entities/user_stats.dart';
import 'package:wafra_frontend/features/dashboard/providers/dashboard_providers.dart';
import 'widgets/profile/profile_header.dart';
import 'widgets/profile/profile_impact_section.dart';
import 'widgets/profile/profile_badges.dart';
import 'widgets/profile/profile_settings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  UserStats? _stats;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await DashboardRepository.instance.getMe();
      if (!mounted) return;
      final user = data['user'] as Map<String, dynamic>?;
      setState(() => _user = user);

      final role = user?['role'] as String? ?? 'individual';
      final stats =
          await DashboardProviders.getUserStatsUseCase.execute(role);
      if (!mounted) return;
      setState(() => _stats = stats);
    } catch (_) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _accent))
          : RefreshIndicator(
              onRefresh: _load,
              color: _accent,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ProfileHeader(
                      username: _username,
                      email: _email,
                      accent: _accent,
                      roleLabel: _roleLabel,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ProfileImpactSection(
                      role: _role,
                      accent: _accent,
                      stats: _stats,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
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
                        children:
                            profileBadgesForRole(_role, _accent, _stats),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
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
                    child: ProfileSettings(accent: _accent),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
    );
  }
}
