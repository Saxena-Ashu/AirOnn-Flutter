import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airon/main.dart';

void main() {
  testWidgets('Login dialog appears on startup', (WidgetTester tester) async {
    // Test LoginFlowWrapper directly, without FlightBloc/FlightRepository/network.
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginFlowWrapper(child: Scaffold(body: Text('Placeholder'))),
      ),
    );

    // Let the first frame + postFrameCallback (which triggers the login dialog) run.
    await tester.pump();

    // Verify the login dialog appeared, as expected on startup.
    expect(find.text('Please login to track flights'), findsOneWidget);
    expect(find.text('UserID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
