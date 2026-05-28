import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/core/network/api_service.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final raw = await ApiService.instance.getRestaurantReservations();
      if (!mounted) return;
      setState(
          () => _reservations = raw.cast<Map<String, dynamic>>());
    } catch (_) {
      // show empty state on error
    } finally {
      if (mounted) setState(() => _loading = false);
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
      await ApiService.instance.acceptReservation(id);
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
      await ApiService.instance.declineReservation(id);
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
      builder: (_) => _RequestDetailsSheet(data: r),
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
              child:
                  CircularProgressIndicator(color: Color(0xFF1A5C38)))
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFF1A5C38),
              child: TabBarView(
                controller: _tabController,
                children: List.generate(4, (i) {
                  final items = _forTab(i);
                  if (items.isEmpty) return const _EmptyRequests();
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, idx) => _RequestCard(
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

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.inbox_outlined,
                size: 40, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 16),
          Text(
            'No requests yet',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your listing is live!',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Request card ─────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const _RequestCard({
    required this.data,
    this.onTap,
    this.onAccept,
    this.onDecline,
  });

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final diff = DateTime.now().difference(DateTime.parse(iso));
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  String _fmtPickup(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final h = dt.hour > 12
          ? dt.hour - 12
          : dt.hour == 0
              ? 12
              : dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      final ap = dt.hour >= 12 ? 'PM' : 'AM';
      return 'Pickup $h:$m $ap';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? 'pending';
    final receiverName = data['receiver_name'] as String? ?? 'Unknown';
    final receiverRole = data['receiver_role'] as String? ?? 'individual';
    final foodName = data['food_name'] as String? ?? '';
    final qty = data['requested_quantity'];

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'accepted':
        statusColor = const Color(0xFF1A5C38);
        statusLabel = 'Confirmed';
        break;
      case 'completed':
        statusColor = const Color(0xFF0EA5E9);
        statusLabel = 'Completed';
        break;
      case 'declined':
      case 'cancelled':
        statusColor = Colors.red;
        statusLabel = status == 'declined' ? 'Declined' : 'Cancelled';
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Pending';
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFF2F2F7),
                  child: Text(
                    receiverName.isNotEmpty
                        ? receiverName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: const Color(0xFF1A5C38),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receiverName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: receiverRole == 'foodbank'
                              ? const Color(0xFFF3E8FF)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          receiverRole == 'foodbank'
                              ? 'Food Bank'
                              : 'Individual',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: receiverRole == 'foodbank'
                                ? const Color(0xFF7C3AED)
                                : const Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 12),
            // Food info row
            Row(
              children: [
                const Icon(Icons.restaurant_outlined,
                    size: 16, color: Color(0xFF8E8E93)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    foodName,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Text(
                  'Qty: $qty',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF1A5C38),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 16, color: Color(0xFF8E8E93)),
                const SizedBox(width: 6),
                Text(
                  _fmtPickup(data['pickup_time'] as String?),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                const Spacer(),
                Text(
                  _timeAgo(data['created_at'] as String?),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
            // Action buttons (pending only)
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Decline',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A5C38),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Accept',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Request details sheet ───────────────────────────────────────────────────

class _RequestDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RequestDetailsSheet({required this.data});

  String _fmtPickup(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso);
      final h = dt.hour > 12
          ? dt.hour - 12
          : dt.hour == 0
              ? 12
              : dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      final ap = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day}/${dt.month}/${dt.year}  ·  $h:$m $ap';
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiverName = data['receiver_name'] as String? ?? 'Unknown';
    final receiverRole = data['receiver_role'] as String? ?? 'individual';
    final receiverPhone = data['receiver_phone'] as String?;
    final foodName = data['food_name'] as String? ?? '';
    final qty = data['requested_quantity'];
    final status = data['status'] as String? ?? 'pending';
    final pickup = _fmtPickup(data['pickup_time'] as String?);
    final created = _fmtPickup(data['created_at'] as String?);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFF2F2F7),
                  child: Text(
                    receiverName.isNotEmpty
                        ? receiverName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: const Color(0xFF1A5C38),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receiverName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: receiverRole == 'foodbank'
                              ? const Color(0xFFF3E8FF)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          receiverRole == 'foodbank'
                              ? 'Food Bank'
                              : 'Individual',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: receiverRole == 'foodbank'
                                ? const Color(0xFF7C3AED)
                                : const Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 14),
            _DetailRow(
              icon: Icons.restaurant_outlined,
              label: 'Food',
              value: '$foodName · Qty $qty',
            ),
            _DetailRow(
              icon: Icons.access_time,
              label: 'Pickup window',
              value: pickup,
            ),
            _DetailRow(
              icon: Icons.event_outlined,
              label: 'Requested',
              value: created,
            ),
            if (receiverPhone != null && receiverPhone.trim().isNotEmpty)
              _DetailRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: receiverPhone,
              ),
            _DetailRow(
              icon: Icons.flag_outlined,
              label: 'Status',
              value: status,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
