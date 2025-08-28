import 'package:flutter_test/flutter_test.dart';
import 'package:desafio_bemol/data/models/product.dart';

void main() {
  group('Product Model Tests', () {
    late Map<String, dynamic> validProductJson;
    late Product validProduct;

    setUp(() {
      validProductJson = {
        'id': 1,
        'title': 'Produto Teste',
        'price': 29.99,
        'description': 'Descrição do produto teste',
        'category': 'electronics',
        'image': 'https://example.com/image.jpg',
        'rating': {
          'rate': 4.5,
          'count': 100
        }
      };

      validProduct = Product(
        id: 1,
        title: 'Produto Teste',
        price: 29.99,
        description: 'Descrição do produto teste',
        category: 'electronics',
        image: 'https://example.com/image.jpg',
        rating: Rating(rate: 4.5, count: 100),
      );
    });

    group('Constructor', () {
      test('deve criar produto com todos os parâmetros', () {
        // Act
        final product = Product(
          id: 1,
          title: 'Produto Teste',
          price: 29.99,
          description: 'Descrição',
          category: 'electronics',
          image: 'https://example.com/image.jpg',
          rating: Rating(rate: 4.5, count: 100),
        );

        // Assert
        expect(product.id, equals(1));
        expect(product.title, equals('Produto Teste'));
        expect(product.price, equals(29.99));
        expect(product.description, equals('Descrição'));
        expect(product.category, equals('electronics'));
        expect(product.image, equals('https://example.com/image.jpg'));
        expect(product.rating.rate, equals(4.5));
        expect(product.rating.count, equals(100));
      });

      test('deve criar produto com valores padrão quando necessário', () {
        // Act
        final product = Product(
          id: 1,
          title: 'Produto Mínimo',
          price: 10.0,
          description: '',
          category: 'test',
          image: '',
          rating: Rating(rate: 0.0, count: 0),
        );

        // Assert
        expect(product.id, equals(1));
        expect(product.title, equals('Produto Mínimo'));
        expect(product.price, equals(10.0));
        expect(product.description, equals(''));
        expect(product.category, equals('test'));
        expect(product.image, equals(''));
        expect(product.rating.rate, equals(0.0));
        expect(product.rating.count, equals(0));
      });
    });

    group('fromJson', () {
      test('deve criar produto a partir de JSON válido', () {
        // Act
        final product = Product.fromJson(validProductJson);

        // Assert
        expect(product.id, equals(1));
        expect(product.title, equals('Produto Teste'));
        expect(product.price, equals(29.99));
        expect(product.description, equals('Descrição do produto teste'));
        expect(product.category, equals('electronics'));
        expect(product.image, equals('https://example.com/image.jpg'));
        expect(product.rating.rate, equals(4.5));
        expect(product.rating.count, equals(100));
      });

      test('deve tratar price como int e converter para double', () {
        // Arrange
        final jsonWithIntPrice = Map<String, dynamic>.from(validProductJson);
        jsonWithIntPrice['price'] = 30; // int ao invés de double

        // Act
        final product = Product.fromJson(jsonWithIntPrice);

        // Assert
        expect(product.price, equals(30.0));
        expect(product.price, isA<double>());
      });

      test('deve lançar erro quando rating está ausente', () {
        // Arrange
        final jsonWithoutRating = Map<String, dynamic>.from(validProductJson);
        jsonWithoutRating.remove('rating');

        // Act & Assert
        expect(() => Product.fromJson(jsonWithoutRating), throwsA(isA<TypeError>()));
      });

      test('deve lançar erro quando rating tem valores nulos', () {
        // Arrange
        final jsonWithNullRating = Map<String, dynamic>.from(validProductJson);
        jsonWithNullRating['rating'] = {
          'rate': null,
          'count': null
        };

        // Act & Assert
        expect(() => Product.fromJson(jsonWithNullRating), throwsA(isA<TypeError>()));
      });

      test('deve lançar erro com campos obrigatórios como null', () {
        // Arrange
        final jsonWithNulls = {
          'id': null,
          'title': null,
          'price': null,
          'description': null,
          'category': null,
          'image': null,
          'rating': null
        };

        // Act & Assert
        expect(() => Product.fromJson(jsonWithNulls), throwsA(isA<TypeError>()));
      });

      test('deve lançar erro com JSON com campos faltantes', () {
        // Arrange
        final incompleteJson = {
          'id': 1,
          'title': 'Produto Incompleto'
        };

        // Act & Assert
        expect(() => Product.fromJson(incompleteJson), throwsA(isA<TypeError>()));
      });
    });

    group('toJson', () {
      test('deve converter produto para JSON', () {
        // Act
        final json = validProduct.toJson();

        // Assert
        expect(json['id'], equals(1));
        expect(json['title'], equals('Produto Teste'));
        expect(json['price'], equals(29.99));
        expect(json['description'], equals('Descrição do produto teste'));
        expect(json['category'], equals('electronics'));
        expect(json['image'], equals('https://example.com/image.jpg'));
        expect(json['rating'], isA<Map<String, dynamic>>());
        expect(json['rating']['rate'], equals(4.5));
        expect(json['rating']['count'], equals(100));
      });

      test('deve manter consistência entre fromJson e toJson', () {
        // Act
        final product = Product.fromJson(validProductJson);
        final json = product.toJson();
        final productFromJson = Product.fromJson(json);

        // Assert
        expect(productFromJson.id, equals(product.id));
        expect(productFromJson.title, equals(product.title));
        expect(productFromJson.price, equals(product.price));
        expect(productFromJson.description, equals(product.description));
        expect(productFromJson.category, equals(product.category));
        expect(productFromJson.image, equals(product.image));
        expect(productFromJson.rating.rate, equals(product.rating.rate));
        expect(productFromJson.rating.count, equals(product.rating.count));
      });
    });

    group('Equality', () {
      test('deve ser igual quando todos os campos são iguais', () {
        // Arrange
        final product1 = Product.fromJson(validProductJson);
        final product2 = Product.fromJson(validProductJson);

        // Act & Assert
        expect(product1 == product2, isTrue);
        expect(product1.hashCode, equals(product2.hashCode));
      });

      test('deve ser diferente quando ID é diferente', () {
        // Arrange
        final product1 = validProduct;
        final product2 = Product(
          id: 2, // ID diferente
          title: validProduct.title,
          price: validProduct.price,
          description: validProduct.description,
          category: validProduct.category,
          image: validProduct.image,
          rating: validProduct.rating,
        );

        // Act & Assert
        expect(product1 == product2, isFalse);
        expect(product1.hashCode == product2.hashCode, isFalse);
      });

      test('deve ser igual quando ID é igual (mesmo com outros campos diferentes)', () {
        // Arrange
        final product1 = validProduct;
        final product2 = Product(
          id: validProduct.id, // Mesmo ID
          title: 'Título Diferente',
          price: validProduct.price,
          description: validProduct.description,
          category: validProduct.category,
          image: validProduct.image,
          rating: validProduct.rating,
        );

        // Act & Assert
        expect(product1 == product2, isTrue); // Igualdade baseada apenas no ID
      });
    });

    group('toString', () {
      test('deve retornar representação string legível', () {
        // Act
        final stringRepresentation = validProduct.toString();

        // Assert
        expect(stringRepresentation, contains('Product'));
        expect(stringRepresentation, contains('id: 1'));
        expect(stringRepresentation, contains('title: Produto Teste'));
        expect(stringRepresentation, contains('price: 29.99'));
      });
    });

    group('Getters', () {
      test('deve retornar valores corretos dos getters', () {
        // Assert
        expect(validProduct.id, equals(1));
        expect(validProduct.title, equals('Produto Teste'));
        expect(validProduct.price, equals(29.99));
        expect(validProduct.description, equals('Descrição do produto teste'));
        expect(validProduct.category, equals('electronics'));
        expect(validProduct.image, equals('https://example.com/image.jpg'));
        expect(validProduct.rating, isA<Rating>());
      });

      test('deve retornar rating formatado corretamente', () {
        // Assert
        expect(validProduct.rating.rate, equals(4.5));
        expect(validProduct.rating.count, equals(100));
      });
    });
  });

  group('Rating Tests', () {
    test('deve criar rating com valores válidos', () {
      // Act
      final rating = Rating(rate: 4.5, count: 100);

      // Assert
      expect(rating.rate, equals(4.5));
      expect(rating.count, equals(100));
    });

    test('deve criar rating com valores zero', () {
      // Act
      final rating = Rating(rate: 0.0, count: 0);

      // Assert
      expect(rating.rate, equals(0.0));
      expect(rating.count, equals(0));
    });

    test('deve converter rating para JSON', () {
      // Arrange
      final rating = Rating(rate: 4.5, count: 100);

      // Act
      final json = rating.toJson();

      // Assert
      expect(json['rate'], equals(4.5));
      expect(json['count'], equals(100));
    });

    test('deve criar rating a partir de JSON', () {
      // Arrange
      final json = {'rate': 4.5, 'count': 100};

      // Act
      final rating = Rating.fromJson(json);

      // Assert
      expect(rating.rate, equals(4.5));
      expect(rating.count, equals(100));
    });

    test('deve tratar JSON com valores nulos', () {
      // Arrange
      final json = {
        'rate': null,
        'count': null,
      };

      // Act & Assert
      expect(() => Rating.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('deve criar instâncias independentes', () {
      // Arrange
      final rating1 = Rating(rate: 4.5, count: 100);
      final rating2 = Rating(rate: 4.5, count: 100);

      // Act & Assert
      expect(rating1.rate, equals(rating2.rate));
      expect(rating1.count, equals(rating2.count));
      expect(rating1.toString(), equals(rating2.toString()));
    });

    test('deve ter toString formatado corretamente', () {
      // Arrange
      final rating = Rating(rate: 4.5, count: 100);

      // Act
      final stringRepresentation = rating.toString();

      // Assert
      expect(stringRepresentation, contains('Rating'));
      expect(stringRepresentation, contains('rate: 4.5'));
      expect(stringRepresentation, contains('count: 100'));
    });
  });
}