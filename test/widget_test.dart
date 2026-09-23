import 'package:flutter_test/flutter_test.dart';

import 'package:cekici_app/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const CekiciApp());
    // Verify the app renders
    expect(find.byType(CekiciApp), findsOneWidget);
  });
}
