import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafra_frontend/features/listings/presentation/post_surplus_food_screen.dart';

class PostSurplusFab extends StatelessWidget {
  final VoidCallback? onPosted;

  const PostSurplusFab({super.key, this.onPosted});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (_) => const PostSurplusFoodScreen()))
          .then((_) => onPosted?.call()),
      backgroundColor: const Color(0xFF1A5C38),
      elevation: 4,
      icon: const Icon(Icons.add, color: Colors.white, size: 20),
      label: Text(
        'Post Surplus Food',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.white,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}
