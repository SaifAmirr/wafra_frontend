import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/support/domain/entities/support_ticket.dart';
import '../../data/admin_repository.dart';
import 'admin_colors.dart';
import 'admin_search_bar.dart';
import 'section_header.dart';
import 'ticket_card.dart';

class TicketsTab extends StatefulWidget {
  const TicketsTab({super.key});

  @override
  State<TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<TicketsTab> {
  List<SupportTicket> _tickets = [];
  List<SupportTicket> _filtered = [];
  bool _loading = false;
  bool _showResolved = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filter);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await AdminRepository.instance.getSupportTickets();
      if (!mounted) return;
      _tickets = data;
      _filter();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filter() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _tickets.where((t) {
        final matchesSearch = q.isEmpty ||
            t.username.toLowerCase().contains(q) ||
            t.email.toLowerCase().contains(q) ||
            t.subject.toLowerCase().contains(q);
        final matchesStatus =
            _showResolved ? true : t.isOpen;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _resolve(int ticketId) async {
    try {
      await AdminRepository.instance.resolveTicket(ticketId);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int get _openCount => _tickets.where((t) => t.isOpen).length;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AdminSectionHeader(
            title: 'Support Tickets',
            subtitle: '$_openCount open ticket${_openCount == 1 ? '' : 's'}',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: AdminSearchBar(controller: _searchController),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Open',
                  selected: !_showResolved,
                  onTap: () {
                    setState(() => _showResolved = false);
                    _filter();
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'All',
                  selected: _showResolved,
                  onTap: () {
                    setState(() => _showResolved = true);
                    _filter();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: kAdminGreen),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    color: kAdminGreen,
                    child: _filtered.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 80),
                              Center(
                                child: Text(
                                  _showResolved
                                      ? 'No tickets yet'
                                      : 'No open tickets',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) => TicketCard(
                              ticket: _filtered[i],
                              onResolve: () =>
                                  _resolve(_filtered[i].id),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? kAdminGreen : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: selected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
