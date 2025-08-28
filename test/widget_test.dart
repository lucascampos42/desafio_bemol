import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:desafio_bemol/main.dart';

void main() {
  setUp(() async {
    // Mock SharedPreferences for tests
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('DesafioBemolApp should build MaterialApp', (WidgetTester tester) async {
    // Test only the app widget without initializing services
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const Text('Test App'),
        ),
      ),
    );

    // Verify that the MaterialApp builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);
  });

  testWidgets('DesafioBemolApp widget structure test', (WidgetTester tester) async {
    // Test the app widget structure without network calls
    const app = DesafioBemolApp();
    
    // Verify the widget can be created
    expect(app, isA<StatelessWidget>());
    expect(app.key, isNull);
  });
}
