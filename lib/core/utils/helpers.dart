import 'dart:async';
import 'package:flutter/foundation.dart';

class Helpers {
  static String formatPrice(double price) =>
    '\$${price.toStringAsFixed(2).replaceAll('.', ',')}';

  static String formatRating(double rating) => rating.toStringAsFixed(1);

  static String truncateText(String text, int maxLength) => 
    text.length <= maxLength ? text : '${text.substring(0, maxLength)}...';

  static String capitalize(String text) => 
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1).toLowerCase();
  
  static bool isNotEmpty(String? text) =>
    text != null && text.trim().isNotEmpty;
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
  }
}
