import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/admin_repository.dart';
import 'admin_colors.dart';
import 'section_header.dart';
import 'listing_card.dart';

class ListingsTab extends StatefulWidget {
  const ListingsTab({super.key});

  @override
  State<ListingsTab> createState() => _ListingsTabState();
}

class _ListingsTabState extends State<ListingsTab> {
  List<Map<String, dynamic>> _listings = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final raw = await AdminRepository.instance.getListings();
      if (!mounted) return;
      setState(() =>
          _listings = raw.map((e) => e as Map<String, dynamic>).toList());
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(int listingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Listing',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('This listing will be permanently removed.',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
                Text('Delete', style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await AdminRepository.instance.deleteListing(listingId);
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
            title: 'Listings',
            subtitle: '${_listings.length} total',
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: kAdminGreen))
                : RefreshIndicator(
                    onRefresh: _load,
                    color: kAdminGreen,
                    child: _listings.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 80),
                              Center(
                                child: Text(
                                  'No listings yet',
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
                            itemCount: _listings.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) => ListingCard(
                              listing: _listings[i],
                              onDelete: () => _delete(
                                  _listings[i]['listing_id'] as int),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
