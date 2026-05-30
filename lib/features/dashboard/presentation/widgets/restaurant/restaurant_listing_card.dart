import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/dashboard/domain/listing_model.dart';

class RestaurantListingCard extends StatelessWidget {
  final RestaurantListing listing;

  const RestaurantListingCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final isActive = listing.status == ListingStatus.active;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${listing.name} (${listing.quantity}x)',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    isActive
                        ? Icons.access_time_rounded
                        : Icons.local_shipping_outlined,
                    size: 13,
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    listing.timeDetail,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Listed ${listing.listedAgo}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _StatusBadge(status: listing.status),
            const SizedBox(height: 10),
            if (isActive && listing.reservationCount > 0)
              _ReservationAvatars(count: listing.reservationCount),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ListingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;

    switch (status) {
      case ListingStatus.active:
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF1A5C38);
        label = 'ACTIVE';
        break;
      case ListingStatus.reserved:
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFF59E0B);
        label = 'RESERVED';
        break;
      case ListingStatus.completed:
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF3B82F6);
        label = 'COMPLETED';
        break;
      default:
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFF59E0B);
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.5,
          color: fg,
        ),
      ),
    );
  }
}

class _ReservationAvatars extends StatelessWidget {
  final int count;

  const _ReservationAvatars({required this.count});

  @override
  Widget build(BuildContext context) {
    const avatarSize = 22.0;
    const overlap = 8.0;
    final show = count.clamp(1, 3);
    final totalWidth = avatarSize + (show - 1) * (avatarSize - overlap);

    return SizedBox(
      width: totalWidth,
      height: avatarSize,
      child: Stack(
        children: [
          for (int i = 0; i < show; i++)
            Positioned(
              left: i * (avatarSize - overlap),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(Icons.person,
                    size: 12, color: Color(0xFF94A3B8)),
              ),
            ),
        ],
      ),
    );
  }
}
