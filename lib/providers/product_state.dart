import '../data/models/product.dart';

class ProductState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final List<Product> favorites;
  final Set<int> favoriteIds;
  final bool isLoading;
  final bool isLoadingFavorites;
  final bool isLoadingMore;
  final bool hasMoreProducts;
  final int currentPage;
  final int pageSize;
  final String? error;
  final String searchQuery;

  const ProductState({
    required this.products,
    required this.filteredProducts,
    required this.favorites,
    required this.favoriteIds,
    required this.isLoading,
    required this.isLoadingFavorites,
    required this.isLoadingMore,
    required this.hasMoreProducts,
    required this.currentPage,
    required this.pageSize,
    this.error,
    required this.searchQuery,
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
      isLoadingMore: false,
      hasMoreProducts: true,
      currentPage: 0,
      pageSize: 10,
      error: null,
      searchQuery: '',
    );
  }

  /// Cria uma cópia do estado com modificações
  ProductState copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    List<Product>? favorites,
    Set<int>? favoriteIds,
    bool? isLoading,
    bool? isLoadingFavorites,
    bool? isLoadingMore,
    bool? hasMoreProducts,
    int? currentPage,
    int? pageSize,
    String? error,
    bool clearError = false,
    String? searchQuery,
  }) {
    return ProductState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      isLoadingFavorites: isLoadingFavorites ?? this.isLoadingFavorites,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreProducts: hasMoreProducts ?? this.hasMoreProducts,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Verifica se há produtos
  bool get hasProducts => products.isNotEmpty;

  /// Verifica se há favoritos
  bool get hasFavorites => favorites.isNotEmpty;

  /// Verifica se há erro
  bool get hasError => error != null;

  /// Verifica se está pesquisando
  bool get isSearching => searchQuery.isNotEmpty;



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
        other.isLoadingMore == isLoadingMore &&
        other.hasMoreProducts == hasMoreProducts &&
        other.currentPage == currentPage &&
        other.pageSize == pageSize &&
        other.error == error &&
        other.searchQuery == searchQuery;
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
      isLoadingMore,
      hasMoreProducts,
      currentPage,
      pageSize,
      error,
      searchQuery,
    );
  }

  @override
  String toString() {
    return 'ProductState(products: ${products.length}, filteredProducts: ${filteredProducts.length}, favorites: ${favorites.length}, isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasMoreProducts: $hasMoreProducts, currentPage: $currentPage, error: $error, searchQuery: $searchQuery)';
  }
}
