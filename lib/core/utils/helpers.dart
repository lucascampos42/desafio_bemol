import 'dart:async';
import 'package:flutter/foundation.dart';

class Helpers {
  /// Formata preço para exibição
  static String formatPrice(double price) {
    return 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
  }
  
  /// Formata rating para exibição
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }
  
  /// Trunca texto se necessário
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Capitaliza primeira letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Valida se string não é nula ou vazia
  static bool isNotEmpty(String? text) {
    return text != null && text.trim().isNotEmpty;
  }
}

/// Classe para debounce em buscas
class Debouncer {
  final int milliseconds;
  Timer? _timer;
  
  Debouncer({required this.milliseconds});
  
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
  
  void dispose() {
    _timer?.cancel();
  }
}