import 'package:flutter/foundation.dart';

/// Sistema de log centralizado para a aplicação
class AppLogger {
  static const String _tag = 'DesafioBemol';
  
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] INFO: $message');
    }
  }
  
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
  
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] WARNING: $message');
    }
  }
  
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] DEBUG: $message');
    }
  }
  
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

  static const String performance = 'PERFORMANCE';
}
