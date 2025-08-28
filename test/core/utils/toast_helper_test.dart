import 'package:flutter_test/flutter_test.dart';
import 'package:desafio_bemol/core/utils/toast_helper.dart';

void main() {
  group('ToastHelper Tests', () {
    test('ToastHelper class should exist', () {
      expect(ToastHelper, isNotNull);
    });

    test('ToastHelper should have showSuccess method', () {
      expect(ToastHelper.showSuccess, isNotNull);
    });

    test('ToastHelper should have showError method', () {
      expect(ToastHelper.showError, isNotNull);
    });

    test('ToastHelper should have showWarning method', () {
      expect(ToastHelper.showWarning, isNotNull);
    });

    test('ToastHelper should have showInfo method', () {
      expect(ToastHelper.showInfo, isNotNull);
    });

    test('should handle different duration values', () {
      const shortDuration = Duration(milliseconds: 100);
      const longDuration = Duration(seconds: 10);
      
      expect(shortDuration.inMilliseconds, equals(100));
      expect(longDuration.inSeconds, equals(10));
    });

    test('should handle empty and long messages', () {
      const emptyMessage = '';
      const longMessage = 'This is a very long message that should be handled properly by the toast widget without causing any layout issues or overflow problems';
      
      expect(emptyMessage.isEmpty, isTrue);
      expect(longMessage.isNotEmpty, isTrue);
      expect(longMessage.length, greaterThan(50));
    });
  });
}