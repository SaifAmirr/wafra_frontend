import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/services/api_service.dart';

class PickupTicketScreen extends StatefulWidget {
  final int reservationId;
  final String restaurantName;
  final String restaurantAddress;

  const PickupTicketScreen({
    super.key,
    required this.reservationId,
    this.restaurantName = 'Restaurant',
    this.restaurantAddress = '',
  });

  @override
  State<PickupTicketScreen> createState() => _PickupTicketScreenState();
}

class _PickupTicketScreenState extends State<PickupTicketScreen> {
  String? _pickupCode;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    try {
      final result = await ApiService.instance.generatePickup(widget.reservationId);
      if (!mounted) return;
      setState(() {
        _pickupCode = result['code'] as String?;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Could not generate pickup code.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xCC0F172A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : _error != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Go Back',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      )
                    : _TicketCard(
                        pickupCode: _pickupCode ?? '----',
                        restaurantName: widget.restaurantName,
                        restaurantAddress: widget.restaurantAddress,
                      ),
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final String pickupCode;
  final String restaurantName;
  final String restaurantAddress;

  const _TicketCard({
    required this.pickupCode,
    required this.restaurantName,
    required this.restaurantAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),

          // Title
          Text(
            'Pick-up Ticket',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Show this to the restaurant staff',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),

          // QR code
          Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const _QrCodePlaceholder(),
          ),

          const SizedBox(height: 20),

          // Pickup code label
          Text(
            'PICKUP CODE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pickupCode,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 6,
              color: const Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 16),

          // Restaurant info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF1A5C38), size: 20),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      restaurantAddress,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Get Directions button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.navigation_rounded, size: 18),
                label: Text(
                  'Get Directions',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── QR Code Placeholder ──────────────────────────────────────────────────────

class _QrCodePlaceholder extends StatelessWidget {
  const _QrCodePlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: _QrPainter(),
    );
  }
}

class _QrPainter extends CustomPainter {
  // Simplified 21×21 QR-style grid with proper finder patterns in 3 corners
  static const _grid = [
    [1,1,1,1,1,1,1,0,1,0,1,0,0,0,1,1,1,1,1,1,1],
    [1,0,0,0,0,0,1,0,0,1,0,1,0,0,1,0,0,0,0,0,1],
    [1,0,1,1,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,0,1],
    [1,0,1,1,1,0,1,0,0,1,0,0,0,0,1,0,1,1,1,0,1],
    [1,0,1,1,1,0,1,0,1,1,1,0,1,0,1,0,1,1,1,0,1],
    [1,0,0,0,0,0,1,0,0,0,0,1,0,0,1,0,0,0,0,0,1],
    [1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1],
    [0,0,0,0,0,0,0,0,1,1,0,1,0,1,0,0,0,0,0,0,0],
    [1,0,1,0,1,1,0,1,0,1,1,0,1,1,0,1,0,1,1,0,1],
    [0,1,0,1,0,0,1,0,1,0,0,1,0,0,1,0,1,0,0,1,0],
    [1,0,1,1,0,1,0,0,0,1,1,0,1,0,0,1,0,1,1,0,0],
    [0,1,0,0,1,0,0,1,1,0,0,1,0,1,1,0,1,0,0,1,1],
    [1,0,0,1,0,1,1,0,1,1,0,0,1,0,0,1,0,0,1,0,0],
    [0,0,0,0,0,0,0,0,1,0,1,1,0,0,1,0,1,1,0,1,0],
    [1,1,1,1,1,1,1,0,0,1,0,0,1,0,1,1,0,0,1,0,1],
    [1,0,0,0,0,0,1,0,1,0,1,0,0,1,0,0,1,0,0,1,0],
    [1,0,1,1,1,0,1,1,0,1,0,1,0,0,1,1,0,1,0,1,1],
    [1,0,1,1,1,0,1,0,1,0,0,0,1,0,0,0,1,0,1,0,0],
    [1,0,1,1,1,0,1,0,0,1,1,1,0,1,1,0,0,1,0,1,1],
    [1,0,0,0,0,0,1,0,1,0,0,0,1,0,0,1,0,0,1,0,0],
    [1,1,1,1,1,1,1,0,0,1,1,0,0,1,1,0,1,1,0,1,1],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final cell = size.width / _grid.length;

    for (int row = 0; row < _grid.length; row++) {
      for (int col = 0; col < _grid[row].length; col++) {
        if (_grid[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(col * cell, row * cell, cell, cell),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
