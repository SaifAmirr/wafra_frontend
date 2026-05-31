import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/core/errors/app_failure.dart';
import 'package:wafra_frontend/features/listings/data/listings_api_repository.dart';
import 'widgets/reservations/reservation_tab_bar.dart';
import 'widgets/reservations/reservation_card.dart';
import 'widgets/reservations/reservation_empty_state.dart';
import 'pickup_ticket_screen.dart';

class MyReservationsScreen extends StatefulWidget {
  final VoidCallback? onGoExplore;
  const MyReservationsScreen({super.key, this.onGoExplore});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['Pending', 'Confirmed', 'Completed', 'Cancelled'];

  static const _statusMap = {
    'Pending': ['pending'],
    'Confirmed': ['accepted'],
    'Completed': ['completed'],
    'Cancelled': ['declined', 'cancelled'],
  };

  List<Map<String, dynamic>> _reservations = [];
  bool _loading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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
      final raw = await ListingsApiRepository.instance.getMyReservations();
      if (!mounted) return;
      setState(() =>
          _reservations = raw.map((e) => e as Map<String, dynamic>).toList());
      if (!silent) _autoSelectTab();
    } catch (_) {
    } finally {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  void _autoSelectTab() {
    if (_reservations.isEmpty) return;
    final hasConfirmed = _reservations.any((r) => r['status'] == 'accepted');
    if (hasConfirmed && _tabController.index == 0) {
      _tabController.animateTo(1);
    }
  }

  List<Map<String, dynamic>> _forTab(String tab) {
    final statuses = _statusMap[tab] ?? [];
    return _reservations
        .where((r) => statuses.contains(r['status'] as String?))
        .toList();
  }

  Future<void> _cancel(int id) async {
    try {
      await ListingsApiRepository.instance.cancelReservation(id);
      _load();
    } on AppFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.red.shade700),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Could not connect to server.'),
              backgroundColor: Colors.red.shade700),
        );
      }
    }
  }

  void _showCode(int id, Map<String, dynamic> r) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PickupTicketScreen(
          reservationId: id,
          restaurantName:
              r['restaurant_name'] as String? ?? 'Restaurant',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'My Reservations',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ReservationTabBar(controller: _tabController, tabs: _tabs),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF2563EB)))
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: const Color(0xFF2563EB),
                      child: TabBarView(
                        controller: _tabController,
                        children: _tabs.map((tab) {
                          final items = _forTab(tab);
                          if (items.isEmpty) {
                            return ReservationEmptyState(
                              tabLabel: tab,
                              onBrowse: widget.onGoExplore ?? () {},
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final r = items[i];
                              final id = r['reservation_id'] as int?;
                              final status = r['status'] as String? ?? '';
                              return ReservationCard(
                                data: r,
                                onCancel: status == 'pending' && id != null
                                    ? () => _cancel(id)
                                    : null,
                                onShowCode: status == 'accepted' && id != null
                                    ? () => _showCode(id, r)
                                    : null,
                                onFindSimilar: (status == 'declined' ||
                                        status == 'cancelled')
                                    ? (widget.onGoExplore ?? () {})
                                    : null,
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
