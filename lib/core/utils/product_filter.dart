import '../../data/models/product.dart';

/// Classe utilitária para filtrar e ordenar produtos de forma eficiente
/// 
/// Esta classe fornece métodos estáticos para:
/// - Filtrar produtos por texto de busca
/// - Filtrar produtos por categoria
/// - Combinar múltiplos filtros simultaneamente
/// - Ordenar produtos por diferentes critérios
/// - Validar queries de busca
/// 
/// Todos os métodos são case-insensitive para melhor experiência do usuário
class ProductFilter {
  /// Filtra produtos aplicando critérios de busca e categoria simultaneamente
  /// 
  /// Este método:
  /// - Aplica filtro de texto no título do produto (case-insensitive)
  /// - Aplica filtro de categoria se especificada
  /// - Combina ambos os filtros quando aplicável
  /// - Valida e sanitiza a query de busca
  /// 
  /// [products] - Lista de produtos para filtrar
  /// [searchQuery] - Texto para buscar nos títulos (opcional)
  /// [selectedCategory] - Categoria para filtrar (opcional)
  /// 
  /// Retorna lista filtrada baseada nos critérios fornecidos
  static List<Product> filterProducts(
    List<Product> products, {
    String? searchQuery,
    String? selectedCategory,
  }) {
    var filtered = products;
    
    // Aplica filtro de busca apenas no título
    filtered = _applySearchFilter(filtered, searchQuery);
    
    // Aplica filtro de categoria se selecionada
    filtered = _applyCategoryFilter(filtered, selectedCategory);
    
    return filtered;
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
  
  /// Filtra produtos por categoria específica
  /// 
  /// Compara a categoria do produto com a categoria fornecida
  /// de forma case-insensitive para maior flexibilidade.
  /// 
  /// [products] - Lista de produtos para filtrar
  /// [selectedCategory] - Nome da categoria para filtrar
  /// 
  /// Retorna produtos que pertencem à categoria especificada
  static List<Product> _applyCategoryFilter(List<Product> products, String? selectedCategory) {
    if (selectedCategory == null || selectedCategory.isEmpty) {
      return products;
    }
    
    return products.where((product) => 
      product.category.toLowerCase() == selectedCategory.toLowerCase()
    ).toList();
  }
  
  /// Filtra produtos por múltiplos critérios avançados
  static List<Product> filterProductsAdvanced(
    List<Product> products, {
    String? searchQuery,
    String? selectedCategory,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? inStock,
  }) {
    var filtered = products;
    
    // Filtros básicos
    filtered = _applySearchFilter(filtered, searchQuery);
    filtered = _applyCategoryFilter(filtered, selectedCategory);
    
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
  
  /// Busca produtos por múltiplos campos (título, descrição, categoria)
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
      product.description.toLowerCase().contains(query) ||
      product.category.toLowerCase().contains(query)
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
      case ProductSortCriteria.category:
        sortedProducts.sort((a, b) => ascending 
          ? a.category.compareTo(b.category)
          : b.category.compareTo(a.category));
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
  category,
}