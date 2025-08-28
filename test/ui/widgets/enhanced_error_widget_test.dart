import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:desafio_bemol/ui/widgets/enhanced_error_widget.dart';

void main() {
  group('EnhancedErrorWidget Tests', () {
    setUpAll(() {
      GoogleFonts.config.allowRuntimeFetching = false;
    });

    setUp(() {
      // Setup is handled in createTestWidget
    });

    Widget createTestWidget({
      required String message,
      VoidCallback? onRetry,
      ErrorType errorType = ErrorType.generic,
      bool showImage = true,
      String? customImagePath,
    }) {
      return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
        ),
        home: Scaffold(
          body: EnhancedErrorWidget(
            message: message,
            onRetry: onRetry,
            errorType: errorType,
            showImage: showImage,
            customImagePath: customImagePath,
          ),
        ),
      );
    }

    testWidgets('should display error message', (WidgetTester tester) async {
      const message = 'Test error message';
      
      await tester.pumpWidget(createTestWidget(message: message));
      
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('should display correct icon for network error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        message: 'Network error',
        errorType: ErrorType.network,
        showImage: false,
      ));
      
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Sem conexão'), findsOneWidget);
    });

    testWidgets('should display correct icon for server error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        message: 'Server error',
        errorType: ErrorType.server,
        showImage: false,
      ));
      
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.text('Erro do servidor'), findsOneWidget);
    });

    testWidgets('should display correct icon for timeout error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        message: 'Timeout error',
        errorType: ErrorType.timeout,
        showImage: false,
      ));
      
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.text('Tempo esgotado'), findsOneWidget);
    });

    testWidgets('should display correct icon for not found error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        message: 'Not found error',
        errorType: ErrorType.notFound,
        showImage: false,
      ));
      
      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('Nada encontrado'), findsOneWidget);
    });

    testWidgets('should display correct icon for storage error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        message: 'Storage error',
        errorType: ErrorType.storage,
        showImage: false,
      ));
      
      expect(find.byIcon(Icons.storage), findsOneWidget);
      expect(find.text('Erro de armazenamento'), findsOneWidget);
    });

    testWidgets('should display correct icon for generic error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        message: 'Generic error',
        errorType: ErrorType.generic,
        showImage: false,
      ));
      
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Ops! Algo deu errado'), findsOneWidget);
    });

    testWidgets('should show retry button when onRetry is provided', (WidgetTester tester) async {
      bool retryPressed = false;
      
      await tester.pumpWidget(createTestWidget(
        message: 'Test error',
        onRetry: () => retryPressed = true,
      ));
      
      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      
      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();
      
      expect(retryPressed, isTrue);
    });

    testWidgets('should not show retry button when onRetry is null', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        message: 'Test error',
        onRetry: null,
      ));
      
      expect(find.text('Tentar novamente'), findsNothing);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('should show correct retry button text for network error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        message: 'Network error',
        errorType: ErrorType.network,
        onRetry: () {},
      ));
      
      expect(find.text('Verificar conexão'), findsOneWidget);
    });

    testWidgets('should show correct retry button text for not found error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        message: 'Not found error',
        errorType: ErrorType.notFound,
        onRetry: () {},
      ));
      
      expect(find.text('Buscar novamente'), findsOneWidget);
    });

    testWidgets('should show help text for network error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        message: 'Network error',
        errorType: ErrorType.network,
      ));
      
      expect(find.text('Verifique sua conexão com a internet e tente novamente.'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should show help text for server error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        message: 'Server error',
        errorType: ErrorType.server,
      ));
      
      expect(find.text('Nossos servidores estão temporariamente indisponíveis.'), findsOneWidget);
    });

    testWidgets('should not show help text for generic error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        message: 'Generic error',
        errorType: ErrorType.generic,
      ));
      
      expect(find.byIcon(Icons.info_outline), findsNothing);
    });

    testWidgets('should hide image when showImage is false', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        message: 'Test error',
        showImage: false,
      ));
      
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('should handle long error messages', (WidgetTester tester) async {
      const longMessage = 'This is a very long error message that should be displayed properly without causing any layout issues or text overflow problems in the error widget';
      
      await tester.pumpWidget(createTestWidget(message: longMessage));
      
      expect(find.text(longMessage), findsOneWidget);
    });

    testWidgets('should be centered in the screen', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(message: 'Test error'));
      
      // Verify that the error widget is properly centered
      expect(find.byType(EnhancedErrorWidget), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('should have proper spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        message: 'Test error',
        onRetry: () {},
        showImage: false,
      ));
      
      expect(find.byType(SizedBox), findsAtLeastNWidgets(3));
    });
  });
}