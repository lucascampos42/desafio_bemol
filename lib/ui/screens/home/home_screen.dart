import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/product_list_widget.dart';
import '../../widgets/favorites_badge_widget.dart';
import '../../widgets/category_error_widget.dart';
import '../product_detail/product_detail_screen.dart';
import '../favorites/favorites_screen.dart';
import '../error/error_screen.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/performance_metrics.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProductProvider _productProvider;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _productProvider = ProductProvider();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScrollChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      await _productProvider.ensureInitialized();
      await _productProvider.initializeWithApi();
      if (mounted) {
        await _productProvider.loadCategories(context);
      }
    } catch (e) {
      debugPrint('Error during app initialization: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ErrorScreen()),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _scrollController.removeListener(_onScrollChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _productProvider.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _productProvider.searchProducts(_searchController.text);
  }

  void _onScrollChanged() {
    if (_productProvider.shouldLoadMore(_scrollController)) {
      _productProvider.loadMoreProducts(context);
    }
  }

  void _navigateToProductDetail(Product product) {
    PerformanceMetrics.instance.trackScreenNavigation(
      'home_to_product_detail',
      {'product_id': product.id.toString()},
    );
    
    Navigator.push(
      context,
      AppAnimations.createRoute(
        page: ProductDetailScreen(
          product: product,
          productProvider: _productProvider,
        ),
      ),
    );
  }

  void _navigateToFavorites() {
    PerformanceMetrics.instance.trackScreenNavigation(
      'home_to_favorites',
      {'favorites_count': _productProvider.value.favorites.length.toString()},
    );
    
    _productProvider.clearError();
    Navigator.push(
      context,
      AppAnimations.createRoute(
        page: FavoritesScreen(
          productProvider: _productProvider,
        ),
      ),
    ).then((_) {
      if (mounted) {
        _productProvider.refresh();
      }
    });
  }



  void _clearFilters() {
    _searchController.clear();
    _productProvider.clearFilters();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
        centerTitle: false,
        actions: [
          ValueListenableBuilder(
            valueListenable: _productProvider,
            builder: (context, state, child) {
              return FavoritesBadgeWidget(
                onTap: _navigateToFavorites,
                hasFavorites: state.hasFavorites,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isInitializing
            ? Center(
                child: AppAnimations.fadeIn(
                  child: const AnimatedLoadingWidget(
                    message: 'Initializing app...',
                    size: 50,
                  ),
                ),
              )
            : ValueListenableBuilder(
                valueListenable: _productProvider,
                builder: (context, state, child) {
                  if (state.hasError && !state.hasProducts) {
                    return Center(
                      child: AppAnimations.scaleIn(
                        child: Image.asset(
                          'assets/images/empty.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => _productProvider.refresh(context),
                    child: Column(
                      children: [
                        SearchBarWidget(
                          controller: _searchController,
                          isSearching: state.isSearching,
                          onClear: _clearFilters,
                        ),
                        // Exibe erro de categorias se houver
                        if (state.hasCategoriesError)
                          CategoryErrorWidget(
                            message: state.categoriesError!,
                            onRetry: () => _productProvider.loadCategories(context),
                            isCompact: true,
                          ),
                        Expanded(
                          child: ProductListWidget(
                            state: state,
                            scrollController: _scrollController,
                            onProductTap: _navigateToProductDetail,
                            onFavoriteToggle: (product, context) => _productProvider.toggleFavorite(product, context),
                            isFavorite: _productProvider.isFavorite,
                            onRefresh: () => _productProvider.refresh(context),
                            onClearSearch: _clearFilters,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}