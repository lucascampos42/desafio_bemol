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
  bool _isInitialized = false;

  ProductProvider({
    ApiService? apiService,
  }) : _apiService = apiService ?? ApiService.instance,
       _searchDebouncer = Debouncer(milliseconds: AppConstants.searchDebounceMs),
       super(ProductState.initial()) {
    _init();
  }

  bool get isInitialized => _isInitialized;

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _init();
    }
  }

  /// Inicialização do provider
  Future<void> _init() async {
    if (_isInitialized) return;
    
    try {
      _localStorage = await LocalStorage.getInstance();
      await loadFavorites();
      await loadProducts();
      await loadCategories();
      _isInitialized = true;
    } catch (e) {
      print('Error during initialization: $e');
      // Garante que pelo menos o localStorage seja inicializado
      try {
        _localStorage ??= await LocalStorage.getInstance();
        await loadFavorites();
        _isInitialized = true;
      } catch (localError) {
        print('Error initializing local storage: $localError');
        _isInitialized = false;
      }
    }
  }

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
      print('Error loading categories: $e');
    }
  }

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
        clearError: true,
      );
    } catch (e) {
      print('Error loading favorites: $e');
      value = value.copyWith(
        isLoadingFavorites: false,
        error: 'Error loading favorites: $e',
      );
    }
  }

  void searchProducts(String query) {
    _searchDebouncer.run(() {
      value = value.copyWith(
        searchQuery: query,
        filteredProducts: _filterProducts(value.products),
      );
    });
  }

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
      print('🔄 toggleFavorite called for product: ${product.title} (ID: ${product.id})');
      _localStorage ??= await LocalStorage.getInstance();
      final isFavorite = value.favoriteIds.contains(product.id);
      print('📋 Current favorites count: ${value.favorites.length}');
      print('❤️ Is currently favorite: $isFavorite');
      
      if (isFavorite) {
        print('➖ Removing from favorites...');
        final success = await _localStorage!.removeFromFavorites(product.id);
        print('✅ Remove operation success: $success');
        
        final newFavorites = value.favorites.where((p) => p.id != product.id).toList();
        final newFavoriteIds = Set<int>.from(value.favoriteIds)..remove(product.id);
        
        value = value.copyWith(
          favorites: newFavorites,
          favoriteIds: newFavoriteIds,
        );
        print('📊 New favorites count: ${newFavorites.length}');
      } else {
        print('➕ Adding to favorites...');
        final success = await _localStorage!.addToFavorites(product);
        print('✅ Add operation success: $success');
        
        final newFavorites = [...value.favorites, product];
        final newFavoriteIds = Set<int>.from(value.favoriteIds)..add(product.id);
        
        value = value.copyWith(
          favorites: newFavorites,
          favoriteIds: newFavoriteIds,
        );
        print('📊 New favorites count: ${newFavorites.length}');
      }
      
      final savedFavorites = await _localStorage!.loadFavorites();
      print('💾 Saved favorites count in storage: ${savedFavorites.length}');
      
    } catch (e) {
      print('❌ Error in toggleFavorite: $e');
      value = value.copyWith(error: 'Error updating favorites: $e');
    }
  }

  bool isFavorite(int productId) {
    return value.favoriteIds.contains(productId);
  }

  Product? getProductById(int id) {
    try {
      return value.products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> refresh() async {
    await Future.wait([
      loadProducts(),
      loadFavorites(),
      loadCategories(),
    ]);
  }

  
  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;
    
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

  void clearError() {
    value = value.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }
}