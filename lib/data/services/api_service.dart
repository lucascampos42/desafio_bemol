import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/logger.dart';

class ApiService {
  static ApiService? _instance;
  late final Dio _dio;
  
  ApiService._internal([Dio? dio]) {
    if (dio != null) {
      _dio = dio;
    } else {
      _initializeDio();
    }
  }
  
  factory ApiService([Dio? dio]) {
    if (dio != null) {
      // Para testes, sempre cria nova instância com Dio injetado
      return ApiService._internal(dio);
    }
    _instance ??= ApiService._internal();
    return _instance!;
  }
  
  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }
  
  static void resetInstance() {
    _instance = null;
  }
  
  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => AppLogger.debug(obj.toString(), LogTags.api),
        error: true,
        requestHeader: true,
        responseHeader: true,
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        AppLogger.info('Requisição: ${options.method} ${options.path}', LogTags.api);
        handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.success('Resposta: ${response.statusCode} ${response.requestOptions.path}', LogTags.api);
        handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.error('Erro na API: ${error.message}', error, null, LogTags.api);
        handler.next(error);
      },
    ));
  }
  
  /// Carrega produtos com suporte a paginação
  /// 
  /// [limit] - Número máximo de produtos a retornar (padrão: 20)
  /// [offset] - Número de produtos a pular (para paginação)
  Future<List<Product>> getProducts({int limit = 20, int offset = 0}) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
      };
      
      // A fakestoreapi.com suporta apenas limit, não offset
      // Para simular paginação, vamos usar limit e depois filtrar no cliente
      final response = await _dio.get(
        AppConstants.productsEndpoint,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final allProducts = data.map((json) => Product.fromJson(json)).toList();
        
        // Simula paginação no cliente já que a API não suporta offset
        final startIndex = offset;
        final endIndex = (startIndex + limit).clamp(0, allProducts.length);
        
        final products = startIndex < allProducts.length 
            ? allProducts.sublist(startIndex, endIndex)
            : <Product>[];
            
        AppLogger.success('${products.length} produtos carregados (offset: $offset, limit: $limit)', LogTags.api);
        return products;
      } else {
        throw ApiException('Error loading products: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }
  
  /// Carrega todos os produtos (para uso interno)
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _dio.get(AppConstants.productsEndpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final products = data.map((json) => Product.fromJson(json)).toList();
        AppLogger.success('${products.length} produtos carregados com sucesso', LogTags.api);
        return products;
      } else {
        throw ApiException('Erro ao carregar produtos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }
  
  Future<Product> getProductById(int id) async {
    try {
      final response = await _dio.get('${AppConstants.productsEndpoint}/$id');
      
      if (response.statusCode == 200) {
        final product = Product.fromJson(response.data);
        AppLogger.success('Produto ${product.title} carregado com sucesso', LogTags.api);
        return product;
      } else {
        throw ApiException('Produto não encontrado');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }
  
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await _dio.get('${AppConstants.productsEndpoint}/category/$category');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final products = data.map((json) => Product.fromJson(json)).toList();
        AppLogger.success('${products.length} produtos da categoria "$category" carregados', LogTags.api);
        return products;
      } else {
        throw ApiException('Error loading products from category');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }
  
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get('${AppConstants.productsEndpoint}/categories');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final categories = data.cast<String>();
        AppLogger.success('${categories.length} categorias carregadas: ${categories.join(", ")}', LogTags.api);
        return categories;
      } else {
        throw ApiException('Error loading categories');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }
  
  /// Trata erros do Dio
  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 404) {
          return ApiException(AppConstants.notFoundError);
        }
        return ApiException('Server error: ${e.response?.statusCode}');
      case DioExceptionType.cancel:
        return ApiException('Request cancelled');
      case DioExceptionType.connectionTimeout:
        return ApiException('Tempo limite de conexão excedido');
      case DioExceptionType.receiveTimeout:
        return ApiException('Tempo limite de recebimento excedido');
      case DioExceptionType.sendTimeout:
        return ApiException('Tempo limite de envio excedido');
      case DioExceptionType.unknown:
      default:
        return ApiException(AppConstants.genericError);
    }
  }
}

class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}