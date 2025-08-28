import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../providers/product_state.dart';
import '../../core/utils/responsive_helper.dart';
import 'state_widgets.dart';
import 'product_card.dart';
import 'responsive_product_card.dart';
import '../../core/utils/animations.dart';

/// Widget de lista de produtos responsivo
/// Mobile: ListView vertical tradicional
/// Desktop: GridView com cards otimizados
class ResponsiveProductListWidget extends StatelessWidget {
  final ProductState state;
  final ScrollController scrollController;
  final Function(Product) onProductTap;
  final Function(Product, BuildContext) onFavoriteToggle;
  final bool Function(int) isFavorite;
  final VoidCallback onRefresh;
  final VoidCallback onClearSearch;

  const ResponsiveProductListWidget({
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

    // Layout responsivo baseado no tamanho da tela
    return ResponsiveHelper.responsive(
      context: context,
      mobile: _buildMobileList(),
      tablet: _buildDesktopGrid(context),
      desktop: _buildDesktopGrid(context),
    );
  }

  /// Lista tradicional para mobile
  Widget _buildMobileList() {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: state.filteredProducts.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Indicador de carregamento no final da lista
        if (index == state.filteredProducts.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
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

  /// Grid responsivo para desktop/tablet
  Widget _buildDesktopGrid(BuildContext context) {
    final columns = ResponsiveHelper.getGridColumns(context);
    final spacing = ResponsiveHelper.getItemSpacing(context);
    final products = state.filteredProducts;
    
    return ResponsiveContainer(
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(spacing),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: ResponsiveHelper.responsiveValue(
                  context: context,
                  mobile: 1.0,
                  tablet: 0.8,
                  desktop: 0.75,
                  largeDesktop: 0.7,
                ),
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = products[index];
                  return AnimatedListItem(
                    index: index,
                    child: ResponsiveProductCard(
                      product: product,
                      isFavorite: isFavorite(product.id),
                      onTap: () => onProductTap(product),
                      onFavoriteToggle: () => onFavoriteToggle(product, context),
                    ),
                  );
                },
                childCount: products.length,
              ),
            ),
          ),
          // Indicador de carregamento no final
          if (state.isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(spacing),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget de item animado para listas
class AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration delay;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimations.fadeSlideIn(
      child: child,
    );
  }
}