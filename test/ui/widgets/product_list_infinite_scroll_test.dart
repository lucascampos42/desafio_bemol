import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:desafio_bemol/ui/widgets/product_list_widget.dart';
import 'package:desafio_bemol/providers/product_state.dart';
import 'package:desafio_bemol/data/models/product.dart';

void main() {
  group('ProductListWidget - Scroll Infinito', () {
    testWidgets('deve exibir indicador de carregamento inicial', (tester) async {
      final state = ProductState.initial().copyWith(isLoading: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductListWidget(
              state: state,
              scrollController: ScrollController(),
              onProductTap: (product) {},
              onFavoriteToggle: (product, context) {},
              isFavorite: (product) => false,
              onRefresh: () async {},
              onClearSearch: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve exibir indicador no final da lista quando carregando mais', (tester) async {
      final product = Product(
        id: 1,
        title: 'Produto 1',
        price: 10.0,
        description: 'Descrição 1',
        category: 'categoria1',
        image: 'image1.jpg',
        rating: Rating(rate: 4.5, count: 100),
      );
      
      final state = ProductState(
        products: [product],
        filteredProducts: [product],
        favorites: [],
        favoriteIds: {},
        isLoading: false,
        isLoadingFavorites: false,
        isLoadingMore: true,
        hasMoreProducts: true,
        currentPage: 1,
        pageSize: 10,
        searchQuery: '',
        categories: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductListWidget(
              state: state,
              scrollController: ScrollController(),
              onProductTap: (product) {},
              onFavoriteToggle: (product, context) {},
              isFavorite: (product) => false,
              onRefresh: () async {},
              onClearSearch: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      
      // Aguarda as animações terminarem
      await tester.pump(const Duration(milliseconds: 500));
      
      // Deve ter um produto e indicadores de loading (pode ter mais de um)
      expect(find.text('Produto 1'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });
  });
}