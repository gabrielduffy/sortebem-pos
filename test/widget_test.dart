import 'package:flutter_test/flutter_test.dart';
import 'package:sortebem_pos/main.dart';

void main() {
  testWidgets('Splash/Activation screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SortebemApp());
    expect(find.text('Ativação Terminal'), findsOneWidget);
  });
}
