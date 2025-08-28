import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../providers/product_state.dart';
import 'state_widgets.dart';
import 'product_card.dart';
import '../../core/utils/animations.dart';

class ProductListWidget extends StatelessWidget {
  final ProductState state;
  final ScrollController scrollController;
  final Function(Product) onProductTap;
  final Function(Product, BuildContext) onFavoriteToggle;
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
      return CustomErrorWidget(
        message: state.error!,
        onRetry: onRefresh,
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
    }

    // Lista de produtos
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: state.filteredProducts.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Indicador de carregamento no final da lista
        if (index == state.filteredProducts.length) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: AppAnimations.rotatingLoader(
                size: 32,
              ),
            ),
          );
        }
        
        final product = state.filteredProducts[index];
        return AnimatedListItem(
          index: index,
          child: ProductCard(
            product: product,
            isFavorite: isFavorite(product.id),
            onTap: () => onProductTap(product),
            onFavoriteToggle: () => onFavoriteToggle(product, context),
          ),
        );
      },
    );
  }
}