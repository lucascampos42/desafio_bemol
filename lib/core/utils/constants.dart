class AppConstants {
  // API
  static const String baseUrl = 'https://fakestoreapi.com';
  static const String productsEndpoint = '/products';
  
  // SharedPreferences Keys
  static const String favoritesKey = 'favorites';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000; // 30 segundos
  
  // Debounce
  static const int searchDebounceMs = 500; // 500ms para busca
  
  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  
  // Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Connection error. Check your internet.';
  static const String notFoundError = 'Product not found.';
  static const String emptyFavoritesMessage = 'No favorite products yet.';
  static const String emptySearchMessage = 'No products found.';
}