import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileImpactSection extends StatelessWidget {
  final String role;
  final Color accent;

  const ProfileImpactSection({
    super.key,
    required this.role,
    required this.accent,
  });

  List<_ImpactStat> get _stats {
    switch (role) {
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
    final stats = _stats;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: stats
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
