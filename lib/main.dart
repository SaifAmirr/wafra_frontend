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
      // Constrain to phone width on web/desktop and update MediaQuery so
      // all children see ~430px width rather than the full browser width.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final w = mq.size.width.clamp(0.0, 430.0);
        return Center(
          child: SizedBox(
            width: w,
            child: MediaQuery(
              data: mq.copyWith(size: Size(w, mq.size.height)),
              child: ClipRect(child: child!),
            ),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
