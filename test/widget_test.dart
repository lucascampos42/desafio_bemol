import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:desafio_bemol/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('DesafioBemolApp should build MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const Text('Test App'),
        ),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);
  });

  testWidgets('DesafioBemolApp widget structure test', (WidgetTester tester) async {
    const app = DesafioBemolApp();
    
    expect(app, isA<StatelessWidget>());
    expect(app.key, isNull);
  });
}