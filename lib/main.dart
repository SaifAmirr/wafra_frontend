import 'package:flutter/material.dart';
import 'package:wafra_frontend/core/network/api_service.dart';
import 'package:wafra_frontend/features/onboarding/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(const WafraApp());
}

class WafraApp extends StatelessWidget {
  const WafraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wafra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A5C38)),
      ),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        // Cap system font scaling at 1.3 so large accessibility or Samsung
        // display-size settings don't overflow fixed-height layouts.
        final safeMq = mq.copyWith(
          textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3),
        );
        // On real phones (≤ 430dp wide) use the full screen — no container.
        // On web/desktop/tablets apply a centered 430dp phone shell.
        if (mq.size.width <= 430) {
          return MediaQuery(data: safeMq, child: child!);
        }
        return Center(
          child: SizedBox(
            width: 430,
            child: MediaQuery(
              data: safeMq.copyWith(size: Size(430, mq.size.height)),
              child: ClipRect(child: child!),
            ),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
