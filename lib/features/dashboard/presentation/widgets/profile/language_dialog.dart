import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showLanguageDialog(BuildContext context, Color accent) {
  return showDialog(
    context: context,
    builder: (_) => _LanguageDialog(accent: accent),
  );
}

class _LanguageDialog extends StatelessWidget {
  final Color accent;
  const _LanguageDialog({required this.accent});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: accent.withValues(alpha: 0.10),
            child: Icon(Icons.language_rounded, color: accent, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            'Language',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          _LangOption(
            flag: '🇺🇸',
            label: 'English',
            selected: true,
            accent: accent,
          ),
          const SizedBox(height: 8),
          _LangOption(
            flag: '🇸🇦',
            label: 'Arabic',
            selected: false,
            accent: accent,
            comingSoon: true,
          ),
          const SizedBox(height: 8),
          _LangOption(
            flag: '🇫🇷',
            label: 'French',
            selected: false,
            accent: accent,
            comingSoon: true,
          ),
          const SizedBox(height: 8),
          _LangOption(
            flag: '🇪🇸',
            label: 'Spanish',
            selected: false,
            accent: accent,
            comingSoon: true,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: Color(0xFF0284C7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'More language support is coming soon!',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF0369A1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                'Got it',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final bool comingSoon;
  final Color accent;

  const _LangOption({
    required this.flag,
    required this.label,
    required this.selected,
    required this.accent,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? accent.withValues(alpha: 0.06) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? accent.withValues(alpha: 0.30) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: comingSoon
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF0F172A),
              ),
            ),
          ),
          if (comingSoon)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Soon',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            )
          else
            Icon(Icons.check_circle_rounded, color: accent, size: 18),
        ],
      ),
    );
  }
}
