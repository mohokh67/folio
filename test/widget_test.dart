import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/app.dart';

void main() {
  testWidgets('app smoke test — renders without crashing', (WidgetTester tester) async {
    // runAsync allows the real SQLite connection timer to complete
    await tester.runAsync(() async {
      await tester.pumpWidget(const ProviderScope(child: App()));
      await tester.pump();
    });
    expect(tester.takeException(), isNull);
  });
}
