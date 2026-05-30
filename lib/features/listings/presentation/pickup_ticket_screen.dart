import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wafra_frontend/core/network/api_service.dart';
import '../data/listings_api_repository.dart';

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
  String? _qrData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    try {
      final result =
          await ListingsApiRepository.instance.generatePickup(widget.reservationId);
      if (!mounted) return;
      final pickup = result['pickup'] as Map<String, dynamic>;
      final qrPayload = pickup['qr_payload'] as Map<String, dynamic>;
      setState(() {
        _pickupCode = pickup['code'] as String?;
        _qrData = jsonEncode(qrPayload);
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not generate pickup code.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xCC0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _error != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
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
                        pickupCode: _pickupCode ?? '------',
                        qrData: _qrData!,
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
  final String qrData;
  final String restaurantName;
  final String restaurantAddress;

  const _TicketCard({
    required this.pickupCode,
    required this.qrData,
    required this.restaurantName,
    required this.restaurantAddress,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Available card width = screenWidth - 48px (24px padding each side)
    final cardInner = screenWidth - 48;
    final qrSize = (cardInner * 0.55).clamp(140.0, 180.0);
    final codeFontSize = (screenWidth * 0.07).clamp(20.0, 28.0);

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
          const SizedBox(height: 20),

          // QR code
          Container(
            width: qrSize,
            height: qrSize,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: qrSize - 20,
              backgroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

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
              fontSize: codeFontSize,
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
                const Icon(Icons.location_on,
                    color: Color(0xFF1A5C38), size: 20),
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
