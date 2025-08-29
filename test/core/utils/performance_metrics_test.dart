import 'package:flutter_test/flutter_test.dart';
import 'package:desafio_bemol/core/utils/performance_metrics.dart';

void main() {
  group('PerformanceMetrics Tests', () {
    late PerformanceMetrics performanceMetrics;

    setUp(() {
      performanceMetrics = PerformanceMetrics.instance;
      performanceMetrics.reset(); // Limpa dados entre testes
    });

    test('deve ser singleton', () {
      final instance1 = PerformanceMetrics.instance;
      final instance2 = PerformanceMetrics.instance;
      expect(instance1, same(instance2));
    });

    test('deve medir tempo de execução síncrona', () {
      final result = performanceMetrics.measure('test_sync', () {
        // Simula operação que demora um pouco
        for (int i = 0; i < 1000; i++) {
          // Operação simples
        }
        return 'resultado';
      });

      expect(result, equals('resultado'));
      final stats = performanceMetrics.getStatistics();
      expect(stats.containsKey('test_sync'), isTrue);
      expect(stats['test_sync']!['count'], equals(1));
      expect(stats['test_sync']!['total_duration'], greaterThanOrEqualTo(0));
    });

    test('deve medir tempo de execução assíncrona', () async {
      final result = await performanceMetrics.measureAsync('test_async', () async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 'resultado_async';
      });

      expect(result, equals('resultado_async'));
      final stats = performanceMetrics.getStatistics();
      expect(stats.containsKey('test_async'), isTrue);
      expect(stats['test_async']!['count'], equals(1));
      expect(stats['test_async']!['total_duration'], greaterThanOrEqualTo(5));
    });

    test('deve incrementar contadores', () {
      performanceMetrics.incrementCounter('test_counter');
      performanceMetrics.incrementCounter('test_counter');
      performanceMetrics.incrementCounter('test_counter');

      final stats = performanceMetrics.getStatistics();
      expect(stats.containsKey('test_counter'), isTrue);
      expect(stats['test_counter']!['count'], equals(3));
    });

    test('deve registrar eventos customizados', () {
      performanceMetrics.incrementCounter('user_action');
      performanceMetrics.logEvent('user_action', {
        'action': 'button_click',
        'screen': 'home',
      });

      final stats = performanceMetrics.getStatistics();
      expect(stats.containsKey('user_action'), isTrue);
      expect(stats['user_action']!['count'], equals(1));
    });

    test('deve rastrear chamadas de API', () {
      performanceMetrics.trackApiCall('get_products', 'success');
      performanceMetrics.trackApiCall('get_products', 'error');
      performanceMetrics.trackApiCall('get_categories', 'success');

      final stats = performanceMetrics.getStatistics();
      expect(stats.containsKey('api_get_products'), isTrue);
      expect(stats.containsKey('api_get_categories'), isTrue);
      expect(stats['api_get_products']!['count'], equals(2));
      expect(stats['api_get_categories']!['count'], equals(1));
    });

    test('deve rastrear navegação de telas', () {
      performanceMetrics.trackScreenNavigation('home_to_detail', {
        'product_id': '123',
      });

      final stats = performanceMetrics.getStatistics();
      expect(stats.containsKey('navigation_home_to_detail'), isTrue);
      expect(stats['navigation_home_to_detail']!['count'], equals(1));
    });

    test('deve rastrear ações de favoritos', () {
      performanceMetrics.trackFavoriteAction(1, 'add');
      performanceMetrics.trackFavoriteAction(2, 'remove');
      performanceMetrics.trackFavoriteAction(3, 'add');

      final stats = performanceMetrics.getStatistics();
      expect(stats.containsKey('favorite_add'), isTrue);
      expect(stats.containsKey('favorite_remove'), isTrue);
      expect(stats['favorite_add']!['count'], equals(2));
      expect(stats['favorite_remove']!['count'], equals(1));
    });

    test('deve rastrear ações de busca', () {
      performanceMetrics.trackSearchAction('smartphone');
      performanceMetrics.trackSearchAction('laptop');
      performanceMetrics.trackSearchAction('');

      final stats = performanceMetrics.getStatistics();
      expect(stats.containsKey('search_action'), isTrue);
      expect(stats['search_action']!['count'], equals(3));
    });

    test('deve calcular estatísticas corretamente', () {
      // Adiciona várias medições
      performanceMetrics.startTimer('test_operation');
      performanceMetrics.stopTimer('test_operation');
      
      performanceMetrics.startTimer('test_operation');
      performanceMetrics.stopTimer('test_operation');
      
      performanceMetrics.startTimer('test_operation');
      performanceMetrics.stopTimer('test_operation');

      final stats = performanceMetrics.getStatistics();
      expect(stats['test_operation']!['count'], equals(3));
      expect(stats['test_operation']!['average_duration'], greaterThanOrEqualTo(0));
      expect(stats['test_operation']!['total_duration'], greaterThanOrEqualTo(0));
    });

    test('deve gerar relatório de performance', () {
      performanceMetrics.incrementCounter('test_metric');
      performanceMetrics.incrementCounter('test_event');
      performanceMetrics.logEvent('test_event', {'data': 'value'});
      
      final report = performanceMetrics.generateReport();
      
      expect(report, isNotEmpty);
      expect(report, contains('PERFORMANCE REPORT'));
      expect(report, contains('test_metric'));
      expect(report, contains('test_event'));
    });

    test('deve resetar métricas', () {
      performanceMetrics.incrementCounter('test_counter');
      performanceMetrics.incrementCounter('test_event');
      performanceMetrics.logEvent('test_event', {});
      
      var stats = performanceMetrics.getStatistics();
      expect(stats.isNotEmpty, isTrue);
      
      performanceMetrics.reset();
      
      stats = performanceMetrics.getStatistics();
      expect(stats.isEmpty, isTrue);
    });

    test('deve lidar com timers não iniciados', () {
      // Tenta parar um timer que não foi iniciado
      expect(() => performanceMetrics.stopTimer('non_existent'), returnsNormally);
    });

    test('deve lidar com múltiplos timers simultâneos', () {
      performanceMetrics.startTimer('timer1');
      performanceMetrics.startTimer('timer2');
      
      performanceMetrics.stopTimer('timer1');
      performanceMetrics.stopTimer('timer2');
      
      final stats = performanceMetrics.getStatistics();
      expect(stats.containsKey('timer1'), isTrue);
      expect(stats.containsKey('timer2'), isTrue);
    });
  });
}