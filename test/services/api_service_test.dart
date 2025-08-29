import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:desafio_bemol/data/services/api_service.dart';
import 'package:desafio_bemol/data/models/product.dart';
import 'package:desafio_bemol/core/utils/constants.dart';

import 'api_service_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      apiService = ApiService(mockDio);
    });

    group('Singleton Pattern', () {
      test('deve retornar a mesma instância', () {
        final instance1 = ApiService.instance;
        final instance2 = ApiService.instance;
        expect(instance1, same(instance2));
      });

      test('deve retornar a mesma instância via factory', () {
        final instance1 = ApiService();
        final instance2 = ApiService();
        expect(instance1, same(instance2));
      });
    });

    group('getProducts', () {
      test('deve retornar lista de produtos com sucesso', () async {
        // Arrange
        final mockResponse = Response(
          data: [
            {
              'id': 1,
              'title': 'Produto Teste',
              'price': 29.99,
              'description': 'Descrição do produto',
              'category': 'electronics',
              'image': 'https://example.com/image.jpg',
              'rating': {'rate': 4.5, 'count': 100}
            }
          ],
          statusCode: 200,
          requestOptions: RequestOptions(path: AppConstants.productsEndpoint),
        );

        when(mockDio.get(
          AppConstants.productsEndpoint,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final products = await apiService.getProducts(limit: 10, offset: 0);

        // Assert
        expect(products, isA<List<Product>>());
        expect(products.length, equals(1));
        expect(products.first.title, equals('Produto Teste'));
        expect(products.first.price, equals(29.99));
      });

      test('deve aplicar paginação corretamente', () async {
        // Arrange
        final allProducts = List.generate(20, (index) => {
          'id': index + 1,
          'title': 'Produto ${index + 1}',
          'price': 10.0 + index,
          'description': 'Descrição ${index + 1}',
          'category': 'electronics',
          'image': 'https://example.com/image${index + 1}.jpg',
          'rating': {'rate': 4.5, 'count': 100}
        });

        final mockResponse = Response(
          data: allProducts,
          statusCode: 200,
          requestOptions: RequestOptions(path: AppConstants.productsEndpoint),
        );

        when(mockDio.get(
          AppConstants.productsEndpoint,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act - Segunda página (offset 10, limit 10)
        final products = await apiService.getProducts(limit: 10, offset: 10);

        // Assert
        expect(products.length, equals(10));
        expect(products.first.title, equals('Produto 11'));
        expect(products.last.title, equals('Produto 20'));
      });

      test('deve lançar ApiException em caso de erro HTTP', () async {
        // Arrange
        final mockResponse = Response(
          data: null,
          statusCode: 404,
          requestOptions: RequestOptions(path: AppConstants.productsEndpoint),
        );

        when(mockDio.get(
          AppConstants.productsEndpoint,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => apiService.getProducts(),
          throwsA(isA<ApiException>()),
        );
      });

      test('deve tratar DioException corretamente', () async {
        // Arrange
        when(mockDio.get(
          AppConstants.productsEndpoint,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: AppConstants.productsEndpoint),
          type: DioExceptionType.connectionTimeout,
        ));

        // Act & Assert
        expect(
          () => apiService.getProducts(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getProductById', () {
      test('deve retornar produto específico com sucesso', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'id': 1,
            'title': 'Produto Específico',
            'price': 49.99,
            'description': 'Descrição específica',
            'category': 'electronics',
            'image': 'https://example.com/specific.jpg',
            'rating': {'rate': 4.8, 'count': 200}
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '${AppConstants.productsEndpoint}/1'),
        );

        when(mockDio.get('${AppConstants.productsEndpoint}/1'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final product = await apiService.getProductById(1);

        // Assert
        expect(product, isA<Product>());
        expect(product.id, equals(1));
        expect(product.title, equals('Produto Específico'));
        expect(product.price, equals(49.99));
      });

      test('deve lançar exceção para produto não encontrado', () async {
        // Arrange
        final mockResponse = Response(
          data: null,
          statusCode: 404,
          requestOptions: RequestOptions(path: '${AppConstants.productsEndpoint}/999'),
        );

        when(mockDio.get('${AppConstants.productsEndpoint}/999'))
            .thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => apiService.getProductById(999),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });
}