import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showTermsOfService(BuildContext context, Color accent) {
  return _showLegalSheet(
    context,
    accent: accent,
    title: 'Terms of Service',
    icon: Icons.article_outlined,
    lastUpdated: 'May 2025',
    sections: _tosSections,
  );
}

Future<void> showPrivacyPolicy(BuildContext context, Color accent) {
  return _showLegalSheet(
    context,
    accent: accent,
    title: 'Privacy Policy',
    icon: Icons.privacy_tip_outlined,
    lastUpdated: 'May 2025',
    sections: _privacySections,
  );
}

Future<void> _showLegalSheet(
  BuildContext context, {
  required Color accent,
  required String title,
  required IconData icon,
  required String lastUpdated,
  required List<_LegalSection> sections,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LegalSheet(
      accent: accent,
      title: title,
      icon: icon,
      lastUpdated: lastUpdated,
      sections: sections,
    ),
  );
}

class _LegalSheet extends StatelessWidget {
  final Color accent;
  final String title;
  final IconData icon;
  final String lastUpdated;
  final List<_LegalSection> sections;

  const _LegalSheet({
    required this.accent,
    required this.title,
    required this.icon,
    required this.lastUpdated,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                itemCount: sections.length,
                itemBuilder: (_, i) => _buildSection(sections[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 16, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: accent.withValues(alpha: 0.10),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Last updated: $lastUpdated',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(_LegalSection section) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            section.body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSection {
  final String heading;
  final String body;
  const _LegalSection(this.heading, this.body);
}

// ─── Terms of Service content ────────────────────────────────────────────────

const _tosSections = [
  _LegalSection(
    '1. Acceptance of Terms',
    'By creating an account or using the Wafra application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our platform.',
  ),
  _LegalSection(
    '2. About Wafra',
    'Wafra is a food surplus sharing platform that connects restaurants and food donors with individuals and food banks. Our mission is to reduce food waste and support communities by making it easy to share surplus food rather than discard it.',
  ),
  _LegalSection(
    '3. User Accounts',
    'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You must provide accurate and complete information when registering. Wafra reserves the right to suspend or terminate accounts that violate these terms.',
  ),
  _LegalSection(
    '4. Food Listings (Restaurants & Donors)',
    'Restaurants and food donors are solely responsible for the accuracy, safety, and legality of any food they list on Wafra. Listed food must be safe for consumption and must comply with all applicable local food safety regulations. Do not list expired, contaminated, or otherwise unsafe food.',
  ),
  _LegalSection(
    '5. Reservations & Pickups',
    'When you reserve a food listing, you commit to picking it up at the designated time and location. Repeated no-shows may result in account restrictions. Wafra is not responsible for any disputes between donors and recipients regarding food quality or availability.',
  ),
  _LegalSection(
    '6. Limitation of Liability',
    'Wafra acts as a platform connecting food donors and recipients. We do not guarantee the quality, safety, or availability of any food listed. Wafra shall not be held liable for any illness, injury, or damages arising from food shared through the platform. Use the platform at your own discretion.',
  ),
  _LegalSection(
    '7. Prohibited Conduct',
    'You may not use Wafra for any unlawful purpose, to post false or misleading information, to harass other users, or to attempt to gain unauthorized access to our systems. Commercial resale of food obtained through Wafra is strictly prohibited.',
  ),
  _LegalSection(
    '8. Changes to Terms',
    'Wafra reserves the right to modify these Terms of Service at any time. We will notify users of significant changes through the app. Your continued use of the platform after any changes constitutes acceptance of the updated terms.',
  ),
  _LegalSection(
    '9. Contact',
    'If you have questions about these Terms of Service, please contact us through the Help & Support section in your profile settings.',
  ),
];

// ─── Privacy Policy content ──────────────────────────────────────────────────

const _privacySections = [
  _LegalSection(
    '1. Introduction',
    'Wafra ("we", "our", or "us") is committed to protecting your personal information. This Privacy Policy explains what data we collect, how we use it, and your rights regarding your information when you use our food surplus sharing platform.',
  ),
  _LegalSection(
    '2. Information We Collect',
    'We collect information you provide directly, including your name, email address, phone number, and role (restaurant, food bank, or individual). For restaurants and food banks, we also collect organization details such as business name, address, and license numbers.',
  ),
  _LegalSection(
    '3. How We Use Your Information',
    'We use your information to operate the Wafra platform — including creating and managing your account, facilitating food listings and reservations, sending notifications about reservation status and pickups, and verifying accounts to maintain a trusted community.',
  ),
  _LegalSection(
    '4. Location Data',
    'Food listing addresses and pickup locations are visible to other approved users on the platform to facilitate food sharing. We do not collect or track your real-time device location without your explicit consent.',
  ),
  _LegalSection(
    '5. Data Sharing',
    'We do not sell your personal data to third parties. We may share limited information with other users on the platform as necessary for the service (e.g., a donor seeing a recipient\'s username when a reservation is made). We may share data with service providers who help us operate the platform, under strict confidentiality obligations.',
  ),
  _LegalSection(
    '6. Data Security',
    'We implement industry-standard security measures to protect your personal information, including encrypted passwords and secure HTTPS connections. However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.',
  ),
  _LegalSection(
    '7. Data Retention',
    'We retain your account information for as long as your account is active or as needed to provide services. You may request deletion of your account and associated data by contacting us through the Help & Support section.',
  ),
  _LegalSection(
    '8. Your Rights',
    'You have the right to access, correct, or delete your personal information. You may also opt out of non-essential communications at any time through your Notification Preferences in the app settings.',
  ),
  _LegalSection(
    '9. Changes to This Policy',
    'We may update this Privacy Policy periodically. We will notify you of significant changes through the app. Your continued use of Wafra after any changes constitutes acceptance of the updated policy.',
  ),
  _LegalSection(
    '10. Contact Us',
    'If you have any questions or concerns about this Privacy Policy or how we handle your data, please reach out via the Help & Support section in your profile settings.',
  ),
];
