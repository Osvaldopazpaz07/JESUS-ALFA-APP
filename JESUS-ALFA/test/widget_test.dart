// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:jesus_calculator_ct/main.dart' as app;

void main() {
  testWidgets('Calculator smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const app.ScientificCalculatorApp(isFirstLaunch: false));

    // The app shows a splash screen for 4 seconds.
    // We need to pump the widget tree for the duration of the splash screen to navigate to the calculator.
    await tester.pump(const Duration(seconds: 5));

    // Verify that our calculator starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '1' button and trigger a frame.
    await tester.tap(find.text('1'));
    await tester.pump();

    // Tap the '+' button and trigger a frame.
    await tester.tap(find.text('+'));
    await tester.pump();

    // Tap the '2' button and trigger a frame.
    await tester.tap(find.text('2'));
    await tester.pump();

    // Tap the '=' button and trigger a frame.
    await tester.tap(find.text('='));
    await tester.pump();

    // Verify that the result is '3'.
    expect(find.text('3'), findsOneWidget);
  });
}
