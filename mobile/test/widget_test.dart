import 'package:flutter_test/flutter_test.dart';
import 'package:klamo_mobile/main.dart';

void main() {
  testWidgets('Klamo app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KlamoApp());
    expect(find.text('Klamo'), findsWidgets);
  });
}
