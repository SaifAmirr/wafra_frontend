import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/core/constants/app_colors.dart';

class ReservationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onCancel;
  final VoidCallback? onShowCode;
  final VoidCallback? onFindSimilar;

  const ReservationCard({
    super.key,
    required this.data,
    this.onCancel,
    this.onShowCode,
    this.onFindSimilar,
  });

  static const _statusColors = {
    'pending': Color(0xFFF59E0B),
    'accepted': AppColors.individualBlue,
    'completed': AppColors.individualBlue,
    'declined': Color(0xFFEF4444),
    'cancelled': Color(0xFF94A3B8),
  };

  static const _statusLabels = {
    'pending': 'Pending',
    'accepted': 'Confirmed',
    'completed': 'Completed',
    'declined': 'Declined',
    'cancelled': 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? 'pending';
    final color = _statusColors[status] ?? const Color(0xFF94A3B8);
    final label = _statusLabels[status] ?? status;
    final foodName = data['food_name'] as String? ??
        data['listing']?['food_name'] as String? ??
        'Food item';
    final restaurant = data['restaurant_name'] as String? ??
        data['listing']?['restaurant_name'] as String? ??
        'Restaurant';
    final qty = data['requested_quantity'] as int? ?? 1;
    final photoUrl = data['photo_url'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: photoUrl != null
                    ? Image.network(
                        photoUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                            _FallbackThumb(color: color),
                      )
                    : _FallbackThumb(color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$restaurant · $qty item${qty != 1 ? 's' : ''}',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (onCancel != null || onShowCode != null || onFindSimilar != null)
            ...[
            const SizedBox(height: 12),
            _CardActions(
              onCancel: onCancel,
              onShowCode: onShowCode,
              onFindSimilar: onFindSimilar,
            ),
          ],
        ],
      ),
    );
  }
}

class _FallbackThumb extends StatelessWidget {
  final Color color;
  const _FallbackThumb({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      color: color.withValues(alpha: 0.1),
      child: Icon(Icons.shopping_bag_outlined, color: color, size: 22),
    );
  }
}

class _CardActions extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onShowCode;
  final VoidCallback? onFindSimilar;

  const _CardActions({this.onCancel, this.onShowCode, this.onFindSimilar});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (onCancel != null) {
      children.add(Expanded(
        child: OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade700,
            side: BorderSide(color: Colors.red.shade300),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text('Cancel',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ));
    }

    if (onShowCode != null) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 10));
      children.add(Expanded(
        child: ElevatedButton.icon(
          onPressed: onShowCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.individualBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          icon: const Icon(Icons.qr_code_2_rounded, size: 16),
          label: Text('Show Code',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ));
    }

    if (onFindSimilar != null) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 10));
      children.add(Expanded(
        child: TextButton.icon(
          onPressed: onFindSimilar,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.individualBlue,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          icon: const Icon(Icons.search, size: 16),
          label: Text('Find similar listings',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ));
    }

    return Row(children: children);
  }
}
