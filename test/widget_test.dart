import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airon/main.dart';

void main() {
  testWidgets('App boots and shows login dialog', (WidgetTester tester) async {
    // Build the app.
    await tester.pumpWidget(const MyApp());

    // Let the first frame + postFrameCallback (which triggers the login dialog) run.
    await tester.pump();

    // Verify the app shell rendered.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify the login dialog appeared, as expected on startup.
    expect(find.text('Please login to track flights'), findsOneWidget);
    expect(find.text('UserID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
