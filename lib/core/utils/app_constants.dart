/// Constantes da aplicação
class AppConstants {
  // Padding e espaçamentos
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  // Border radius
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Tamanhos de ícones
  static const double smallIconSize = 16.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 32.0;
  
  // Elevações
  static const double defaultElevation = 4.0;
  static const double smallElevation = 2.0;
  static const double largeElevation = 8.0;
  
  // Durações de animação
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Breakpoints responsivos
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;
  
  // Configurações de API
  static const String baseUrl = 'https://fakestoreapi.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Configurações de cache
  static const String favoritesKey = 'favorites';
  static const String searchHistoryKey = 'search_history';
  
  // Configurações de paginação
  static const int itemsPerPage = 20;
  static const int maxSearchHistory = 10;
  
  // Configurações de imagem
  static const double defaultImageAspectRatio = 1.0;
  static const double cardImageHeight = 200.0;
  static const double detailImageHeight = 300.0;
}