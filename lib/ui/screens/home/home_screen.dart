import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../../providers/product_provider.dart';
import '../../../core/utils/constants.dart';
import '../../widgets/state_widgets.dart';
import '../../widgets/product_card.dart';
import '../product_detail/product_detail_screen.dart';
import '../favorites/favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProductProvider _productProvider;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _productProvider = ProductProvider();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _productProvider.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _productProvider.searchProducts(_searchController.text);
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: product,
          productProvider: _productProvider,
        ),
      ),
    );
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          productProvider: _productProvider,
        ),
      ),
    );
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
        title: const Text('Products', style: TextStyle(fontSize: 20)),
        centerTitle: false,
        actions: [
          ValueListenableBuilder(
            valueListenable: _productProvider,
            builder: (context, state, child) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: _navigateToFavorites,
                    icon: const Icon(Icons.favorite_border_outlined),
                  ),
                  if (state.hasFavorites)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${state.favorites.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _productProvider,
          builder: (context, state, child) {
            return RefreshIndicator(
              onRefresh: _productProvider.refresh,
              child: Column(
                children: [
                  // Barra de busca e filtros
                  _buildSearchAndFilters(state),
                  // Lista de produtos
                  Expanded(
                    child: _buildProductList(state),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(state) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Campo de busca
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: state.isSearching
                    ? IconButton(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: AppConstants.defaultPadding,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }




  Widget _buildProductList(state) {
    if (state.isLoading && !state.hasProducts) {
      return const LoadingWidget(message: 'Loading products...');
    }

    if (state.hasError && !state.hasProducts) {
      return CustomErrorWidget(
        message: state.error!,
        onRetry: _productProvider.refresh,
      );
    }

    if (!state.hasProducts) {
      return const EmptyWidget(
        message: 'No products found',
        subtitle: 'Try again later',
        icon: Icons.shopping_bag_outlined,
      );
    }

    if (state.filteredProducts.isEmpty) {
      if (state.isSearching) {
        return NoSearchResultsWidget(
          searchQuery: state.searchQuery,
          onClearSearch: _clearFilters,
        );
      }
      return const EmptyWidget(
        message: 'No products in this category',
        icon: Icons.category_outlined,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: state.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = state.filteredProducts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
          child: ProductCard(
            product: product,
            isFavorite: _productProvider.isFavorite(product.id),
            onTap: () => _navigateToProductDetail(product),
            onFavoriteToggle: () => _productProvider.toggleFavorite(product),
          ),
        );
      },
    );
  }
}