import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../data/services/api_service.dart';
import '../data/local/local_storage.dart';
import '../core/utils/helpers.dart';
import '../core/utils/constants.dart';
import '../core/utils/logger.dart';
import '../core/utils/error_handler.dart';
import '../core/utils/product_filter.dart';
import '../core/managers/favorites_manager.dart';
import '../core/utils/performance_metrics.dart';
import 'product_state.dart';

class ProductProvider extends ValueNotifier<ProductState> {
  final ApiService _apiService;
  LocalStorage? _localStorage;
  FavoritesManager? _favoritesManager;
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

  /// Inicializa o provider carregando dados essenciais
  /// Deve ser chamado antes de qualquer operação que dependa do estado inicial
  Future<void> _init() async {
    if (_isInitialized) return;
    
    try {
      _localStorage = await LocalStorage.getInstance();
      _favoritesManager = FavoritesManager(_localStorage!);
      await _loadInitialFavorites();
      _isInitialized = true;
      AppLogger.success('Provider inicializado com sucesso', LogTags.provider);
    } catch (e) {
      AppLogger.error('Erro durante inicialização', e, null, LogTags.provider);
      await _handleInitializationError();
    }
  }
  
  /// Tenta recuperar de erro de inicialização
  Future<void> _handleInitializationError() async {
    try {
      _localStorage ??= await LocalStorage.getInstance();
      _favoritesManager ??= FavoritesManager(_localStorage!);
      await _loadInitialFavorites();
      _isInitialized = true;
      AppLogger.success('Provider inicializado na segunda tentativa', LogTags.provider);
    } catch (localError) {
      AppLogger.error('Erro crítico ao inicializar local storage', localError, null, LogTags.provider);
      _isInitialized = false;
      value = value.copyWith(error: 'Error initializing local storage. Try restarting the app.');
    }
  }
  

  Future<void> _loadInitialFavorites() async {
    if (_favoritesManager == null) return;
    
    final result = await _favoritesManager!.loadFavorites();
    if (result.isSuccess) {
      value = value.copyWith(
        favorites: result.favorites!,
        favoriteIds: result.favoriteIds!,
        clearError: true,
      );
    }
  }

  Future<void> initializeWithApi() async {
    await ensureInitialized();
    if (value.products.isEmpty) {
      await loadProducts();
    }
  }

  /// Carrega produtos da API com tratamento de erro robusto
  /// Utiliza [ErrorHandler] para tratamento centralizado de exceções
  Future<void> loadProducts([BuildContext? context]) async {
    if (value.isLoading) return;
    
    value = value.copyWith(
      isLoading: true, 
      clearError: true,
      currentPage: 0,
      hasMoreProducts: true,
    );
    
    try {
      final products = await PerformanceMetrics.instance.measureAsync(
        'load_products',
        () => _apiService.getProducts(
          limit: value.pageSize,
          offset: 0,
        ),
      );
      
      PerformanceMetrics.instance.trackApiCall('products', 'success');
      
      value = value.copyWith(
        products: products,
        filteredProducts: _filterProducts(products),
        isLoading: false,
        currentPage: 1,
        hasMoreProducts: products.length >= value.pageSize,
      );
    } catch (e) {
      final errorInfo = ErrorHandler.handleProductLoadError(e);
      
      value = value.copyWith(
        isLoading: false,
        error: errorInfo.message,
      );
      
      if (context != null && context.mounted) {
        ErrorHandler.showErrorToast(context, errorInfo);
      }
    }
  }

  /// Carrega mais produtos para scroll infinito
  Future<void> loadMoreProducts([BuildContext? context]) async {
    if (value.isLoadingMore || !value.hasMoreProducts || value.isLoading) return;
    
    value = value.copyWith(isLoadingMore: true);
    
    try {
      final offset = value.currentPage * value.pageSize;
      final newProducts = await PerformanceMetrics.instance.measureAsync(
        'load_more_products',
        () => _apiService.getProducts(
          limit: value.pageSize,
          offset: offset,
        ),
      );
      
      PerformanceMetrics.instance.trackApiCall('products_pagination', 'success');
      
      final allProducts = [...value.products, ...newProducts];
      
      value = value.copyWith(
        products: allProducts,
        filteredProducts: _filterProducts(allProducts),
        isLoadingMore: false,
        currentPage: value.currentPage + 1,
        hasMoreProducts: newProducts.length >= value.pageSize,
      );
    } catch (e) {
      final errorInfo = ErrorHandler.handleProductLoadError(e);
      
      value = value.copyWith(
        isLoadingMore: false,
        error: errorInfo.message,
      );
      
      if (context != null && context.mounted) {
        ErrorHandler.showErrorToast(context, errorInfo);
      }
    }
  }



