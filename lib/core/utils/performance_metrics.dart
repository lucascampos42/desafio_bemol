import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'logger.dart';

/// Sistema de métricas de performance para monitoramento do app
class PerformanceMetrics {
  static final PerformanceMetrics _instance = PerformanceMetrics._internal();
  factory PerformanceMetrics() => _instance;
  PerformanceMetrics._internal();

  static PerformanceMetrics get instance => _instance;

  final Map<String, DateTime> _startTimes = {};
  final Map<String, List<int>> _durations = {};
  final Map<String, int> _counters = {};
  
  /// Inicia medição de tempo para uma operação
  void startTimer(String operation) {
    _startTimes[operation] = DateTime.now();
    AppLogger.debug('⏱️ Started timer for: $operation', LogTags.performance);
  }

  /// Para medição de tempo e registra a duração
  void stopTimer(String operation) {
    final startTime = _startTimes[operation];
    if (startTime == null) {
      AppLogger.warning('Timer not found for operation: $operation', LogTags.performance);
      return;
    }

    final duration = DateTime.now().difference(startTime).inMilliseconds;
    _durations.putIfAbsent(operation, () => []).add(duration);
    _startTimes.remove(operation);

    AppLogger.info('⏱️ $operation completed in ${duration}ms', LogTags.performance);
    
    // Log warning para operações lentas
    if (duration > 1000) {
      AppLogger.warning('🐌 Slow operation detected: $operation took ${duration}ms', LogTags.performance);
    }
  }

  /// Incrementa contador para uma métrica
  void incrementCounter(String metric) {
    _counters[metric] = (_counters[metric] ?? 0) + 1;
    AppLogger.debug('📊 Counter $metric: ${_counters[metric]}', LogTags.performance);
  }

  /// Registra evento personalizado
  void logEvent(String event, {Map<String, dynamic>? data}) {
    final logData = data != null ? ' - Data: $data' : '';
    AppLogger.info('📝 Event: $event$logData', LogTags.performance);
  }

  /// Mede tempo de execução de uma função
  Future<T> measureAsync<T>(String operation, Future<T> Function() function) async {
    startTimer(operation);
    try {
      final result = await function();
      stopTimer(operation);
      return result;
    } catch (e) {
      stopTimer(operation);
      AppLogger.error('❌ Error in $operation', e, null, LogTags.performance);
      rethrow;
    }
  }

  /// Mede tempo de execução de uma função síncrona
  T measureSync<T>(String operation, T Function() function) {
    startTimer(operation);
    try {
      final result = function();
      stopTimer(operation);
      return result;
    } catch (e) {
      stopTimer(operation);
      AppLogger.error('❌ Error in $operation', e, null, LogTags.performance);
      rethrow;
    }
  }

  /// Obtém estatísticas de uma operação
  PerformanceStats? getStats(String operation) {
    final durations = _durations[operation];
    if (durations == null || durations.isEmpty) return null;

    durations.sort();
    final count = durations.length;
    final sum = durations.reduce((a, b) => a + b);
    final average = sum / count;
    final median = count % 2 == 0
        ? (durations[count ~/ 2 - 1] + durations[count ~/ 2]) / 2
        : durations[count ~/ 2].toDouble();

    return PerformanceStats(
      operation: operation,
      count: count,
      averageMs: average,
      medianMs: median,
      minMs: durations.first,
      maxMs: durations.last,
      totalMs: sum,
    );
  }

  /// Obtém todas as estatísticas
  Map<String, PerformanceStats> getAllStats() {
    final stats = <String, PerformanceStats>{};
    for (final operation in _durations.keys) {
      final stat = getStats(operation);
      if (stat != null) {
        stats[operation] = stat;
      }
    }
    return stats;
  }

  /// Obtém todos os contadores
  Map<String, int> getAllCounters() => Map.from(_counters);

  /// Gera relatório de performance
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('📊 PERFORMANCE REPORT');
    buffer.writeln('=' * 50);
    
    // Estatísticas de tempo
    buffer.writeln('\n⏱️ TIMING STATISTICS:');
    final stats = getAllStats();
    if (stats.isEmpty) {
      buffer.writeln('No timing data available');
    } else {
      for (final stat in stats.values) {
        buffer.writeln('${stat.operation}:');
        buffer.writeln('  Count: ${stat.count}');
        buffer.writeln('  Average: ${stat.averageMs.toStringAsFixed(2)}ms');
        buffer.writeln('  Median: ${stat.medianMs.toStringAsFixed(2)}ms');
        buffer.writeln('  Min: ${stat.minMs}ms');
        buffer.writeln('  Max: ${stat.maxMs}ms');
        buffer.writeln('  Total: ${stat.totalMs}ms');
        buffer.writeln('');
      }
    }

    // Contadores
    buffer.writeln('📊 COUNTERS:');
    final counters = getAllCounters();
    if (counters.isEmpty) {
      buffer.writeln('No counter data available');
    } else {
      for (final entry in counters.entries) {
        buffer.writeln('${entry.key}: ${entry.value}');
      }
    }

    return buffer.toString();
  }

  /// Limpa todas as métricas
  void clear() {
    _startTimes.clear();
    _durations.clear();
    _counters.clear();
    AppLogger.info('🧹 Performance metrics cleared', LogTags.performance);
  }

  /// Monitora uso de memória (apenas em debug)
  void logMemoryUsage(String context) {
    if (kDebugMode) {
      try {
        // Força garbage collection para medição mais precisa
        SystemChannels.platform.invokeMethod('SystemChrome.setApplicationSwitcherDescription');
        
        AppLogger.info('🧠 Memory check at: $context', LogTags.performance);
      } catch (e) {
        AppLogger.debug('Could not get memory info: $e', LogTags.performance);
      }
    }
  }
}

/// Classe para armazenar estatísticas de performance
class PerformanceStats {
  final String operation;
  final int count;
  final double averageMs;
  final double medianMs;
  final int minMs;
  final int maxMs;
  final int totalMs;

  const PerformanceStats({
    required this.operation,
    required this.count,
    required this.averageMs,
    required this.medianMs,
    required this.minMs,
    required this.maxMs,
    required this.totalMs,
  });

  @override
  String toString() {
    return 'PerformanceStats(operation: $operation, count: $count, avg: ${averageMs.toStringAsFixed(2)}ms)';
  }
}

/// Extensão para facilitar uso das métricas
extension PerformanceExtension on PerformanceMetrics {
  /// Métricas específicas para operações de API
  void trackApiCall(String endpoint) {
    incrementCounter('api_calls_total');
    incrementCounter('api_calls_$endpoint');
  }

  /// Métricas específicas para operações de UI
  void trackScreenNavigation(String screenName) {
    incrementCounter('screen_navigations_total');
    incrementCounter('screen_navigations_$screenName');
    logEvent('screen_navigation', {'screen': screenName});
  }

  /// Métricas específicas para operações de favoritos
  void trackFavoriteAction(String action) {
    incrementCounter('favorite_actions_total');
    incrementCounter('favorite_actions_$action');
  }

  /// Métricas específicas para busca
  void trackSearchAction(String query) {
    incrementCounter('search_actions_total');
    if (query.isNotEmpty) {
      incrementCounter('search_with_query');
    } else {
      incrementCounter('search_cleared');
    }
  }
}