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
        error: true,
        requestHeader: true,
        responseHeader: true,
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
        throw ApiException('Error loading products: ${response.statusCode}');
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
        return Product.fromJson(response.data);
      } else {
        throw ApiException('Product not found');
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
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('Error loading category products');
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
        return data.cast<String>();
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
        return ApiException('Connection timeout');
      case DioExceptionType.receiveTimeout:
        return ApiException('Receive timeout');
      case DioExceptionType.sendTimeout:
        return ApiException('Send timeout');
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