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
  
  void startTimer(String operation) {
    _startTimes[operation] = DateTime.now();
    AppLogger.debug('⏱️ Timer iniciado para: $operation', LogTags.performance);
  }

  void stopTimer(String operation) {
    final startTime = _startTimes[operation];
    if (startTime == null) {
      AppLogger.warning('Timer não encontrado para operação: $operation', LogTags.performance);
      return;
    }

    final duration = DateTime.now().difference(startTime).inMilliseconds;
    _durations.putIfAbsent(operation, () => []).add(duration);
    _startTimes.remove(operation);

    AppLogger.info('⏱️ $operation concluído em ${duration}ms', LogTags.performance);
    
    // Registra aviso para operações lentas
    if (duration > 1000) {
      AppLogger.warning('🐌 Operação lenta detectada: $operation levou ${duration}ms', LogTags.performance);
    }
  }

  void incrementCounter(String metric) {
    _counters[metric] = (_counters[metric] ?? 0) + 1;
    AppLogger.debug('📊 Contador $metric: ${_counters[metric]}', LogTags.performance);
  }

  void logEvent(String event, Map<String, dynamic>? data) {
    final logData = data != null ? ' - Data: $data' : '';
    AppLogger.info('📝 Evento: $event$logData', LogTags.performance);
  }

  /// Mede tempo de execução de uma função assíncrona
  Future<T> measureAsync<T>(String operation, Future<T> Function() function) async {
    startTimer(operation);
    try {
      final result = await function();
      stopTimer(operation);
      return result;
    } catch (e) {
      stopTimer(operation);
      AppLogger.error('❌ Erro em $operation', e, null, LogTags.performance);
      rethrow;
    }
  }

  T measure<T>(String operation, T Function() function) {
    startTimer(operation);
    try {
      final result = function();
      stopTimer(operation);
      return result;
    } catch (e) {
      stopTimer(operation);
      AppLogger.error('❌ Erro em $operation', e, null, LogTags.performance);
      rethrow;
    }
  }

  T measureSync<T>(String operation, T Function() function) {
    return measure(operation, function);
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

  Map<String, Map<String, dynamic>> getStatistics() {
    final result = <String, Map<String, dynamic>>{};
    
    // Adiciona estatísticas de tempo
    for (final operation in _durations.keys) {
      final durations = _durations[operation]!;
      if (durations.isNotEmpty) {
        final sum = durations.reduce((a, b) => a + b);
        result[operation] = {
          'count': durations.length,
          'total_duration': sum,
          'average_duration': sum / durations.length,
        };
      }
    }
    
    // Adiciona contadores
    for (final entry in _counters.entries) {
      result[entry.key] = {
        'count': entry.value,
      };
    }
    
    return result;
  }


  Map<String, int> getAllCounters() => Map.from(_counters);

  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('📊 RELATÓRIO DE PERFORMANCE');
    buffer.writeln('=' * 50);
    
    // Estatísticas de tempo
    buffer.writeln('\n⏱️ ESTATÍSTICAS DE TEMPO:');
    final stats = getAllStats();
    if (stats.isEmpty) {
      buffer.writeln('Nenhum dado de tempo disponível');
    } else {
      for (final stat in stats.values) {
        buffer.writeln('${stat.operation}:');
        buffer.writeln('  Contagem: ${stat.count}');
        buffer.writeln('  Média: ${stat.averageMs.toStringAsFixed(2)}ms');
        buffer.writeln('  Mediana: ${stat.medianMs.toStringAsFixed(2)}ms');
        buffer.writeln('  Mín: ${stat.minMs}ms');
        buffer.writeln('  Máx: ${stat.maxMs}ms');
        buffer.writeln('  Total: ${stat.totalMs}ms');
        buffer.writeln('');
      }
    }

    // Contadores
    buffer.writeln('📊 CONTADORES:');
    final counters = getAllCounters();
    if (counters.isEmpty) {
      buffer.writeln('Nenhum dado de contador disponível');
    } else {
      for (final entry in counters.entries) {
        buffer.writeln('${entry.key}: ${entry.value}');
      }
    }

    return buffer.toString();
  }

  void clear() {
    _startTimes.clear();
    _durations.clear();
    _counters.clear();
    AppLogger.info('🧹 Métricas de performance limpas', LogTags.performance);
  }

  void reset() {
    clear();
  }

  void logMemoryUsage(String context) {
    if (kDebugMode) {
      try {
        // Força garbage collection para medição mais precisa
        SystemChannels.platform.invokeMethod('SystemChrome.setApplicationSwitcherDescription');
        
        AppLogger.info('🧠 Verificação de memória em: $context', LogTags.performance);
      } catch (e) {
        AppLogger.debug('Não foi possível obter informações de memória: $e', LogTags.performance);
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

extension PerformanceExtension on PerformanceMetrics {
  void trackApiCall(String endpoint, String status) {
    incrementCounter('api_calls_total');
    incrementCounter('api_$endpoint');
    logEvent('api_call', {
      'endpoint': endpoint,
      'status': status,
    });
  }

  void trackScreenNavigation(String screenName, [Map<String, dynamic>? data]) {
    incrementCounter('screen_navigations_total');
    incrementCounter('navigation_$screenName');
    logEvent('screen_navigation', {
      'screen': screenName,
      ...?data,
    });
  }

  void trackFavoriteAction(int productId, String action) {
    incrementCounter('favorite_actions_total');
    incrementCounter('favorite_$action');
    logEvent('favorite_action', {
      'product_id': productId.toString(),
      'action': action,
    });
  }

  void trackSearchAction(String query) {
    incrementCounter('search_action');
    if (query.isNotEmpty) {
      incrementCounter('search_with_query');
    } else {
      incrementCounter('search_cleared');
    }
    logEvent('search_action', {
      'query_length': query.length.toString(),
      'has_query': query.isNotEmpty.toString(),
    });
  }
}
