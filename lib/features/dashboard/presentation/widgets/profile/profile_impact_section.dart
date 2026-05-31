import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/dashboard/domain/entities/user_stats.dart';

class ProfileImpactSection extends StatelessWidget {
  final String role;
  final Color accent;
  final UserStats? stats;

  const ProfileImpactSection({
    super.key,
    required this.role,
    required this.accent,
    this.stats,
  });

  List<_ImpactStat> get _statItems {
    switch (role) {
      case 'restaurant':
        return [
          _ImpactStat(
            label: 'Meals Donated',
            value: stats != null ? '${stats!.mealsDonated}' : '—',
            icon: Icons.volunteer_activism_outlined,
          ),
          _ImpactStat(
            label: 'Listings Posted',
            value: stats != null ? '${stats!.listingsPosted}' : '—',
            icon: Icons.post_add_outlined,
          ),
          _ImpactStat(
            label: 'Partners Served',
            value: stats != null ? '${stats!.partnersServed}' : '—',
            icon: Icons.account_balance_outlined,
          ),
        ];
      case 'foodbank':
        return [
          _ImpactStat(
            label: 'Meals Collected',
            value: stats != null ? '${stats!.mealsReceived}' : '—',
            icon: Icons.kitchen_outlined,
          ),
          _ImpactStat(
            label: 'Pickups Done',
            value: stats != null ? '${stats!.pickupsCompleted}' : '—',
            icon: Icons.people_outline,
          ),
          _ImpactStat(
            label: 'Restaurant Partners',
            value: stats != null ? '${stats!.restaurantsVisited}' : '—',
            icon: Icons.storefront_outlined,
          ),
        ];
      default:
        return [
          _ImpactStat(
            label: 'Meals Received',
            value: stats != null ? '${stats!.mealsReceived}' : '—',
            icon: Icons.dining_outlined,
          ),
          _ImpactStat(
            label: 'Pickups Completed',
            value: stats != null ? '${stats!.pickupsCompleted}' : '—',
            icon: Icons.check_circle_outline,
          ),
          _ImpactStat(
            label: 'Restaurants Visited',
            value: stats != null ? '${stats!.restaurantsVisited}' : '—',
            icon: Icons.storefront_outlined,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: _statItems
            .map<Widget>((s) => _ImpactCard(stat: s, color: accent))
            .expand((w) => [w, const SizedBox(width: 10)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class _ImpactStat {
  final String label;
  final String value;
  final IconData icon;
  const _ImpactStat({
    required this.label,
    required this.value,
    required this.icon,
  });
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
