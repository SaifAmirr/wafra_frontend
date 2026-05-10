import 'package:flutter_test/flutter_test.dart';
import 'package:wafra_frontend/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WafraApp());
  });
}
