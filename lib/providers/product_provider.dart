import 'package:flutter/foundation.dart';
import '../data/models/product.dart';
import '../data/services/api_service.dart';
import '../data/local/local_storage.dart';
import '../core/utils/helpers.dart';
import '../core/utils/constants.dart';
import 'product_state.dart';

class ProductProvider extends ValueNotifier<ProductState> {
  final ApiService _apiService;
  LocalStorage? _localStorage;
  final Debouncer _searchDebouncer;

  ProductProvider({
    ApiService? apiService,
  }) : _apiService = apiService ?? ApiService.instance,
       _searchDebouncer = Debouncer(milliseconds: AppConstants.searchDebounceMs),
       super(ProductState.initial()) {
    _init();
  }

  /// Inicialização do provider
  Future<void> _init() async {
    _localStorage = await LocalStorage.getInstance();
    await loadFavorites();
    await loadProducts();
    await loadCategories();
  }

  /// Carrega todos os produtos
  Future<void> loadProducts() async {
    if (value.isLoading) return;
    
    value = value.copyWith(isLoading: true, clearError: true);
    
    try {
      final products = await _apiService.getProducts();
      value = value.copyWith(
        products: products,
        filteredProducts: _filterProducts(products),
        isLoading: false,
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Carrega categorias
  Future<void> loadCategories() async {
    try {
      final categories = await _apiService.getCategories();
      value = value.copyWith(categories: categories);
    } catch (e) {
      // Erro silencioso para categorias
      print('Erro ao carregar categorias: $e');
    }
  }

  /// Carrega favoritos do storage local
  Future<void> loadFavorites() async {
    value = value.copyWith(isLoadingFavorites: true);
    
    try {
      _localStorage ??= await LocalStorage.getInstance();
      final favorites = await _localStorage!.loadFavorites();
      final favoriteIds = favorites.map((p) => p.id).toSet();
      
      value = value.copyWith(
        favorites: favorites,
        favoriteIds: favoriteIds,
        isLoadingFavorites: false,
      );
    } catch (e) {
      value = value.copyWith(
        isLoadingFavorites: false,
        error: 'Erro ao carregar favoritos: $e',
      );
    }
  }

  /// Busca produtos com debounce
  void searchProducts(String query) {
    _searchDebouncer.run(() {
      value = value.copyWith(
        searchQuery: query,
        filteredProducts: _filterProducts(value.products),
      );
    });
  }

  /// Filtra por categoria
  void filterByCategory(String? category) {
    value = value.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
      filteredProducts: _filterProducts(value.products),
    );
  }

  /// Limpa filtros
  void clearFilters() {
    value = value.copyWith(
      searchQuery: '',
      selectedCategory: null,
      clearCategory: true,
      filteredProducts: value.products,
    );
  }

  /// Adiciona/remove produto dos favoritos
  Future<void> toggleFavorite(Product product) async {
    try {
      _localStorage ??= await LocalStorage.getInstance();
      final isFavorite = value.favoriteIds.contains(product.id);
      
      if (isFavorite) {
        await _localStorage!.removeFromFavorites(product.id);
        final newFavorites = value.favorites.where((p) => p.id != product.id).toList();
        final newFavoriteIds = Set<int>.from(value.favoriteIds)..remove(product.id);
        
        value = value.copyWith(
          favorites: newFavorites,
          favoriteIds: newFavoriteIds,
        );
      } else {
        await _localStorage!.addToFavorites(product);
        final newFavorites = [...value.favorites, product];
        final newFavoriteIds = Set<int>.from(value.favoriteIds)..add(product.id);
        
        value = value.copyWith(
          favorites: newFavorites,
          favoriteIds: newFavoriteIds,
        );
      }
    } catch (e) {
      value = value.copyWith(error: 'Erro ao atualizar favoritos: $e');
    }
  }

  /// Verifica se produto é favorito
  bool isFavorite(int productId) {
    return value.favoriteIds.contains(productId);
  }

  /// Busca produto por ID
  Product? getProductById(int id) {
    try {
      return value.products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Recarrega dados
  Future<void> refresh() async {
    await Future.wait([
      loadProducts(),
      loadFavorites(),
      loadCategories(),
    ]);
  }

  /// Filtra produtos baseado na busca e categoria
  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;
    
    // Filtro por categoria
    if (value.selectedCategory != null) {
      filtered = filtered.where((product) => 
        product.category.toLowerCase() == value.selectedCategory!.toLowerCase()
      ).toList();
    }
    
    // Filtro por busca
    if (value.searchQuery.isNotEmpty) {
      final query = value.searchQuery.toLowerCase();
      filtered = filtered.where((product) => 
        product.title.toLowerCase().contains(query) ||
        product.description.toLowerCase().contains(query) ||
        product.category.toLowerCase().contains(query)
      ).toList();
    }
    
    return filtered;
  }

  /// Limpa erro
  void clearError() {
    value = value.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }
}