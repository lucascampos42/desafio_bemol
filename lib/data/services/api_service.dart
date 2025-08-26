import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../../core/utils/constants.dart';

class ApiService {
  static ApiService? _instance;
  late final Dio _dio;
  
  ApiService._internal() {
    _initializeDio();
  }
  
  factory ApiService() {
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
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        debugPrint('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }
  
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get(AppConstants.productsEndpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('Erro ao carregar produtos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Erro inesperado: $e');
    }
  }
  
  Future<Product> getProductById(int id) async {
    try {
      final response = await _dio.get('${AppConstants.productsEndpoint}/$id');
      
      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      } else {
        throw ApiException('Produto não encontrado');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Erro inesperado: $e');
    }
  }
  
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await _dio.get('${AppConstants.productsEndpoint}/category/$category');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('Erro ao carregar produtos da categoria');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Erro inesperado: $e');
    }
  }
  
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get('${AppConstants.productsEndpoint}/categories');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.cast<String>();
      } else {
        throw ApiException('Erro ao carregar categorias');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Erro inesperado: $e');
    }
  }
  
  /// Trata erros do Dio
  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException(AppConstants.errorNetwork);
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 404) {
          return ApiException(AppConstants.errorNotFound);
        }
        return ApiException('Erro do servidor: ${e.response?.statusCode}');
      case DioExceptionType.cancel:
        return ApiException('Requisição cancelada');
      case DioExceptionType.unknown:
      default:
        return ApiException(AppConstants.errorNetwork);
    }
  }
}

/// Exceção customizada para erros da API
class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}