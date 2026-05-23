import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/screens/post_success_screen.dart';
import 'package:wafra_frontend/services/api_service.dart';

class PostSurplusFoodScreen extends StatefulWidget {
  const PostSurplusFoodScreen({super.key});

  @override
  State<PostSurplusFoodScreen> createState() => _PostSurplusFoodScreenState();
}

class _PostSurplusFoodScreenState extends State<PostSurplusFoodScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _selectedCategory = 0;
  final _categories = ['Cooked Meals', 'Bakery', 'Produce', 'Dairy', 'Beverages'];

  final _dietaryOptions = ['Vegan', 'Gluten-Free', 'Halal', 'Nut-Free', 'Dairy-Free'];
  final Set<String> _selectedDietary = {};

  String _selectedUnit = 'portions';
  final _units = ['portions', 'kg', 'items', 'boxes', 'plates'];

  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      initialTime: TimeOfDay.now(),
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

  Future<void> _publish() async {
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
    setState(() => _loading = true);
    try {
      await ApiService.instance.createListing(
        foodName: name,
        category: _categories[_selectedCategory],
        quantity: int.parse(qtyStr),
        pickupTime: pickupDt.toIso8601String(),
        location: 'Grand Avenue 124, NY',
        dietaryTags: _selectedDietary.toList(),
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PostSuccessScreen()),
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Could not connect to server.');
    } finally {
      if (mounted) setState(() => _loading = false);
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
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF0F172A),
            size: 20,
          ),
        ),
        title: Text(
          'Post Surplus Food',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Photo upload ───────────────────────────────────────────
                  GestureDetector(
                    onTap: () {}, // TODO: open image picker
                    child: CustomPaint(
                      painter: _DashedBorderPainter(),
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A5C38),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Add Photo',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Support JPG, PNG up to 5MB',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Food Name ──────────────────────────────────────────────
                  _SectionLabel('Food Name'),
                  _textField(
                    controller: _nameController,
                    hint: 'e.g. Fresh Garden Salad',
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 20),

                  // ── Category ───────────────────────────────────────────────
                  _SectionLabel('Category'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_categories.length, (i) {
                        final active = i == _selectedCategory;
                        return Padding(
                          padding: EdgeInsets.only(
                            right: i < _categories.length - 1 ? 8 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
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

                  // ── Quantity + Unit ────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel('Quantity'),
                            _textField(
                              controller: _quantityController,
                              hint: '5',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel('Unit'),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedUnit,
                              items: _units
                                  .map(
                                    (u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(
                                        u,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedUnit = v!),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: const Color(0xFF0F172A),
                              ),
                              decoration: _inputDecoration(null),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF64748B),
                              ),
                              dropdownColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Dietary Tags ───────────────────────────────────────────
                  _SectionLabel('Dietary Tags'),
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
                            horizontal: 14,
                            vertical: 8,
                          ),
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
                                const Icon(
                                  Icons.check,
                                  size: 13,
                                  color: Color(0xFF1A5C38),
                                ),
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

                  // ── Pickup Availability ────────────────────────────────────
                  _SectionLabel('Pickup Availability'),
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

                  // ── Location ───────────────────────────────────────────────
                  Row(
                    children: [
                      Text(
                        'Location',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Change',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: const Color(0xFF1A5C38),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF1A5C38),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Grand Avenue 124, NY',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Description ────────────────────────────────────────────
                  _SectionLabel('Description'),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: _inputDecoration(
                      'Describe the food, packaging, or special instructions...',
                    ).copyWith(
                      contentPadding: const EdgeInsets.all(16),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Publish button (fixed) ─────────────────────────────────────────
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
                onPressed: _loading ? null : _publish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5C38),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Publish Listing',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF0F172A)),
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: hint != null && hint.length > 30 ? 13 : 15,
        color: const Color(0xFFCBD5E1),
      ),
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
                color: hasValue
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFCBD5E1),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }
}

// ─── Dashed border painter ────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A5C38).withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dash = 6.0;
    const gap = 4.0;
    const radius = 12.0;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(radius),
      ));

    final dashed = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashed.addPath(
          metric.extractPath(distance, distance + dash),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
