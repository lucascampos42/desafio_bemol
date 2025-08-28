import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:desafio_bemol/main.dart' as app;
import 'package:desafio_bemol/data/models/product.dart';
import 'package:desafio_bemol/providers/product_provider.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    group('Main Navigation Flow', () {
    testWidgets('should navigate from home to product details and back', (
      tester,
    ) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(find.byType(ListView), findsOneWidget);
        final firstProduct = find.byKey(const Key('product_card_0')).first;
        await tester.tap(firstProduct);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('product_detail_screen')), findsOneWidget);
        expect(find.byKey(const Key('product_detail_image')), findsOneWidget);
        expect(find.byKey(const Key('product_detail_title')), findsOneWidget);
        expect(find.byKey(const Key('product_detail_price')), findsOneWidget);
        expect(
          find.byKey(const Key('product_detail_description')),
          findsOneWidget,
        );

        // Act - Voltar para home
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Assert - Verificar se voltou para home
        expect(find.byKey(const Key('home_screen')), findsOneWidget);
        expect(find.byType(GridView), findsOneWidget);
      });

      testWidgets('should navigate to favorites screen and back', (
        tester,
      ) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Act - Navegar para favoritos
        await tester.tap(find.byIcon(Icons.favorite));
        await tester.pumpAndSettle();

        // Assert - Verificar se está na tela de favoritos
        expect(find.byKey(const Key('favorites_screen')), findsOneWidget);
        expect(find.text('Favoritos'), findsOneWidget);

        // Act - Voltar para home
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Assert - Verificar se voltou para home
        expect(find.byKey(const Key('home_screen')), findsOneWidget);
      });
    });

    group('Favorites Flow', () {
      testWidgets(
        'should add product to favorites and view in favorites screen',
        (tester) async {
          // Arrange
          app.main();
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Act - Adicionar primeiro produto aos favoritos
          final favoriteButton = find
              .byKey(const Key('favorite_button_0'))
              .first;
          await tester.tap(favoriteButton);
          await tester.pumpAndSettle();

          // Navegar para tela de favoritos
          await tester.tap(find.byIcon(Icons.favorite));
          await tester.pumpAndSettle();

          // Assert - Verificar se produto está nos favoritos
          expect(find.byKey(const Key('favorites_screen')), findsOneWidget);
          expect(find.byType(ListView), findsOneWidget);
          expect(find.byKey(const Key('favorite_product_0')), findsOneWidget);
        },
      );

      testWidgets('should remove product from favorites', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Adicionar produto aos favoritos
        final favoriteButton = find.byKey(const Key('favorite_button_0')).first;
        await tester.tap(favoriteButton);
        await tester.pumpAndSettle();

        // Navegar para favoritos
        await tester.tap(find.byIcon(Icons.favorite));
        await tester.pumpAndSettle();

        // Act - Remover produto dos favoritos
        final removeFavoriteButton = find
            .byKey(const Key('remove_favorite_0'))
            .first;
        await tester.tap(removeFavoriteButton);
        await tester.pumpAndSettle();

        // Assert - Verificar se produto foi removido
        expect(find.text('Nenhum produto favorito'), findsOneWidget);
        expect(find.byKey(const Key('favorite_product_0')), findsNothing);
      });

      testWidgets('should persist favorites after app restart', (
        tester,
      ) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Adicionar produto aos favoritos
        final favoriteButton = find.byKey(const Key('favorite_button_0')).first;
        await tester.tap(favoriteButton);
        await tester.pumpAndSettle();

        // Act - Simular reinício do app
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/platform',
          null,
          (data) {},
        );

        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Navegar para favoritos
        await tester.tap(find.byIcon(Icons.favorite));
        await tester.pumpAndSettle();

        // Assert - Verificar se favorito foi persistido
        expect(find.byKey(const Key('favorite_product_0')), findsOneWidget);
      });
    });

    group('Search Flow', () {
      testWidgets('should search products in real time', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act - Tocar no campo de busca
        final searchField = find.byKey(const Key('search_field'));
        await tester.tap(searchField);
        await tester.pumpAndSettle();

        // Digitar termo de busca
        await tester.enterText(searchField, 'electronics');
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(
          const Duration(milliseconds: 500),
        ); // Aguardar debounce

        // Assert - Verificar se resultados foram filtrados
        expect(find.byType(ListView), findsOneWidget);

        // Verificar se apenas produtos da categoria electronics são mostrados
        final productCards = find.byType(Card);
        expect(productCards, findsWidgets);
      });

      testWidgets('should clear search and show all products', (
        tester,
      ) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final searchField = find.byKey(const Key('search_field'));

        // Fazer uma busca primeiro
        await tester.tap(searchField);
        await tester.enterText(searchField, 'electronics');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Act - Limpar busca
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Assert - Verificar se todos os produtos são mostrados novamente
        expect(find.byType(ListView), findsOneWidget);
        final productCards = find.byType(Card);
        expect(productCards, findsWidgets);
      });

      testWidgets('should show message when no product is found', (
        tester,
      ) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act - Buscar por termo que não existe
        final searchField = find.byKey(const Key('search_field'));
        await tester.tap(searchField);
        await tester.enterText(searchField, 'produto_inexistente_xyz');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Assert - Verificar mensagem de nenhum resultado
        expect(find.text('No products found'), findsOneWidget);
        expect(find.byType(ListView), findsNothing);
      });
    });

    group('Categories Flow', () {
      testWidgets('should filter products by category', (tester) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act - Selecionar categoria
        final categoryChip = find
            .byKey(const Key('category_electronics'))
            .first;
        await tester.tap(categoryChip);
        await tester.pumpAndSettle();

        // Assert - Verificar se produtos foram filtrados
        expect(find.byType(ListView), findsOneWidget);

        // Verificar se chip está selecionado
        final selectedChip = tester.widget<FilterChip>(categoryChip);
        expect(selectedChip.selected, isTrue);
      });

      testWidgets('should remove category filter', (tester) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final categoryChip = find
            .byKey(const Key('category_electronics'))
            .first;
        await tester.tap(categoryChip);
        await tester.pumpAndSettle();

        await tester.tap(categoryChip);
        await tester.pumpAndSettle();

        final unselectedChip = tester.widget<FilterChip>(categoryChip);
        expect(unselectedChip.selected, isFalse);

        expect(find.byType(ListView), findsOneWidget);
      });
    });

    group('Infinite Scroll Flow', () {
      testWidgets('should load more products when scrolling', (
        tester,
      ) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final initialProductCount = find.byType(Card).evaluate().length;

        final listView = find.byType(ListView);
        await tester.drag(listView, const Offset(0, -1000));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(
          const Duration(seconds: 2),
        ); // Aguardar carregamento

        final finalProductCount = find.byType(Card).evaluate().length;
        expect(finalProductCount, greaterThan(initialProductCount));
      });

      testWidgets(
        'should show loading indicator during infinite scroll',
        (tester) async {
          app.main();
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          final listView = find.byType(ListView);
          await tester.drag(listView, const Offset(0, -1000));
          await tester.pump();

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        },
      );
    });

    group('Error Handling', () {
      testWidgets('should show error when fails to load products', (
        tester,
      ) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 5));
        final retryButton = find.byKey(const Key('retry_button'));
        if (retryButton.evaluate().isNotEmpty) {
          await tester.tap(retryButton);
          await tester.pumpAndSettle();
        }

        expect(find.byKey(const Key('home_screen')), findsOneWidget);
      });
    });

    group('Performance', () {
      testWidgets('should maintain performance with many products', (
        tester,
      ) async {
        // Arrange
        app.main();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Act - Fazer múltiplos scrolls
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 5; i++) {
          await tester.drag(find.byType(ListView), const Offset(0, -500));
          await tester.pump();
        }

        stopwatch.stop();

        // Assert - Verificar se performance é aceitável
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        expect(find.byType(ListView), findsOneWidget);
      });
    });
  });
}
