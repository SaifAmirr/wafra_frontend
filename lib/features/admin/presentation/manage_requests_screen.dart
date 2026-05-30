import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/core/network/api_service.dart';
import 'package:wafra_frontend/features/listings/presentation/pickup_scan_screen.dart';
import '../data/admin_repository.dart';
import 'widgets/empty_requests.dart';
import 'widgets/request_card.dart';
import 'widgets/request_details_sheet.dart';

class ManageRequestsScreen extends StatefulWidget {
  const ManageRequestsScreen({super.key});

  @override
  State<ManageRequestsScreen> createState() => _ManageRequestsScreenState();
}

class _ManageRequestsScreenState extends State<ManageRequestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Map<String, dynamic>> _reservations = [];
  bool _loading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
    _timer = Timer.periodic(
        const Duration(seconds: 15), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final raw = await AdminRepository.instance.getReservations();
      if (!mounted) return;
      setState(() => _reservations = raw.cast<Map<String, dynamic>>());
    } catch (_) {
    } finally {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _forTab(int tab) {
    return _reservations.where((r) {
      final s = r['status'] as String? ?? '';
      switch (tab) {
        case 0:
          return true;
        case 1:
          return s == 'pending';
        case 2:
          return s == 'accepted';
        case 3:
          return s == 'completed';
        default:
          return false;
      }
    }).toList();
  }

  Future<void> _accept(int id) async {
    try {
      await AdminRepository.instance.acceptReservation(id);
      _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  Future<void> _decline(int id) async {
    try {
      await AdminRepository.instance.declineReservation(id);
      _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  void _showDetails(BuildContext context, Map<String, dynamic> r) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RequestDetailsSheet(data: r),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        _reservations.where((r) => r['status'] == 'pending').length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner,
                color: Color(0xFF1A5C38)),
            tooltip: 'Scan Pickup QR',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const PickupScanScreen()),
            ),
          ),
        ],
        title: Row(
          children: [
            Text(
              'Pickup Requests',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: const Color(0xFF0F172A),
              ),
            ),
            if (pendingCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5C38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pendingCount',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: const Color(0xFF1A5C38),
          unselectedLabelColor: const Color(0xFF8E8E93),
          indicatorColor: const Color(0xFF1A5C38),
          labelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A5C38)))
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFF1A5C38),
              child: TabBarView(
                controller: _tabController,
                children: List.generate(4, (i) {
                  final items = _forTab(i);
                  if (items.isEmpty) return const EmptyRequests();
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, idx) => RequestCard(
                      data: items[idx],
                      onTap: () => _showDetails(context, items[idx]),
                      onAccept: items[idx]['status'] == 'pending'
                          ? () => _accept(
                              items[idx]['reservation_id'] as int)
                          : null,
                      onDecline: items[idx]['status'] == 'pending'
                          ? () => _decline(
                              items[idx]['reservation_id'] as int)
                          : null,
                    ),
                  );
                }),
              ),
            ),
    );
  }
}
