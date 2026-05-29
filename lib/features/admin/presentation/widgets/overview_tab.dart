import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/admin_repository.dart';
import 'admin_colors.dart';
import 'logout_button.dart';
import 'stat_card.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  Map<String, dynamic>? _stats;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await AdminRepository.instance.getStats();
      if (!mounted) return;
      setState(() => _stats = data['stats'] as Map<String, dynamic>?);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _int(String key) =>
      int.tryParse(_stats?[key]?.toString() ?? '0') ?? 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        color: kAdminGreen,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            if (_loading)
              const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: kAdminGreen)),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      label: 'Total Users',
                      value: _int('total_users'),
                      icon: Icons.people_outline,
                      color: kAdminGreen,
                    ),
                    StatCard(
                      label: 'Restaurants',
                      value: _int('restaurants'),
                      icon: Icons.storefront_outlined,
                      color: const Color(0xFF0EA5E9),
                    ),
                    StatCard(
                      label: 'Food Banks',
                      value: _int('food_banks'),
                      icon: Icons.volunteer_activism_outlined,
                      color: const Color(0xFF7C3AED),
                    ),
                    StatCard(
                      label: 'Individuals',
                      value: _int('individuals'),
                      icon: Icons.person_outline,
                      color: const Color(0xFF1D4ED8),
                    ),
                    StatCard(
                      label: 'Active Listings',
                      value: _int('total_listings'),
                      icon: Icons.post_add_outlined,
                      color: const Color(0xFFF59E0B),
                    ),
                    StatCard(
                      label: 'Reservations',
                      value: _int('total_reservations'),
                      icon: Icons.bookmark_outline,
                      color: const Color(0xFFEF4444),
                    ),
                  ],
                ),
              ),
              if (_int('pending_verification') > 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFCD34D)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFD97706), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${_int('pending_verification')} user(s) awaiting verification',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      color: Colors.white,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Panel',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Wafra management dashboard',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
          const Spacer(),
          const LogoutButton(),
        ],
      ),
    );
  }
}
