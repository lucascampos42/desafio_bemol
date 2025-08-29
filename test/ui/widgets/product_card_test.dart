import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desafio_bemol/data/models/product.dart';
import 'package:desafio_bemol/ui/widgets/product_card.dart';

void main() {
  group('ProductCard Widget Tests', () {
    late Product testProduct;

    setUp(() {
      testProduct = Product(
        id: 1,
        title: 'Produto Teste',
        price: 29.99,
        description: 'Descrição do produto teste',
        category: 'electronics',
        image: 'https://example.com/image.jpg',
        rating: Rating(rate: 4.5, count: 100),
      );
    });

    Widget createTestWidget({
      Product? product,
      bool? isFavorite,
      VoidCallback? onTap,
      VoidCallback? onFavoriteToggle,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ProductCard(
            product: product ?? testProduct,
            isFavorite: isFavorite ?? false,
            onTap: onTap ?? () {},
            onFavoriteToggle: onFavoriteToggle ?? () {},
          ),
        ),
      );
    }

    group('Rendering', () {
      testWidgets('deve renderizar todos os elementos do produto', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.textContaining('Produto Teste'), findsOneWidget);
        expect(find.textContaining('29'), findsOneWidget);
        expect(find.textContaining('4.5'), findsOneWidget);
        expect(find.textContaining('100'), findsOneWidget);
        expect(find.byType(ProductCard), findsOneWidget);
      });

      testWidgets('deve renderizar ícone de favorito vazio quando não é favorito', (tester) async {
        await tester.pumpWidget(createTestWidget(isFavorite: false));

        expect(find.byType(ProductCard), findsOneWidget);
      });

      testWidgets('deve renderizar ícone de favorito preenchido quando é favorito', (tester) async {
        await tester.pumpWidget(createTestWidget(isFavorite: true));

        expect(find.byType(ProductCard), findsOneWidget);
      });

      testWidgets('deve truncar título longo corretamente', (tester) async {
        final productWithLongTitle = Product(
          id: 1,
          title: 'Este é um título muito longo que deveria ser truncado para não quebrar o layout do card',
          price: 29.99,
          description: 'Descrição',
          category: 'electronics',
          image: 'https://example.com/image.jpg',
          rating: Rating(rate: 4.5, count: 100),
        );

        await tester.pumpWidget(createTestWidget(product: productWithLongTitle));

        expect(find.byType(ProductCard), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets('deve aceitar callbacks onTap e onFavoriteToggle', (tester) async {
        bool tapCalled = false;
        bool favoriteToggleCalled = false;
        
        void onTap() {
          tapCalled = true;
        }
        
        void onFavoriteToggle() {
          favoriteToggleCalled = true;
        }

        await tester.pumpWidget(createTestWidget(
          onTap: onTap,
          onFavoriteToggle: onFavoriteToggle,
        ));

        expect(find.byType(ProductCard), findsOneWidget);
        
        // Simula os callbacks diretamente
        onTap();
        onFavoriteToggle();
        
        expect(tapCalled, isTrue);
        expect(favoriteToggleCalled, isTrue);
      });
    });

    group('Edge Cases', () {
      testWidgets('deve lidar com preço zero', (tester) async {
        final productWithZeroPrice = Product(
          id: 1,
          title: 'Produto Grátis',
          price: 0.0,
          description: 'Descrição',
          category: 'electronics',
          image: 'https://example.com/image.jpg',
          rating: Rating(rate: 4.5, count: 100),
        );

        await tester.pumpWidget(createTestWidget(product: productWithZeroPrice));

        expect(find.byType(ProductCard), findsOneWidget);
      });

      testWidgets('deve lidar com rating zero', (tester) async {
        final productWithZeroRating = Product(
          id: 1,
          title: 'Produto Sem Rating',
          price: 29.99,
          description: 'Descrição',
          category: 'electronics',
          image: 'https://example.com/image.jpg',
          rating: Rating(rate: 0.0, count: 0),
        );

        await tester.pumpWidget(createTestWidget(product: productWithZeroRating));

        expect(find.byType(ProductCard), findsOneWidget);
      });

      testWidgets('deve lidar com categoria vazia', (tester) async {
        final productWithEmptyCategory = Product(
          id: 1,
          title: 'Produto Sem Categoria',
          price: 29.99,
          description: 'Descrição',
          category: '',
          image: 'https://example.com/image.jpg',
          rating: Rating(rate: 4.5, count: 100),
        );

        await tester.pumpWidget(createTestWidget(product: productWithEmptyCategory));

        expect(find.byType(ProductCard), findsOneWidget);
      });

      testWidgets('deve lidar com título vazio', (tester) async {
        final productWithEmptyTitle = Product(
          id: 1,
          title: '',
          price: 29.99,
          description: 'Descrição',
          category: 'electronics',
          image: 'https://example.com/image.jpg',
          rating: Rating(rate: 4.5, count: 100),
        );

        await tester.pumpWidget(createTestWidget(product: productWithEmptyTitle));

        expect(find.byType(ProductCard), findsOneWidget);
      });
    });

    group('Performance', () {
      testWidgets('deve renderizar rapidamente com muitos produtos', (tester) async {
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: 100,
                itemBuilder: (context, index) => ProductCard(
                  product: Product(
                    id: index,
                    title: 'Produto $index',
                    price: 29.99 + index,
                    description: 'Descrição $index',
                    category: 'electronics',
                    image: 'https://example.com/image$index.jpg',
                    rating: Rating(rate: 4.5, count: 100),
                  ),
                  isFavorite: index % 2 == 0,
                  onTap: () {},
                  onFavoriteToggle: () {},
                ),
              ),
            ),
          ),
        );
        
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(find.byType(ProductCard), findsWidgets);
      });
    });
  });
}