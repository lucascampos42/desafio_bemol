import '../../data/models/product.dart';

/// Classe utilitária para filtrar e ordenar produtos de forma eficiente
/// 
/// Esta classe fornece métodos estáticos para:
/// - Filtrar produtos por texto de busca no título
/// - Ordenar produtos por diferentes critérios
/// - Validar queries de busca
/// 
/// Todos os métodos são case-insensitive para melhor experiência do usuário
/// 
/// Nota: A API não fornece filtro por categoria, apenas busca por título
class ProductFilter {
  /// Filtra produtos por texto de busca no título
  /// 
  /// - Aplica filtro de texto no título do produto (case-insensitive)
  /// - Valida e sanitiza a query de busca
  /// 
  /// [products] - Lista de produtos para filtrar
  /// [searchQuery] - Texto para buscar nos títulos (opcional)
  /// 
  /// Retorna lista filtrada baseada no critério de busca
  static List<Product> filterProducts(
    List<Product> products, {
    String? searchQuery,
  }) {
    return _applySearchFilter(products, searchQuery);
  }
  
  /// Filtra produtos por texto de busca no título
  /// 
  /// Realiza busca case-insensitive por substring no título do produto.
  /// A query é sanitizada removendo espaços extras.
  /// 
  /// [products] - Lista de produtos para filtrar
  /// [searchQuery] - Texto a ser buscado nos títulos
  /// 
  /// Retorna produtos cujos títulos contêm a query
  static List<Product> _applySearchFilter(List<Product> products, String? searchQuery) {
    if (searchQuery == null || searchQuery.isEmpty) {
      return products;
    }
    
    final query = searchQuery.toLowerCase().trim();
    if (query.isEmpty) {
      return products;
    }
    
    return products.where((product) => 
      product.title.toLowerCase().contains(query)
    ).toList();
  }
  

  
  /// Filtra produtos por múltiplos critérios (apenas busca por título e filtros de preço/rating)
  /// 
  /// Nota: Filtro por categoria removido pois a API não suporta esta funcionalidade
  static List<Product> filterProductsAdvanced(
    List<Product> products, {
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) {
    var filtered = products;
    
    // Filtro de busca por título
    filtered = _applySearchFilter(filtered, searchQuery);
    
    // Filtro por preço mínimo
    if (minPrice != null) {
      filtered = filtered.where((product) => product.price >= minPrice).toList();
    }
    
    // Filtro por preço máximo
    if (maxPrice != null) {
      filtered = filtered.where((product) => product.price <= maxPrice).toList();
    }
    
    // Filtro por rating mínimo
    if (minRating != null) {
      filtered = filtered.where((product) => product.rating.rate >= minRating).toList();
    }
    
    return filtered;
  }
  
  /// Busca produtos por múltiplos campos (título e descrição)
  /// 
  /// Nota: Busca por categoria removida pois a API não suporta filtro por categoria
  static List<Product> searchInAllFields(
    List<Product> products,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) {
      return products;
    }
    
    final query = searchQuery.toLowerCase().trim();
    if (query.isEmpty) {
      return products;
    }
    
    return products.where((product) => 
      product.title.toLowerCase().contains(query) ||
      product.description.toLowerCase().contains(query)
    ).toList();
  }
  
  /// Ordena produtos por critério específico
  static List<Product> sortProducts(
    List<Product> products,
    ProductSortCriteria criteria, {
    bool ascending = true,
  }) {
    final sortedProducts = List<Product>.from(products);
    
    switch (criteria) {
      case ProductSortCriteria.name:
        sortedProducts.sort((a, b) => ascending 
          ? a.title.compareTo(b.title)
          : b.title.compareTo(a.title));
        break;
      case ProductSortCriteria.price:
        sortedProducts.sort((a, b) => ascending 
          ? a.price.compareTo(b.price)
          : b.price.compareTo(a.price));
        break;
      case ProductSortCriteria.rating:
        sortedProducts.sort((a, b) => ascending 
          ? a.rating.rate.compareTo(b.rating.rate)
          : b.rating.rate.compareTo(a.rating.rate));
        break;

    }
    
    return sortedProducts;
  }
  
  /// Valida se uma query de busca é válida
  static bool isValidSearchQuery(String? query) {
    if (query == null) return false;
    final trimmed = query.trim();
    return trimmed.isNotEmpty && trimmed.length >= 2;
  }
  
  /// Limpa e normaliza uma query de busca
  static String normalizeSearchQuery(String query) {
    return query.toLowerCase().trim();
  }
}

/// Critérios de ordenação para produtos
enum ProductSortCriteria {
  name,
  price,
  rating,
}