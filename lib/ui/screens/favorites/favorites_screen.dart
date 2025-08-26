import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../../providers/product_provider.dart';
import '../../../core/utils/constants.dart';
import '../../widgets/product_card.dart';
import '../../widgets/state_widgets.dart';
import '../product_detail/product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final ProductProvider productProvider;

  const FavoritesScreen({
    super.key,
    required this.productProvider,
  });

  void _navigateToProductDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: product,
          productProvider: productProvider,
        ),
      ),
    );
  }

  void _showClearFavoritesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limpar Favoritos'),
          content: const Text(
            'Tem certeza que deseja remover todos os produtos dos favoritos?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllFavorites();
              },
              child: const Text(
                'Limpar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearAllFavorites() async {
    final favorites = List<Product>.from(productProvider.value.favorites);
    for (final product in favorites) {
      await productProvider.toggleFavorite(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: [
          ValueListenableBuilder(
            valueListenable: productProvider,
            builder: (context, state, child) {
              if (!state.hasFavorites) return const SizedBox.shrink();
              
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'clear') {
                    _showClearFavoritesDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Limpar todos'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: productProvider,
        builder: (context, state, child) {
          if (state.isLoadingFavorites) {
            return const LoadingWidget(message: 'Carregando favoritos...');
          }

          if (state.hasError) {
            return CustomErrorWidget(
              message: state.error!,
              onRetry: productProvider.loadFavorites,
            );
          }

          if (!state.hasFavorites) {
            return EmptyWidget(
              message: AppConstants.emptyFavorites,
              subtitle: 'Adicione produtos aos favoritos para vê-los aqui',
              icon: Icons.favorite_border,
              action: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Explorar Produtos'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: productProvider.loadFavorites,
            child: Column(
              children: [
                // Header com contador
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  color: Colors.grey[50],
                  child: Text(
                    '${state.favorites.length} produto${state.favorites.length != 1 ? 's' : ''} favoritado${state.favorites.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Lista de favoritos
                Expanded(
                  child: _buildFavoritesList(context, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, state) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppConstants.smallPadding,
        mainAxisSpacing: AppConstants.smallPadding,
      ),
      itemCount: state.favorites.length,
      itemBuilder: (context, index) {
        final product = state.favorites[index];
        return ProductCard(
          product: product,
          isFavorite: true, // Sempre true na tela de favoritos
          onTap: () => _navigateToProductDetail(context, product),
          onFavoriteToggle: () => _showRemoveFavoriteDialog(context, product),
        );
      },
    );
  }

  void _showRemoveFavoriteDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remover Favorito'),
          content: Text(
            'Deseja remover "${product.title}" dos favoritos?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                productProvider.toggleFavorite(product);
                
                // Mostra snackbar de confirmação
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Produto removido dos favoritos'),
                    action: SnackBarAction(
                      label: 'Desfazer',
                      onPressed: () => productProvider.toggleFavorite(product),
                    ),
                  ),
                );
              },
              child: const Text(
                'Remover',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}