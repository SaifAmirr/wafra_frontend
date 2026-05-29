import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/core/network/api_service.dart';
import 'package:wafra_frontend/features/dashboard/domain/listing_model.dart';
import 'package:wafra_frontend/features/listings/data/listings_api_repository.dart';
import 'widgets/post_surplus/section_label.dart';

class EditListingScreen extends StatefulWidget {
  final RestaurantListing listing;

  const EditListingScreen({super.key, required this.listing});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();

  final _categories = [
    'Cooked Meals',
    'Bakery',
    'Produce',
    'Dairy',
    'Beverages',
  ];

  final _dietaryOptions = [
    'Vegan',
    'Gluten-Free',
    'Halal',
    'Nut-Free',
    'Dairy-Free',
  ];

  late int _selectedCategory;
  late Set<String> _selectedDietary;
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.listing.name;
    _quantityController.text = widget.listing.quantity.toString();

    final catIndex = _categories.indexWhere(
      (c) => c.toLowerCase() == widget.listing.category.toLowerCase(),
    );
    _selectedCategory = catIndex >= 0 ? catIndex : 0;

    _selectedDietary = widget.listing.dietaryTags.toSet();

    if (widget.listing.pickupTime != null) {
      final local = widget.listing.pickupTime!.toLocal();
      _pickupDate = DateTime(local.year, local.month, local.day);
      _pickupTime = TimeOfDay(hour: local.hour, minute: local.minute);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A5C38),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _pickupDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickupTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A5C38),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _pickupTime = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final qtyStr = _quantityController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter a food name.');
      return;
    }
    if (qtyStr.isEmpty || int.tryParse(qtyStr) == null) {
      _showError('Please enter a valid quantity.');
      return;
    }
    if (_pickupDate == null || _pickupTime == null) {
      _showError('Please select a pickup date and time.');
      return;
    }
    final pickupDt = DateTime(
      _pickupDate!.year,
      _pickupDate!.month,
      _pickupDate!.day,
      _pickupTime!.hour,
      _pickupTime!.minute,
    );

    setState(() => _saving = true);
    try {
      await ListingsApiRepository.instance.updateListing(
        widget.listing.listingId,
        foodName: name,
        category: _categories[_selectedCategory],
        quantity: int.parse(qtyStr),
        pickupTime: pickupDt.toIso8601String(),
        location: widget.listing.location,
        dietaryTags: _selectedDietary.toList(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing updated successfully.'),
          backgroundColor: Color(0xFF1A5C38),
        ),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Could not connect to server.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete Listing',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.listing.name}"? This cannot be undone.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: const Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete',
                style: GoogleFonts.inter(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ListingsApiRepository.instance.deleteListing(widget.listing.listingId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Could not connect to server.');
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  String get _dateDisplay {
    if (_pickupDate == null) return 'Select date';
    return '${_pickupDate!.day.toString().padLeft(2, '0')} / '
        '${_pickupDate!.month.toString().padLeft(2, '0')} / '
        '${_pickupDate!.year}';
  }

  String get _timeDisplay {
    if (_pickupTime == null) return 'Select time';
    final h = _pickupTime!.hour.toString().padLeft(2, '0');
    final m = _pickupTime!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF0F172A), size: 20),
        ),
        title: Text(
          'Edit Listing',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: [
          _deleting
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.red),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _confirmDelete,
                ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Food Name'),
                  _textField(
                    controller: _nameController,
                    hint: 'e.g. Fresh Garden Salad',
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('Category'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_categories.length, (i) {
                        final active = i == _selectedCategory;
                        return Padding(
                          padding: EdgeInsets.only(
                              right: i < _categories.length - 1 ? 8 : 0),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 9),
                              decoration: BoxDecoration(
                                color: active
                                    ? const Color(0xFF1A5C38)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: active
                                      ? const Color(0xFF1A5C38)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Text(
                                _categories[i],
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: active
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('Quantity'),
                  _textField(
                    controller: _quantityController,
                    hint: '5',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('Dietary Tags'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _dietaryOptions.map((tag) {
                      final selected = _selectedDietary.contains(tag);
                      return GestureDetector(
                        onTap: () => setState(() => selected
                            ? _selectedDietary.remove(tag)
                            : _selectedDietary.add(tag)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFECFDF5)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF1A5C38)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (selected) ...[
                                const Icon(Icons.check,
                                    size: 13, color: Color(0xFF1A5C38)),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                tag,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: selected
                                      ? const Color(0xFF1A5C38)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('Pickup Availability'),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: _pickerField(
                            icon: Icons.calendar_today_outlined,
                            label: _dateDisplay,
                            hasValue: _pickupDate != null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickTime,
                          child: _pickerField(
                            icon: Icons.access_time_rounded,
                            label: _timeDisplay,
                            hasValue: _pickupTime != null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('Pickup Location'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 18, color: Color(0xFF1A5C38)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.listing.location.isNotEmpty
                                ? widget.listing.location
                                : 'No location set.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: widget.listing.location.isNotEmpty
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5C38),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        'Save Changes',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, fontSize: 18),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 15, color: const Color(0xFFCBD5E1)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A5C38), width: 1.5),
        ),
      ),
    );
  }

  Widget _pickerField({
    required IconData icon,
    required String label,
    required bool hasValue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color:
                    hasValue ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
