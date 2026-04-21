import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pcgen/src/app.dart';

void main() {
  testWidgets('PCGen app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PCGenApp());
    // App starts with the preloader
    expect(find.text('PCGen'), findsWidgets);
  });
}
