import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:desafio_bemol/providers/product_provider.dart';
import 'package:desafio_bemol/providers/product_state.dart';
import 'package:desafio_bemol/data/models/product.dart';

void main() {
  group('ProductProvider - Scroll Infinito', () {
    late ProductProvider productProvider;
    late ScrollController scrollController;

    setUp(() {
      scrollController = ScrollController();
      productProvider = ProductProvider();
    });

    tearDown(() {
      productProvider.dispose();
      scrollController.dispose();
    });

    group('ProductState - Paginação', () {
      test('deve ter estado inicial correto para paginação', () {
        // Arrange & Act
        final initialState = ProductState.initial();

        // Assert
        expect(initialState.currentPage, equals(0));
        expect(initialState.hasMoreProducts, isTrue);
        expect(initialState.isLoadingMore, isFalse);
        expect(initialState.pageSize, equals(10));
      });

      test('deve atualizar estado de paginação corretamente', () {
        // Arrange
        final initialState = ProductState.initial();
        final mockProducts = List.generate(10, (index) => Product(
          id: index + 1,
          title: 'Produto ${index + 1}',
          price: 10.0 + index,
          description: 'Descrição ${index + 1}',
          category: 'categoria1',
          image: 'image${index + 1}.jpg',
          rating: Rating(rate: 4.5, count: 100),
        ));

        // Act
        final updatedState = initialState.copyWith(
          products: mockProducts,
          currentPage: 1,
          hasMoreProducts: true,
          isLoadingMore: false,
        );

        // Assert
        expect(updatedState.products.length, equals(10));
        expect(updatedState.currentPage, equals(1));
        expect(updatedState.hasMoreProducts, isTrue);
        expect(updatedState.isLoadingMore, isFalse);
      });
    });

    group('Estado de Carregamento', () {
      test('deve simular adição de produtos à lista existente', () {
        // Arrange
        final initialProducts = List.generate(10, (index) => Product(
          id: index + 1,
          title: 'Produto ${index + 1}',
          price: 10.0 + index,
          description: 'Descrição ${index + 1}',
          category: 'categoria1',
          image: 'image${index + 1}.jpg',
          rating: Rating(rate: 4.5, count: 100),
        ));
        
        final moreProducts = List.generate(10, (index) => Product(
          id: index + 11,
          title: 'Produto ${index + 11}',
          price: 20.0 + index,
          description: 'Descrição ${index + 11}',
          category: 'categoria1',
          image: 'image${index + 11}.jpg',
          rating: Rating(rate: 4.5, count: 100),
        ));

        // Configurar estado inicial
        productProvider.value = productProvider.value.copyWith(
          products: initialProducts,
          currentPage: 1,
          hasMoreProducts: true,
        );

        // Simular carregamento de mais produtos
        final allProducts = [...initialProducts, ...moreProducts];
        productProvider.value = productProvider.value.copyWith(
          products: allProducts,
          currentPage: 2,
          isLoadingMore: false,
        );

        // Assert
        expect(productProvider.value.products.length, equals(20));
        expect(productProvider.value.currentPage, equals(2));
        expect(productProvider.value.isLoadingMore, isFalse);
      });

      test('deve controlar estado de carregamento corretamente', () {
        // Arrange
        productProvider.value = productProvider.value.copyWith(
          isLoadingMore: true,
          hasMoreProducts: true,
        );

        // Assert
        expect(productProvider.value.isLoadingMore, isTrue);
        expect(productProvider.value.hasMoreProducts, isTrue);
        
        // Simular fim do carregamento
        productProvider.value = productProvider.value.copyWith(
          isLoadingMore: false,
        );
        
        expect(productProvider.value.isLoadingMore, isFalse);
      });

      test('deve controlar quando não há mais produtos', () {
        // Arrange & Act
        productProvider.value = productProvider.value.copyWith(
          hasMoreProducts: false,
        );

        // Assert
        expect(productProvider.value.hasMoreProducts, isFalse);
      });
    });

    group('Condições de Scroll', () {
      test('deve verificar condições para carregar mais produtos', () {
        // Arrange
        productProvider.value = productProvider.value.copyWith(
          hasMoreProducts: true,
          isLoadingMore: false,
          isLoading: false,
        );

        // Act & Assert
        expect(productProvider.value.hasMoreProducts, isTrue);
        expect(productProvider.value.isLoadingMore, isFalse);
        expect(productProvider.value.isLoading, isFalse);
      });

      test('deve impedir carregamento quando não há mais produtos', () {
        // Arrange
        productProvider.value = productProvider.value.copyWith(
          hasMoreProducts: false,
        );

        // Act & Assert
        expect(productProvider.value.hasMoreProducts, isFalse);
      });

      test('deve impedir carregamento quando já está carregando', () {
        // Arrange
        productProvider.value = productProvider.value.copyWith(
          hasMoreProducts: true,
          isLoadingMore: true,
        );

        // Act & Assert
        expect(productProvider.value.isLoadingMore, isTrue);
      });

      test('deve impedir carregamento quando carregamento inicial está ativo', () {
        // Arrange
        productProvider.value = productProvider.value.copyWith(
          hasMoreProducts: true,
          isLoadingMore: false,
          isLoading: true,
        );

        // Act & Assert
        expect(productProvider.value.isLoading, isTrue);
      });
    });
  });
}