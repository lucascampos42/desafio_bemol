import 'package:flutter/foundation.dart';

/// Sistema de logging centralizado para o aplicativo
class AppLogger {
  static const String _tag = 'DesafioBemol';
  
  /// Log de informação
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] INFO: $message');
    }
  }
  
  /// Log de erro
  static void error(String message, [dynamic error, StackTrace? stackTrace, String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] ERROR: $message');
      if (error != null) {
        debugPrint('[$_tag${tag != null ? ':$tag' : ''}] ERROR Details: $error');
      }
      if (stackTrace != null) {
        debugPrint('[$_tag${tag != null ? ':$tag' : ''}] STACK: $stackTrace');
      }
    }
  }
  
  /// Log de warning
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] WARNING: $message');
    }
  }
  
  /// Log de debug
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] DEBUG: $message');
    }
  }
  
  /// Log de sucesso
  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] SUCCESS: $message');
    }
  }
}

/// Tags específicas para diferentes módulos
class LogTags {
  static const String api = 'API';
  static const String storage = 'STORAGE';
  static const String provider = 'PROVIDER';
  static const String ui = 'UI';
  static const String favorites = 'FAVORITES';
  static const String search = 'SEARCH';
  static const String categories = 'CATEGORIES';
}