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
  
  // Mensagens
  static const String errorGeneric = 'Algo deu errado. Tente novamente.';
  static const String errorNetwork = 'Erro de conexão. Verifique sua internet.';
  static const String errorNotFound = 'Produto não encontrado.';
  static const String emptyFavorites = 'Nenhum produto favoritado ainda.';
  static const String emptySearch = 'Nenhum produto encontrado.';
}