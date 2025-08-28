import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../data/services/api_service.dart';
import '../data/local/local_storage.dart';
import '../core/utils/helpers.dart';
import '../core/utils/constants.dart';
import '../core/utils/logger.dart';
import '../core/utils/toast_helper.dart';
import '../ui/widgets/enhanced_error_widget.dart';
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

  Future<void> _init() async {
    if (_isInitialized) return;
    
    try {
      _localStorage = await LocalStorage.getInstance();
      await loadFavorites();
      _isInitialized = true;
      AppLogger.success('Provider inicializado com sucesso', LogTags.provider);
    } catch (e) {
      AppLogger.error('Erro durante inicialização', e, null, LogTags.provider);
      try {
        _localStorage ??= await LocalStorage.getInstance();
        await loadFavorites();
        _isInitialized = true;
        AppLogger.success('Provider inicializado na segunda tentativa', LogTags.provider);
      } catch (localError) {
        AppLogger.error('Erro crítico ao inicializar local storage', localError, null, LogTags.provider);
        _isInitialized = false;
        // Notifica erro crítico para o usuário
        value = value.copyWith(error: 'Erro ao inicializar armazenamento local. Tente reiniciar o app.');
      }
    }
  }

  Future<void> initializeWithApi() async {
    await ensureInitialized();
    if (value.products.isEmpty) {
      await loadProducts();
      await loadCategories();
    }
  }

  Future<void> loadProducts([BuildContext? context]) async {
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
      String errorMessage;
      ErrorType errorType;
      
      if (e.toString().contains('SocketException') || 
          e.toString().contains('NetworkException')) {
        errorMessage = 'Sem conexão com a internet';
        errorType = ErrorType.network;
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Tempo limite excedido';
        errorType = ErrorType.timeout;
      } else if (e.toString().contains('500') || e.toString().contains('502')) {
        errorMessage = 'Servidor temporariamente indisponível';
        errorType = ErrorType.server;
      } else {
        errorMessage = 'Erro ao carregar produtos';
        errorType = ErrorType.generic;
      }
      
      value = value.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      
      if (context != null && context.mounted) {
        ToastHelper.showError(context, errorMessage);
      }
    }
  }

  /// Carrega categorias
  Future<void> loadCategories([BuildContext? context]) async {
    try {
      final categories = await _apiService.getCategories();
      value = value.copyWith(
        categories: categories,
        categoriesError: null,
      );
      AppLogger.success('${categories.length} categorias carregadas', LogTags.categories);
    } catch (e) {
      AppLogger.warning('Falha ao carregar categorias - continuando sem filtros', LogTags.categories);
      
      String errorMessage = 'Filtros por categoria indisponíveis';
      
      if (e.toString().contains('SocketException') || 
          e.toString().contains('NetworkException')) {
        errorMessage = 'Sem conexão para carregar categorias';
      }
      
      // Não é um erro crítico, mas informa o usuário sutilmente
      value = value.copyWith(
        categories: [], // Lista vazia para evitar null
        categoriesError: errorMessage
      );
      
      if (context != null && context.mounted) {
        ToastHelper.showWarning(context, errorMessage);
      }
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

  /// Carrega favoritos sem verificar conexão (para tela de favoritos)
  Future<void> loadFavoritesOnly() async {
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
      AppLogger.success('${favorites.length} favoritos carregados do armazenamento local', LogTags.favorites);
    } catch (e) {
      AppLogger.error('Erro ao carregar favoritos do armazenamento local', e, null, LogTags.favorites);
      value = value.copyWith(
        isLoadingFavorites: false,
        error: 'Erro ao carregar favoritos. Verifique o armazenamento do dispositivo.',
      );
    }
  }

  void searchProducts(String query) {
    // Atualiza imediatamente o searchQuery para mostrar feedback visual
    value = value.copyWith(searchQuery: query);
    
    // Aplica debounce apenas na filtragem para otimizar performance
    _searchDebouncer.run(() {
      value = value.copyWith(
        filteredProducts: _filterProducts(value.products),
      );
    });
  }

  void clearFilters() {
    // Cancela qualquer debounce pendente para evitar atualizações desnecessárias
    _searchDebouncer.cancel();
    
    value = value.copyWith(
      searchQuery: '',
      selectedCategory: null,
      clearCategory: true,
      filteredProducts: value.products,
    );
  }

  /// Adiciona/remove produto dos favoritos
  Future<void> toggleFavorite(Product product, [BuildContext? context]) async {
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
        
        if (context != null && context.mounted) {
          ToastHelper.showInfo(context, 'Removido dos favoritos');
        }
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
        AppLogger.info('Favoritos atualizados: ${newFavorites.length} itens', LogTags.favorites);
        
        if (context != null && context.mounted) {
          ToastHelper.showSuccess(context, 'Adicionado aos favoritos');
        }
      }
      
      final savedFavorites = await _localStorage!.loadFavorites();
      AppLogger.debug('Favoritos salvos no armazenamento: ${savedFavorites.length}', LogTags.favorites);
      
    } catch (e) {
      AppLogger.error('Erro ao alternar favorito', e, null, LogTags.favorites);
      value = value.copyWith(error: 'Erro ao atualizar favoritos. Tente novamente.');
      
      if (context != null && context.mounted) {
        ToastHelper.showError(
          context,
          'Erro ao salvar favorito. Tente novamente.',
        );
      }
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
      loadCategories(context),
    ]);
  }

  
  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;
    
    // Aplica filtro de busca apenas no título (não na categoria)
    if (value.searchQuery.isNotEmpty) {
      final query = value.searchQuery.toLowerCase().trim();
      if (query.isNotEmpty) {
        filtered = filtered.where((product) => 
          product.title.toLowerCase().contains(query)
        ).toList();
      }
    }
    
    // Aplica filtro de categoria se selecionada
    if (value.selectedCategory != null && value.selectedCategory!.isNotEmpty) {
      filtered = filtered.where((product) => 
        product.category.toLowerCase() == value.selectedCategory!.toLowerCase()
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