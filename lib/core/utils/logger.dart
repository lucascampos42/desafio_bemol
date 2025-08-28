import 'package:flutter/foundation.dart';

/// Centralized logging system for the application
class AppLogger {
  static const String _tag = 'DesafioBemol';
  
  /// Information log
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] INFO: $message');
    }
  }
  
  /// Error log
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
  
  /// Warning log
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] WARNING: $message');
    }
  }
  
  /// Debug log
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] DEBUG: $message');
    }
  }
  
  /// Success log
  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] SUCCESS: $message');
    }
  }
}

/// Specific tags for different modules
class LogTags {
  static const String api = 'API';
  static const String storage = 'STORAGE';
  static const String provider = 'PROVIDER';
  static const String ui = 'UI';
  static const String favorites = 'FAVORITES';
  static const String search = 'SEARCH';
  static const String categories = 'CATEGORIES';
  static const String performance = 'PERFORMANCE';
}