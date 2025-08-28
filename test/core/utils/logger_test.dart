import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:desafio_bemol/core/utils/logger.dart';

void main() {
  group('AppLogger Tests', () {
    setUp(() {
      // Reset debug mode for each test
      debugDefaultTargetPlatformOverride = null;
    });

    test('should call info method without errors', () {
      expect(() => AppLogger.info('Test message', LogTags.api), returnsNormally);
    });

    test('should call error method without errors', () {
      expect(() => AppLogger.error('Test error', null, null, LogTags.api), returnsNormally);
    });

    test('should call warning method without errors', () {
      expect(() => AppLogger.warning('Test warning', LogTags.api), returnsNormally);
    });

    test('should call debug method without errors', () {
      expect(() => AppLogger.debug('Test debug', LogTags.api), returnsNormally);
    });

    test('should call success method without errors', () {
      expect(() => AppLogger.success('Test success', LogTags.api), returnsNormally);
    });

    test('should handle null tag gracefully', () {
      expect(() => AppLogger.info('Test message', null), returnsNormally);
      expect(() => AppLogger.error('Test error', null, null, null), returnsNormally);
      expect(() => AppLogger.warning('Test warning', null), returnsNormally);
      expect(() => AppLogger.debug('Test debug', null), returnsNormally);
      expect(() => AppLogger.success('Test success', null), returnsNormally);
    });

    test('should handle empty message', () {
      expect(() => AppLogger.info('', LogTags.api), returnsNormally);
      expect(() => AppLogger.error('', null, null, LogTags.api), returnsNormally);
    });

    test('should handle special characters in message', () {
      const message = 'Test with special chars: @#\$%^&*()';
      expect(() => AppLogger.info(message, LogTags.api), returnsNormally);
    });

    test('should handle error with exception and stack trace', () {
      final exception = Exception('Test exception');
      final stackTrace = StackTrace.current;
      
      expect(() => AppLogger.error(
        'Test error with details',
        exception,
        stackTrace,
        LogTags.api,
      ), returnsNormally);
    });

    group('Log Tags', () {
      test('should have all required log tags', () {
        expect(LogTags.api, isNotEmpty);
        expect(LogTags.storage, isNotEmpty);
        expect(LogTags.provider, isNotEmpty);
        expect(LogTags.ui, isNotEmpty);
        expect(LogTags.favorites, isNotEmpty);
        expect(LogTags.categories, isNotEmpty);
        expect(LogTags.search, isNotEmpty);
      });

      test('should have unique log tags', () {
        final tags = [
          LogTags.api,
          LogTags.storage,
          LogTags.provider,
          LogTags.ui,
          LogTags.favorites,
          LogTags.categories,
          LogTags.search,
        ];
        
        final uniqueTags = tags.toSet();
        expect(uniqueTags.length, equals(tags.length));
      });

      test('should have correct tag values', () {
        expect(LogTags.api, equals('API'));
        expect(LogTags.storage, equals('STORAGE'));
        expect(LogTags.provider, equals('PROVIDER'));
        expect(LogTags.ui, equals('UI'));
        expect(LogTags.favorites, equals('FAVORITES'));
        expect(LogTags.categories, equals('CATEGORIES'));
        expect(LogTags.search, equals('SEARCH'));
      });
    });

    group('Method Parameters', () {
      test('info method should accept optional tag', () {
        expect(() => AppLogger.info('Test info'), returnsNormally);
        expect(() => AppLogger.info('Test info', LogTags.api), returnsNormally);
      });

      test('error method should accept optional parameters', () {
        expect(() => AppLogger.error('Test error'), returnsNormally);
        expect(() => AppLogger.error('Test error', Exception('test')), returnsNormally);
        expect(() => AppLogger.error('Test error', null, StackTrace.current), returnsNormally);
        expect(() => AppLogger.error('Test error', null, null, LogTags.api), returnsNormally);
      });

      test('warning method should accept optional tag', () {
        expect(() => AppLogger.warning('Test warning'), returnsNormally);
        expect(() => AppLogger.warning('Test warning', LogTags.api), returnsNormally);
      });

      test('debug method should accept optional tag', () {
        expect(() => AppLogger.debug('Test debug'), returnsNormally);
        expect(() => AppLogger.debug('Test debug', LogTags.api), returnsNormally);
      });

      test('success method should accept optional tag', () {
        expect(() => AppLogger.success('Test success'), returnsNormally);
        expect(() => AppLogger.success('Test success', LogTags.api), returnsNormally);
      });
    });
  });
}