import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/admin_repository.dart';
import 'admin_colors.dart';
import 'section_header.dart';
import 'admin_search_bar.dart';
import 'user_card.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = false;
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
      final raw = await AdminRepository.instance.getUsers();
      if (!mounted) return;
      _users = raw.map((e) => e as Map<String, dynamic>).toList();
      _filter();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filter() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _users
          : _users
              .where((u) =>
                  (u['username'] as String? ?? '').toLowerCase().contains(q) ||
                  (u['email'] as String? ?? '').toLowerCase().contains(q))
              .toList();
    });
  }

  Future<void> _approve(int userId) async {
    try {
      await AdminRepository.instance.approveUser(userId);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _reject(int userId) async {
    try {
      await AdminRepository.instance.rejectUser(userId);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AdminSectionHeader(
            title: 'Users',
            subtitle: '${_users.length} total',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: AdminSearchBar(controller: _searchController),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: kAdminGreen))
                : RefreshIndicator(
                    onRefresh: _load,
                    color: kAdminGreen,
                    child: _filtered.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 80),
                              Center(
                                child: Text(
                                  'No users found',
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
                            itemBuilder: (_, i) => UserCard(
                              user: _filtered[i],
                              onApprove: () => _approve(
                                  _filtered[i]['user_id'] as int),
                              onReject: () =>
                                  _reject(_filtered[i]['user_id'] as int),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
