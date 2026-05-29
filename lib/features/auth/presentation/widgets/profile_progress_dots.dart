import 'package:flutter/material.dart';

class ProfileProgressDots extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;

  const ProfileProgressDots({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor = const Color(0xFF1A5C38),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (i) {
        final isActive = i == currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? activeColor : const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
