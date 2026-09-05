import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greenstock/main.dart';

void main() {
  testWidgets('Hasad app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HasadApp(),
      ),
    );
    expect(find.byType(HasadApp), findsOneWidget);
  });
}