  Future<void> loadFavorites() async {
    await ensureInitialized();
    if (_favoritesManager == null) return;
    
    value = value.copyWith(isLoadingFavorites: true);
    
    final result = await PerformanceMetrics.instance.measureAsync(
      'load_favorites',
      () => _favoritesManager!.loadFavorites(),
    );
    
    if (result.isSuccess) {
      value = value.copyWith(
        favorites: result.favorites!,
        favoriteIds: result.favoriteIds!,
        isLoadingFavorites: false,
        clearError: true,
      );
    } else {
      value = value.copyWith(
        isLoadingFavorites: false,
        error: result.error,
      );
    }
  }


  Future<void> loadFavoritesOnly() async {
    await ensureInitialized();
    if (_favoritesManager == null) return;
    
    value = value.copyWith(isLoadingFavorites: true);
    
    final result = await _favoritesManager!.loadFavorites();
    
    if (result.isSuccess) {
      value = value.copyWith(
        favorites: result.favorites!,
        favoriteIds: result.favoriteIds!,
        isLoadingFavorites: false,
      );
    } else {
      value = value.copyWith(
        isLoadingFavorites: false,
        error: result.error,
      );
    }
  }

  /// Realiza busca em tempo real nos produtos carregados
  /// A busca é case-insensitive e busca por substring no título
  void searchProducts(String query) {
    PerformanceMetrics.instance.trackSearchAction(query);
    
    // Atualiza imediatamente o searchQuery para mostrar feedback visual
    value = value.copyWith(searchQuery: query);
    
    // Aplica debounce apenas na filtragem para otimizar performance
    _searchDebouncer.run(() {
      PerformanceMetrics.instance.measure('search_filter', () {
        value = value.copyWith(
          filteredProducts: _filterProducts(value.products),
        );
      });
    });
  }

  void clearFilters() {
    // Cancela qualquer debounce pendente para evitar atualizações desnecessárias
    _searchDebouncer.cancel();
    
    value = value.copyWith(
      searchQuery: '',
      filteredProducts: value.products,
    );
  }

  /// Adiciona ou remove produto dos favoritos com persistência local
  /// Valida a consistência do armazenamento e exibe feedback visual ao usuário
  Future<void> toggleFavorite(Product product, [BuildContext? context]) async {
    await ensureInitialized();
    if (_favoritesManager == null) {
      value = value.copyWith(error: 'Error initializing favorites');
      return;
    }
    
    final isFavorite = value.favoriteIds.contains(product.id);
    
    final result = await PerformanceMetrics.instance.measureAsync(
      'toggle_favorite',
      () async {
        return isFavorite 
          ? await _favoritesManager!.removeFromFavorites(product.id, context)
          : await _favoritesManager!.addToFavorites(product, context);
      },
    );
    
    PerformanceMetrics.instance.trackFavoriteAction(
      product.id, 
      isFavorite ? 'remove' : 'add'
    );
    
    if (result.isSuccess) {
      _updateFavoritesState(product, result.isFavorite!);
      await _favoritesManager!.validateStorage();
    } else {
      value = value.copyWith(error: result.error);
    }
  }
  

  void _updateFavoritesState(Product product, bool isFavorite) {
    if (isFavorite) {
      final newFavorites = [...value.favorites, product];
      final newFavoriteIds = Set<int>.from(value.favoriteIds)..add(product.id);
      
      value = value.copyWith(
        favorites: newFavorites,
        favoriteIds: newFavoriteIds,
      );
    } else {
      final newFavorites = value.favorites.where((p) => p.id != product.id).toList();
      final newFavoriteIds = Set<int>.from(value.favoriteIds)..remove(product.id);
      
      value = value.copyWith(
        favorites: newFavorites,
        favoriteIds: newFavoriteIds,
      );
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

  Future<void> refresh([BuildContext? context]) async {
    await Future.wait([
      loadProducts(context),
      loadFavorites(),
    ]);
  }

  /// Verifica se deve carregar mais produtos baseado na posição do scroll
  bool shouldLoadMore(ScrollController scrollController, {double threshold = 200.0}) {
    if (!scrollController.hasClients) return false;
    
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    
    return (maxScroll - currentScroll) <= threshold && 
           value.hasMoreProducts && 
           !value.isLoadingMore && 
           !value.isLoading;
  }

  
  /// Aplica filtros de busca aos produtos
  List<Product> _filterProducts(List<Product> products) {
    return ProductFilter.filterProducts(
      products,
      searchQuery: value.searchQuery,
    );
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
