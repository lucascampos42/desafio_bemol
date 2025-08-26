import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../../providers/product_provider.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/helpers.dart';
import '../../widgets/product_card.dart';
import '../../widgets/state_widgets.dart';
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

  void _onCategorySelected(String? category) {
    _productProvider.filterByCategory(category);
  }

  void _clearFilters() {
    _searchController.clear();
    _productProvider.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          ValueListenableBuilder(
            valueListenable: _productProvider,
            builder: (context, state, child) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: _navigateToFavorites,
                    icon: const Icon(Icons.favorite),
                  ),
                  if (state.hasFavorites)
                    Positioned(
                      right: 8,
                      top: 8,
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
                            fontSize: 10,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar produtos...',
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
          const SizedBox(height: AppConstants.defaultPadding),
          // Filtro de categorias
          if (state.categories.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Todos'),
                        selected: state.selectedCategory == null,
                        onSelected: (_) => _onCategorySelected(null),
                      ),
                    );
                  }
                  
                  final category = state.categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(Helpers.capitalize(category)),
                      selected: state.selectedCategory == category,
                      onSelected: (_) => _onCategorySelected(category),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductList(state) {
    if (state.isLoading && !state.hasProducts) {
      return const LoadingWidget(message: 'Carregando produtos...');
    }

    if (state.hasError && !state.hasProducts) {
      return CustomErrorWidget(
        message: state.error!,
        onRetry: _productProvider.refresh,
      );
    }

    if (!state.hasProducts) {
      return const EmptyWidget(
        message: 'Nenhum produto encontrado',
        subtitle: 'Tente novamente mais tarde',
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
        message: 'Nenhum produto nesta categoria',
        icon: Icons.category_outlined,
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppConstants.smallPadding,
        mainAxisSpacing: AppConstants.smallPadding,
      ),
      itemCount: state.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = state.filteredProducts[index];
        return ProductCard(
          product: product,
          isFavorite: _productProvider.isFavorite(product.id),
          onTap: () => _navigateToProductDetail(product),
          onFavoriteToggle: () => _productProvider.toggleFavorite(product),
        );
      },
    );
  }
}