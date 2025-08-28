import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../data/services/api_service.dart';
import '../data/local/local_storage.dart';
import '../core/utils/helpers.dart';
import '../core/utils/constants.dart';
import '../core/utils/logger.dart';
import '../core/utils/toast_helper.dart';
import '../core/utils/error_handler.dart';
import '../core/utils/product_filter.dart';
import '../core/managers/favorites_manager.dart';
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
  /// 
  /// Este método é responsável por:
  /// - Inicializar o FavoritesManager
  /// - Carregar favoritos salvos localmente
  /// - Tratar erros de inicialização
  /// 
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
  
  /// Carrega favoritos durante a inicialização
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
      await loadCategories();
    }
  }

  /// Carrega produtos da API com tratamento de erro robusto
  /// 
  /// Este método:
  /// - Faz requisição para a API de produtos
  /// - Atualiza o estado com os produtos recebidos
  /// - Aplica filtros baseados na busca e categoria selecionada
  /// - Trata erros de rede e exibe feedback ao usuário
  /// - Resetar paginação para primeira página
  /// 
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
      final products = await _apiService.getProducts(
        limit: value.pageSize,
        offset: 0,
      );
      
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
      
      ErrorHandler.showErrorToast(context, errorInfo);
    }
  }

  /// Carrega mais produtos para scroll infinito
  /// 
  /// Este método:
  /// - Verifica se há mais produtos para carregar
  /// - Carrega próxima página de produtos
  /// - Adiciona novos produtos à lista existente
  /// - Atualiza estado de paginação
  Future<void> loadMoreProducts([BuildContext? context]) async {
    if (value.isLoadingMore || !value.hasMoreProducts || value.isLoading) return;
    
    value = value.copyWith(isLoadingMore: true);
    
    try {
      final offset = value.currentPage * value.pageSize;
      final newProducts = await _apiService.getProducts(
        limit: value.pageSize,
        offset: offset,
      );
      
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
      
      ErrorHandler.showErrorToast(context, errorInfo);
    }
  }

  /// Carrega categorias disponíveis da API
  /// 
  /// Este método:
  /// - Busca todas as categorias de produtos disponíveis
  /// - Atualiza o estado com a lista de categorias
  /// - Trata erros de rede com fallback gracioso
  /// 
  /// As categorias são usadas para filtrar produtos na interface
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
      
      final errorInfo = ErrorHandler.handleCategoryLoadError(e);
      
      // Não é um erro crítico, mas informa o usuário sutilmente
      value = value.copyWith(
        categories: [], // Lista vazia para evitar null
        categoriesError: errorInfo.message
      );
      
      if (context != null && context.mounted) {
        ToastHelper.showWarning(context, errorInfo.message);
      }
    }
  }

  Future<void> loadFavorites() async {
    await ensureInitialized();
    if (_favoritesManager == null) return;
    
    value = value.copyWith(isLoadingFavorites: true);
    
    final result = await _favoritesManager!.loadFavorites();
    
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

  /// Carrega favoritos sem verificar conexão (para tela de favoritos)
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
  /// 
  /// Este método:
  /// - Atualiza a query de busca no estado
  /// - Aplica filtro de texto nos títulos dos produtos
  /// - Combina com filtro de categoria se ativo
  /// - Atualiza a lista filtrada automaticamente
  /// 
  /// A busca é case-insensitive e busca por substring no título
  /// 
  /// [query] - Texto a ser buscado nos produtos
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

  /// Adiciona ou remove produto dos favoritos com persistência local
  /// 
  /// Este método:
  /// - Verifica se o produto já está nos favoritos
  /// - Delega a operação para o [FavoritesManager]
  /// - Atualiza o estado local após sucesso
  /// - Valida a consistência do armazenamento
  /// - Exibe feedback visual ao usuário
  /// 
  /// [product] - Produto a ser adicionado/removido
  /// [context] - Contexto para exibir toasts (opcional)
  Future<void> toggleFavorite(Product product, [BuildContext? context]) async {
    await ensureInitialized();
    if (_favoritesManager == null) {
      value = value.copyWith(error: 'Error initializing favorites');
      return;
    }
    
    final isFavorite = value.favoriteIds.contains(product.id);
    
    final result = isFavorite 
      ? await _favoritesManager!.removeFromFavorites(product.id, context)
      : await _favoritesManager!.addToFavorites(product, context);
    
    if (result.isSuccess) {
      _updateFavoritesState(product, result.isFavorite!);
      await _favoritesManager!.validateStorage();
    } else {
      value = value.copyWith(error: result.error);
    }
  }
  
  /// Atualiza o estado dos favoritos após toggle
  void _updateFavoritesState(Product product, bool isFavorite) {
    if (isFavorite) {
      // Adicionar aos favoritos
      final newFavorites = [...value.favorites, product];
      final newFavoriteIds = Set<int>.from(value.favoriteIds)..add(product.id);
      
      value = value.copyWith(
        favorites: newFavorites,
        favoriteIds: newFavoriteIds,
      );
    } else {
      // Remover dos favoritos
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
      loadCategories(context),
    ]);
  }

  /// Verifica se deve carregar mais produtos baseado na posição do scroll
  /// 
  /// [scrollController] - Controller do scroll para verificar posição
  /// [threshold] - Distância do final para começar a carregar (padrão: 200px)
  bool shouldLoadMore(ScrollController scrollController, {double threshold = 200.0}) {
    if (!scrollController.hasClients) return false;
    
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    
    return (maxScroll - currentScroll) <= threshold && 
           value.hasMoreProducts && 
           !value.isLoadingMore && 
           !value.isLoading;
  }

  
  /// Aplica filtros de busca e categoria aos produtos
  /// 
  /// Este método utiliza [ProductFilter] para:
  /// - Filtrar por texto de busca (título do produto)
  /// - Filtrar por categoria selecionada
  /// - Combinar múltiplos filtros quando aplicável
  /// 
  /// [products] - Lista de produtos para filtrar
  /// 
  /// Retorna lista filtrada baseada nos critérios ativos
  List<Product> _filterProducts(List<Product> products) {
    return ProductFilter.filterProducts(
      products,
      searchQuery: value.searchQuery,
      selectedCategory: value.selectedCategory,
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