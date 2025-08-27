import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../providers/product_state.dart';
import '../../core/utils/constants.dart';
import 'state_widgets.dart';
import 'product_card.dart';

class ProductListWidget extends StatelessWidget {
  final ProductState state;
  final ScrollController scrollController;
  final Function(Product) onProductTap;
  final Function(Product) onFavoriteToggle;
  final bool Function(int) isFavorite;
  final VoidCallback onRefresh;
  final VoidCallback onClearSearch;

  const ProductListWidget({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onProductTap,
    required this.onFavoriteToggle,
    required this.isFavorite,
    required this.onRefresh,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    // Estado de carregamento inicial
    if (state.isLoading && !state.hasProducts) {
      return const LoadingWidget(message: 'Loading products...');
    }

    // Estado de erro sem produtos
    if (state.hasError && !state.hasProducts) {
      return CustomErrorWidget(
        message: state.error!,
        onRetry: onRefresh,
      );
    }

    // Nenhum produto encontrado
    if (!state.hasProducts) {
      return const EmptyWidget(
        message: 'No products found',
        subtitle: 'Try again later',
        icon: Icons.shopping_bag_outlined,
      );
    }

    // Nenhum resultado na busca ou filtro
    if (state.filteredProducts.isEmpty) {
      if (state.isSearching) {
        return NoSearchResultsWidget(
          searchQuery: state.searchQuery,
          onClearSearch: onClearSearch,
        );
      }
      return const EmptyWidget(
        message: 'No products in this category',
        icon: Icons.category_outlined,
      );
    }

    // Lista de produtos
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: state.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = state.filteredProducts[index];
        return ProductCard(
          product: product,
          isFavorite: isFavorite(product.id),
          onTap: () => onProductTap(product),
          onFavoriteToggle: () => onFavoriteToggle(product),
        );
      },
    );
  }
}