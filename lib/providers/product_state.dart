import '../data/models/product.dart';

class ProductState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final List<Product> favorites;
  final Set<int> favoriteIds;
  final bool isLoading;
  final bool isLoadingFavorites;
  final String? error;
  final String searchQuery;
  final String? selectedCategory;
  final List<String> categories;

  const ProductState({
    required this.products,
    required this.filteredProducts,
    required this.favorites,
    required this.favoriteIds,
    required this.isLoading,
    required this.isLoadingFavorites,
    this.error,
    required this.searchQuery,
    this.selectedCategory,
    required this.categories,
  });

  /// Estado inicial
  factory ProductState.initial() {
    return const ProductState(
      products: [],
      filteredProducts: [],
      favorites: [],
      favoriteIds: {},
      isLoading: false,
      isLoadingFavorites: false,
      error: null,
      searchQuery: '',
      selectedCategory: null,
      categories: [],
    );
  }

  /// Cria cópia do estado com modificações
  ProductState copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    List<Product>? favorites,
    Set<int>? favoriteIds,
    bool? isLoading,
    bool? isLoadingFavorites,
    String? error,
    bool clearError = false,
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
    List<String>? categories,
  }) {
    return ProductState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      isLoadingFavorites: isLoadingFavorites ?? this.isLoadingFavorites,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      categories: categories ?? this.categories,
    );
  }

  /// Verifica se tem produtos
  bool get hasProducts => products.isNotEmpty;

  /// Verifica se tem favoritos
  bool get hasFavorites => favorites.isNotEmpty;

  /// Verifica se tem erro
  bool get hasError => error != null;

  /// Verifica se está buscando
  bool get isSearching => searchQuery.isNotEmpty;

  /// Verifica se tem filtro de categoria
  bool get hasCategory => selectedCategory != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductState &&
        other.products == products &&
        other.filteredProducts == filteredProducts &&
        other.favorites == favorites &&
        other.favoriteIds == favoriteIds &&
        other.isLoading == isLoading &&
        other.isLoadingFavorites == isLoadingFavorites &&
        other.error == error &&
        other.searchQuery == searchQuery &&
        other.selectedCategory == selectedCategory &&
        other.categories == categories;
  }

  @override
  int get hashCode {
    return Object.hash(
      products,
      filteredProducts,
      favorites,
      favoriteIds,
      isLoading,
      isLoadingFavorites,
      error,
      searchQuery,
      selectedCategory,
      categories,
    );
  }

  @override
  String toString() {
    return 'ProductState(products: ${products.length}, filteredProducts: ${filteredProducts.length}, favorites: ${favorites.length}, isLoading: $isLoading, error: $error, searchQuery: $searchQuery, selectedCategory: $selectedCategory)';
  }
}