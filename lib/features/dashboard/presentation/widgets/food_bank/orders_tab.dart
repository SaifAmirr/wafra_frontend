import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/core/network/api_service.dart';
import 'package:wafra_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:wafra_frontend/features/listings/presentation/pickup_ticket_screen.dart';
import 'food_bank_order_card.dart';

const _kPurple = Color(0xFF7C3AED);

class OrdersTab extends StatefulWidget {
  final VoidCallback? onGoBrowse;

  const OrdersTab({super.key, this.onGoBrowse});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;
  List<Map<String, dynamic>> _reservations = [];
  bool _loading = false;

  static const _statusMap = {
    0: ['pending'],
    1: ['accepted'],
    2: ['completed'],
    3: ['declined', 'cancelled'],
  };

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final raw = await DashboardRepository.instance.getMyReservations();
      if (!mounted) return;
      setState(() =>
          _reservations = raw.cast<Map<String, dynamic>>());
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel(int id) async {
    try {
      await DashboardRepository.instance.cancelReservation(id);
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

  List<Map<String, dynamic>> _forTab(int i) {
    final statuses = _statusMap[i] ?? [];
    return _reservations
        .where((r) => statuses.contains(r['status'] as String?))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Orders',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: const Color(0xFF0F172A),
          ),
        ),
        bottom: TabBar(
          controller: _tc,
          labelColor: _kPurple,
          unselectedLabelColor: const Color(0xFF8E8E93),
          indicatorColor: _kPurple,
          labelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 13),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _kPurple))
          : RefreshIndicator(
              onRefresh: _load,
              color: _kPurple,
              child: TabBarView(
                controller: _tc,
                children: List.generate(4, (i) {
                  final items = _forTab(i);
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No orders here yet.',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF8E8E93)),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, idx) {
                      final s = items[idx]['status'] as String? ?? '';
                      return FoodBankOrderCard(
                        data: items[idx],
                        onCancel: s == 'pending'
                            ? () => _cancel(
                                items[idx]['reservation_id'] as int)
                            : null,
                        onShowCode: s == 'accepted'
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PickupTicketScreen(
                                      reservationId: items[idx]
                                          ['reservation_id'] as int,
                                    ),
                                  ),
                                )
                            : null,
                        onFindAlternatives:
                            (s == 'declined' || s == 'cancelled')
                                ? widget.onGoBrowse
                                : null,
                      );
                    },
                  );
                }),
              ),
            ),
    );
  }
}
