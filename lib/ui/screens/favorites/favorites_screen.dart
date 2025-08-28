import 'package:desafio_bemol/core/utils/animations.dart';
import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/state_widgets.dart';
import '../error/error_screen.dart';
import '../product_detail/product_detail_screen.dart';
import '../../../core/utils/performance_metrics.dart';

class FavoritesScreen extends StatefulWidget {
  final ProductProvider productProvider;

  const FavoritesScreen({
    super.key,
    required this.productProvider,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _hasNavigatedToError = false;

  @override
  void initState() {
    super.initState();
    
    PerformanceMetrics.instance.trackScreenNavigation(
      'favorites_screen_loaded',
      {'favorites_count': widget.productProvider.value.favorites.length.toString()},
    );
    
    // Load favorites after initial build to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.productProvider.loadFavoritesOnly();
      }
    });
  }

  Future<void> _navigateToProductDetail(BuildContext context, Product product) async {
    PerformanceMetrics.instance.trackScreenNavigation(
      'favorites_to_product_detail',
      {'product_id': product.id.toString()},
    );
    
    await Navigator.push(
      context,
      AppAnimations.createRoute(
        page: ProductDetailScreen(
          product: product,
          productProvider: widget.productProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: widget.productProvider,
        builder: (context, state, child) {
          if (state.isLoadingFavorites) {
            return const LoadingWidget(message: 'Loading favorites...');
          }

          if (state.hasError) {
            if (!_hasNavigatedToError) {
              _hasNavigatedToError = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ErrorScreen()),
                  );
                }
              });
            }
            return const SizedBox.shrink();
          }

          if (!state.hasFavorites) {
            return Center(
              child: Image.asset(
                'assets/images/empty.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.favorite_border,
                    size: 64,
                  );
                },
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: widget.productProvider.loadFavoritesOnly,
            child: _buildFavoritesList(context, state),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, dynamic state) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: state.favorites.length,
      itemBuilder: (context, index) {
        final product = state.favorites[index];
        return AnimatedListItem(
          index: index,
          child: ProductCard(
            product: product,
            isFavorite: true,
            onTap: () => _navigateToProductDetail(context, product),
            onFavoriteToggle: () => widget.productProvider.toggleFavorite(product, context),
          ),
        );
      },
    );
  }
}
